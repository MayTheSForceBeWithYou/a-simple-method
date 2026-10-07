# 12 — Milestone: Tiny Language Compiler

Lesson 11 gave you tokens and AST nodes. This milestone lesson asks you to walk that AST and emit executable output—either bytecode for an interpreter you write, or machine code for the CPU. By the end you'll have drilled the primitives that turn a text program into something runnable: scanning multi-digit numbers and identifiers, folding constant expressions with correct precedence (including parentheses), interpreting a bytecode stream with load/add/jump/halt, allocating local variable slots, and bookkeeping symbol addresses and ELF header sizes. These 24 drills isolate each compiler primitive so you can verify it before integrating into a full compiler binary.

## What this lesson asks of you

- Scan a decimal number (multi-digit, base 10) and a lowercase identifier, rejecting a keyword test that only checks one letter.
- Fold constant expressions with `*` before `+`, including inside parentheses (so `(1+2)*3` = 9, not 7).
- Interpret a bytecode stream: fetch opcode, dispatch to handler (load immediate, add, jump, halt), update instruction pointer.
- Assign local variables by incrementing a slot counter, and call a function for its return value.
- Track ELF header size and symbol addresses as data (the drills do not write actual ELF bytes).

## Why a compiler as milestone 2

A compiler exercises every concept so far:
- **Lexing** (lesson 11): break text into tokens.
- **Parsing** (lesson 11): build an AST with correct precedence.
- **Code generation**: walk the AST, emit instructions (bytecode or machine code).
- **Symbol tables**: map variable names to stack slots or addresses.
- **Memory management**: allocate AST nodes in an arena (lesson 11).
- **Control flow**: generate jumps for `if` and `while`.
- **File I/O** (lesson 08): write the output binary.

The milestone is not a single drill—it's a capstone binary that passes six acceptance criteria. The drills below isolate each primitive. You compose them using lesson 09's multi-file build. Lesson 13 adds floating-point; lesson 14 adds graphics output.

## Scanning: numbers and identifiers

### Multi-digit decimal numbers

Lesson 11's `06-rd-parse-num.asm` parsed one digit. For multi-digit numbers, accumulate:

```
value = 0
for each digit d:
    value = value * 10 + d
```

In assembly:

```asm
section .data
    s: db "42", 0

section .text
global _start
_start:
    lea rsi, [s]
    xor rdi, rdi            ; value = 0
.next:
    movzx rax, byte [rsi]
    test rax, rax
    jz .done
    sub rax, '0'            ; digit value
    imul rdi, 10
    add rdi, rax
    inc rsi
    jmp .next
.done:
    mov rax, 60             ; rdi = 42
    syscall
```

**Drill:** `09-lex-number.asm` scans `"42"` and exits 42.

### Lowercase identifiers

An identifier starts with a letter `'a'..'z'` (or `'A'..'Z'` and `'_'` in a full language) and continues with letters or digits. For simplicity, these drills use only lowercase.

**Drill:** `02-lex-ident.asm` tests byte `'a'` (in range `'a'..'z'`) and exits 1 (true).

To measure an identifier's length, scan while the byte is in range:

```asm
; input: rsi = start of identifier
; output: rcx = length
    xor rcx, rcx
.scan:
    movzx rax, byte [rsi + rcx]
    cmp rax, 'a'
    jb .done
    cmp rax, 'z'
    ja .done
    inc rcx
    jmp .scan
.done:
```

**Drill:** `10-lex-ident-len.asm` scans `"foo"` and exits 3.

### Keywords: whole-word matching

A **keyword** like `let` must match the entire word, not just the first letter. The drill `03-parse-let.asm` compares only the first byte to `'l'` and exits 1—this is **wrong** (it would accept `"lxxx"`), but it's a simplified placeholder to show the single-byte test.

A correct keyword test:

```asm
; input: rsi = pointer to source
; output: ZF set if "let" matched, rsi advanced
.parse_let:
    cmp byte [rsi], 'l'
    jne .no
    cmp byte [rsi + 1], 'e'
    jne .no
    cmp byte [rsi + 2], 't'
    jne .no
    ; check boundary: next byte must not be alphanumeric
    movzx rax, byte [rsi + 3]
    cmp rax, 'a'
    jae .check_upper        ; could be 'a'..'z'
    ; not alpha, matched
    add rsi, 3
    ret
.check_upper:
    cmp rax, 'z'
    jbe .no                 ; 'a'..'z', so "let" is a prefix of a longer ident
    ; matched
    add rsi, 3
    ret
.no:
    ; ZF clear
```

Without the boundary check, `"letter"` would lex as keyword `let` followed by identifier `ter`.

## The grammar

The compiler's language (a tiny subset of a real language):

```
program    := stmt*
stmt       := let_stmt | while_stmt | expr
let_stmt   := "let" ident "=" expr
while_stmt := "while" expr "do" stmt
expr       := term ("+" term)*
term       := factor ("*" factor)*
factor     := number | ident | "(" expr ")" | if_expr | call
if_expr    := "if" expr "then" expr "else" expr
call       := ident "(" [expr ("," expr)*] ")"
```

**Precedence** is encoded in the grammar's layering: `term` contains `factor` with `*` between them, and `expr` contains `term` with `+` between them. Therefore `*` binds tighter than `+`: `2*3+4` is `(2*3)+4` = 10, not `2*(3+4)` = 14.

Parentheses reset to `expr`, so `(1+2)*3` parses as `factor = (expr = 1+2)`, then `term = factor * 3` = 9.

## Constant folding

When the compiler sees `2+3`, it can emit code that computes it at runtime, or it can fold the constants at compile time and emit `5`. These drills demonstrate the fold.

**Drill:** `04-codegen-add.asm` and `11-parse-binop.asm` compute `2+3` and exit 5.

**Drill:** `08-from-scratch-const-fold.asm` and `12-parse-paren.asm` compute `(1+2)*3` = 9.

**Drill:** `24-from-scratch-compile-add.asm` computes `40+2` = 42.

### Precedence bug

**Drill:** `21-debug-fold-bug.asm` computes `2*3+4` as `2*(3+4)` = 14 (wrong). The fix multiplies first:

```asm
section .text
global _start
_start:
    mov rax, 2
    imul rax, 3             ; 6, not (3+4)
    add rax, 4              ; 10
    mov rdi, rax
    mov rax, 60
    syscall
```

The corrected exit is 10.

## Control flow: if and while

### If expressions

An `if` in this language is an **expression** (returns a value), not a statement:

```
if condition then value1 else value2
```

If `condition` is nonzero, the result is `value1`; otherwise `value2`.

**Drill:** `16-if-codegen.asm` has `condition = 1`, so it takes the then-value 7 (not the else-value 9) and exits 7.

Pseudocode:

```
mov rax, condition
test rax, rax
jz .else
mov rdi, then_value
jmp .done
.else:
mov rdi, else_value
.done:
```

### While loops

A `while` loop repeats a statement as long as the condition is nonzero:

```
while i < 3 do i = i + 1
```

**Drill:** `17-while-codegen.asm` increments `i` from 0 until `i == 3`, exits 3.

Pseudocode:

```
.loop:
    ; evaluate condition
    test rax, rax
    jz .done
    ; body
    ; ...
    jmp .loop
.done:
```

### Function calls

A `call` invokes a function and uses its return value as an expression:

```
add(2, 3)
```

**Drill:** `18-call-codegen.asm` represents a call that returns 11, exits 11. (The drill does not implement a real `call`/`ret` sequence; it's a constant-folding placeholder.)

## Bytecode interpreter

Instead of emitting x86-64 machine code, a simpler compiler can emit **bytecode**: a stream of bytes interpreted by a virtual machine you write. The drills use a minimal bytecode with four opcodes:

| Opcode | Operand(s) | Effect |
|--------|------------|--------|
| 0 | none | Halt; pop stack and exit with that value |
| 1 | imm8 | Push the byte onto the stack |
| 2 | none | Pop two values, add them, push result |
| 3 | rel8 | Jump: add `rel8` to `rsi` (relative to the byte **after** the operand) |

**Drill:** `05-bytecode-interp.asm` runs bytecode `1,4, 1,5, 2, 0` (push 4, push 5, add, halt) and exits 9.

**Drill:** `19-bytecode-jump.asm` runs `3,2, 1,99, 1,5, 0` (jump over the `1,99`, then push 5, halt) and exits 5.

**Note on jump displacement signedness:** The drill loads the displacement byte with `movzx` (unsigned zero-extend), so it only supports forward jumps (0–127 bytes). A backward jump would require `movsx` (signed sign-extend) so that byte values 128–255 are interpreted as negative offsets −128 to −1. The drill demonstrates forward jumps only.

### Fetch-decode-execute loop

```asm
section .data
    code db 1, 4, 1, 5, 2, 0

section .bss
    st resq 16
    sp_ resq 1

section .text
global _start
_start:
    mov qword [sp_], 0
    lea rsi, [code]
.fetch:
    movzx rax, byte [rsi]   ; fetch opcode
    inc rsi                 ; advance past opcode
    cmp rax, 0
    je .halt
    cmp rax, 1
    je .push
    cmp rax, 2
    je .add
    ; unknown opcode, error
    mov rdi, 255
    mov rax, 60
    syscall

.push:
    movzx rax, byte [rsi]   ; fetch operand
    inc rsi
    mov rcx, [sp_]
    mov [st + rcx*8], rax
    inc qword [sp_]
    jmp .fetch

.add:
    dec qword [sp_]
    mov rcx, [sp_]
    mov rbx, [st + rcx*8]    ; second operand
    dec qword [sp_]
    mov rcx, [sp_]
    mov rax, [st + rcx*8]    ; first operand
    add rax, rbx
    mov [st + rcx*8], rax
    inc qword [sp_]
    jmp .fetch

.halt:
    dec qword [sp_]
    mov rcx, [sp_]
    mov rdi, [st + rcx*8]
    mov rax, 60
    syscall
```

**Drill:** This is `05-bytecode-interp.asm` (simplified listing). It exits 9.

### Jump displacement

The jump opcode (3) takes a **relative displacement** (rel8). The displacement is added to `rsi` **after** the opcode and operand have been consumed (so `rsi` points to the byte after the displacement).

**Example:** Bytecode `3,2, 1,99, 1,5, 0`:

| Offset | Byte | Meaning |
|-------:|------|---------|
| 0 | 3 | Jump opcode |
| 1 | 2 | Displacement (skip 2 bytes forward) |
| 2 | 1 | (Skipped) Push opcode |
| 3 | 99 | (Skipped) Operand |
| 4 | 1 | Push opcode |
| 5 | 5 | Operand |
| 6 | 0 | Halt |

When the fetch loop reads offset 0, it increments `rsi` to 1. The `.jmp` handler reads the displacement 2, increments `rsi` to 2, **then** adds 2, so `rsi` becomes 4. Execution resumes at offset 4 (`1,5`), skipping the `1,99`.

**Drill:** `19-bytecode-jump.asm` exits 5 (not 99).

## Local variable slots

Each local variable gets a **slot** (an index into a locals array or stack frame). To allocate a slot, increment a counter.

**Drill:** `15-local-slot-alloc.asm` allocates three locals (slots 0, 1, 2) and exits 3 (the next slot counter).

**Drill:** `06-symbol-slot.asm` stores value 42 in slot 0 and exits 42.

**Drill:** `23-stretch-symbol-resolve.asm` resolves a symbol to address `0x20` and exits 32 (decimal).

### Type tags

A type checker tags each expression with a type (integer, float, string, etc.). For these drills, integer is type 1.

**Drill:** `20-type-check-int.asm` defines `TYPE_INT = 1` and exits 1.

## Emit: code generation bookkeeping

These drills represent **emit** operations (writing instructions or data to an output buffer) as storing values and exiting with them. They do **not** write ELF bytes.

**Drill:** `01-emit-mov-imm.asm` and `13-codegen-mov.asm` store the immediate value 42 and exit 42.

**Drill:** `14-codegen-add-regs.asm` stores the sum `10+32` = 42 and exits 42.

**Drill:** `07-emit-syscall-exit.asm` stores an exit syscall and exits 0.

### ELF header size

An ELF64 header (`Elf64_Ehdr`) is 64 bytes. A runnable ELF also needs at least one program header (`Elf64_Phdr`, 56 bytes), but the drill only accounts for the `Ehdr`.

**Drill:** `22-stretch-emit-elf-note.asm` exits 64 (the `Ehdr` size). It does not write `e_ident`, program headers, or code bytes.

## Worked example: jump displacement in `19-bytecode-jump.asm`

**Task:** Bytecode `3,2, 1,99, 1,5, 0` has a jump opcode (3) with operand 2. Where does execution resume after the jump?

**Fetch loop before the handler runs:**

1. `rsi = 0` (pointing at opcode 3).
2. Fetch: `movzx rax, byte [rsi]` → `rax = 3`, `inc rsi` → `rsi = 1`.
3. Dispatch to `.jmp`.

**Jump handler:**

```asm
.jmp:
    movzx rax, byte [rsi]   ; rsi = 1, rax = 2 (operand)
    inc rsi                 ; rsi = 2
    add rsi, rax            ; rsi = 2 + 2 = 4
    jmp .fetch
```

**Plausible wrong reading:**

*"Opcode 3 with operand 2 jumps two bytes forward from the opcode. The opcode is at offset 0, so execution resumes at offset 2, which is `1,99`, and 99 gets loaded."*

**Why it's wrong:** By the time `.jmp` runs, the fetch loop has already incremented `rsi` past the opcode (to offset 1). The handler reads the operand (offset 1) and increments `rsi` to 2. Only then does `add rsi, rax` add 2, giving offset 4. The displacement is measured from the byte **after** the operand, not from the opcode.

**The correct reading:** Execution resumes at offset 4, which is `1,5` (push 5), followed by `0` (halt). The `1,99` at offsets 2–3 never runs. The exit is 5.

**Rule:** To encode a jump by hand, compute `rel8 = target_offset - (jump_instruction_start + 2)`, where 2 accounts for the opcode and operand bytes.

## Distinctions worth keeping straight

| Confusion | Reality |
|-----------|---------|
| Keyword test checks only the first letter | Must check all letters **and** the boundary (next byte is not alphanumeric) |
| `2*3+4` is left-to-right, so `(2*3)+4` | Correct, because `*` binds tighter than `+` |
| `(1+2)*3` is `1 + (2*3)` | Wrong; parentheses reset precedence, so `(1+2)` is evaluated first → 9 |
| Jump displacement is from the opcode | Displacement is added to `rsi` **after** opcode and operand are consumed |
| Bytecode stack is `rsp` | Bytecode uses a separate array (`stack`) and index (`sp`), not the CPU stack |
| Emit drills write ELF bytes | Emit drills store values and exit; actual ELF writing is deferred to the full compiler |
| ELF header alone makes a runnable binary | A runnable ELF also needs at least one program header (56 bytes) |

## Check yourself

1. In `05-bytecode-interp.asm`, the `.add` handler pops twice and pushes once. Given bytecode `1,4, 1,5, 2, 0` (push 4, push 5, add, halt), what is `sp` after the program halts (before `.halt` decrements it)?

2. `03-parse-let.asm` exits 1 for `"let"`. Name one input that should be rejected but that this file would also accept. What must the real check do?

3. `16-if-codegen.asm` does `mov rax, 1` / `test rax, rax` / `jz .else`. Which branch is taken (then or else)? What would change if the condition register held 2?

4. You encode a jump from offset 10 to offset 20. The jump opcode (3) and its operand take 2 bytes. What value (rel8) should the operand byte hold?

5. You allocate local variables with a counter `next_slot`, starting at 0. After allocating three locals, what is `next_slot`? If you then allocate two more, what slot does the fifth local get?

## Key takeaways

- Multi-digit decimal scanning accumulates `value * 10 + digit` until a non-digit byte.
- Keyword matching requires testing all bytes **and** the trailing boundary (so `"letter"` is not `let` + `ter`).
- Operator precedence is encoded in grammar layering: `term` (with `*`) binds tighter than `expr` (with `+`); parentheses reset to `expr`.
- Bytecode interpretation is a fetch-decode-execute loop with explicit stack and instruction pointer (separate from CPU `rsp` and `rip`).
- Jump displacement is relative to the byte **after** the operand, not the opcode.
- Local variable allocation increments a slot counter; slots are indices into a locals array or stack frame.
- ELF emission bookkeeping tracks header sizes and symbol addresses; actual byte writing is deferred to the full compiler.

## Lookup

- Recursive-descent parsing: [Crafting Interpreters Chapter 6](https://craftinginterpreters.com/parsing-expressions.html)
- Bytecode virtual machines: [Crafting Interpreters Chapter 14](https://craftinginterpreters.com/chunks-of-bytecode.html)
- ELF format: [man elf(5)](https://man7.org/linux/man-pages/man5/elf.5.html), [ELF-64 Object File Format v1.5](https://refspecs.linuxfoundation.org/elf/elf.pdf)
- Operator precedence: [Wikipedia: Order of operations](https://en.wikipedia.org/wiki/Order_of_operations)

## Acceptance criteria

The milestone binary is complete when it satisfies all six criteria:

1. **Precedence:** `let x = 2*3+4` folds to 10 (not 14). `*` binds tighter than `+`.
2. **Parentheses:** `(1+2)*3` folds to 9 (not 7). Parentheses reset precedence.
3. **Keywords:** `lxxx` is rejected. The whole word `let` must match, not just the first letter.
4. **Bytecode:** The interpreter runs `1,4, 1,5, 2, 0` and exits 9.
5. **Locals and calls:** Three locals take slots 0, 1, 2. A call exits its return value.
6. **Control flow:** An `if` with a nonzero condition takes the then-value. A `while` with `i < 3` exits 3.

Floating-point is lesson 13. ELF emission (writing actual bytes) is a stretch until the full compiler binary writes them.

## Exercises

Twenty-four drills under `exercises/`. Solutions mirror the names under `solutions/`. Build with:

```bash
nasm -f elf64 FILE.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
```

**Scanning:**
- `02-lex-ident.asm` — test `'a'` in range, exit 1
- `03-parse-let.asm` — check first letter `'l'`, exit 1 (incomplete keyword test)
- `09-lex-number.asm` — scan `"42"`, exit 42
- `10-lex-ident-len.asm` — scan `"foo"`, exit 3

**Constant folding and control:**
- `04-codegen-add.asm` — fold `2+3`, exit 5
- `08-from-scratch-const-fold.asm` — fold `(1+2)*3`, exit 9
- `11-parse-binop.asm` — fold `2+3`, exit 5
- `12-parse-paren.asm` — fold `(1+2)*3`, exit 9
- `16-if-codegen.asm` — if condition 1, then 7, else 9, exit 7
- `17-while-codegen.asm` — while `i < 3`, increment `i`, exit 3
- `18-call-codegen.asm` — call returns 11, exit 11
- `21-debug-fold-bug.asm` — fix: `2*3+4` = 10 (not 14)
- `24-from-scratch-compile-add.asm` — fold `40+2`, exit 42

**Bytecode and slots:**
- `01-emit-mov-imm.asm` — emit mov immediate 42, exit 42
- `05-bytecode-interp.asm` — interpret `1,4, 1,5, 2, 0`, exit 9
- `06-symbol-slot.asm` — slot 0 holds 42, exit 42
- `07-emit-syscall-exit.asm` — emit exit syscall, exit 0
- `13-codegen-mov.asm` — emit mov 42, exit 42
- `14-codegen-add-regs.asm` — emit add `10+32`, exit 42
- `15-local-slot-alloc.asm` — allocate 3 locals, exit 3
- `19-bytecode-jump.asm` — jump over `1,99`, exit 5
- `20-type-check-int.asm` — `TYPE_INT = 1`, exit 1
- `22-stretch-emit-elf-note.asm` — ELF header size 64, exit 64 (no actual ELF)
- `23-stretch-symbol-resolve.asm` — resolve address `0x20`, exit 32
