# Lesson 12 — Milestone: Tiny Language Compiler

## Learning objectives

1. Scan a decimal and a lowercase ident, and reject a keyword test that only checks one letter.
2. Fold constants with `*` before `+`, including inside parentheses.
3. Interpret a byte stream: load, add, jump, halt.
4. Assign locals by incrementing a slot counter and call a function for its return value.
5. Keep an ELF size and a symbol address as data. These drills do not write an object file.

The roadmap's compiler emits a runnable ELF. These 24 files are the folds, the scan, and one bytecode loop. They do not print NASM, and they do not write ELF bytes. Floating point is lesson 13.

## Scan

A lowercase ident starts in `'a'..'z'`. The byte `'a'` exits 1 (`02-lex-ident.asm`). `"foo"` exits 3 because each in-range byte increments the length (`10-lex-ident-len.asm`). `"let"` exits 1 because the solution compares the first byte to `'l'` and stops (`03-parse-let.asm`). That is not a keyword test. `lxxx` would pass.

A number is a running total times ten, plus the next digit.

```asm
section .data
    s db "42", 0
section .text
global _start
_start:
    lea rsi, [s]
    xor rdi, rdi
.next:
    movzx rax, byte [rsi]
    test rax, rax
    jz .done
    sub rax, '0'
    imul rdi, 10
    add rdi, rax
    inc rsi
    jmp .next
.done:
    mov rax, 60             ; rdi == 42
    syscall
```

That is `09-lex-number.asm`. One digit in lesson 11 was a single `sub`. This loop is the multi-digit form.

## Fold

`2+3` exits 5 (`04-codegen-add.asm`, `11-parse-binop.asm`). `(1+2)*3` adds first, then multiplies, and exits 9 (`08-from-scratch-const-fold.asm`, `12-parse-paren.asm`). `40+2` exits 42 (`24-from-scratch-compile-add.asm`).

`21-debug-fold-bug.asm` computes `2*3+4` as `2*(3+4)`. The fix multiplies first.

```asm
section .text
global _start
_start:
    mov rax, 2
    imul rax, 3             ; 6, not (3+4) first
    add rax, 4
    mov rdi, rax            ; 10
    mov rax, 60
    syscall
```

An `if` whose condition is 1 takes the then-value 7, not the else-value 9 (`16-if-codegen.asm`). A while that increments while `i < 3` exits 3 (`17-while-codegen.asm`). A call that returns 11 exits 11 (`18-call-codegen.asm`). None of these print an instruction stream. The "emit" drills store a qword and exit with it: 42 in `01-emit-mov-imm.asm` and `13-codegen-mov.asm`, `10+32` in `14-codegen-add-regs.asm`, and a bare `exit 0` in `07-emit-syscall-exit.asm`.

## Bytecode

The interpreter in `05-bytecode-interp.asm` and `19-bytecode-jump.asm` is a fetch loop. The opcode is one byte. The instruction pointer is `rsi`, already advanced past that byte before the handler runs.

| Opcode | Bytes after it | Effect |
|--------|----------------|--------|
| 0 | none | halt; exit the top of the value stack |
| 1 | imm8 | push that byte |
| 2 | none | pop `a`, pop `b`, push `a+b` |
| 3 | rel8 | add `rel8` to `rsi` after the rel8 byte has been consumed |

`1, 4, 1, 5, 2, 0` pushes 4, pushes 5, adds, halts. Exit 9. A jump's displacement is not measured from the opcode. `3, 2` consumes the `2`, then adds 2, which skips the next two bytes.

```asm
section .data
    code db 3, 2, 1, 99, 1, 5, 0
section .bss
    st resq 4
    sp_ resq 1
section .text
global _start
_start:
    mov qword [sp_], 0
    lea rsi, [code]
.fetch:
    movzx rax, byte [rsi]
    inc rsi
    cmp rax, 1
    je .load
    cmp rax, 3
    je .jmp
    jmp .halt
.load:
    movzx rax, byte [rsi]
    inc rsi
    mov rcx, [sp_]
    mov [st+rcx*8], rax
    inc qword [sp_]
    jmp .fetch
.jmp:
    movzx rax, byte [rsi]
    inc rsi
    add rsi, rax            ; skip 1, 99
    jmp .fetch
.halt:
    dec qword [sp_]
    mov rcx, [sp_]
    mov rdi, [st+rcx*8]     ; 5
    mov rax, 60
    syscall
```

The load of 99 never runs. Exit 5. Add is opcode 2 in the other drill. This listing has no add.

## Slots, types, ELF

Each local increments `next_slot`. Three locals exit 3 (`15-local-slot-alloc.asm`). Slot 0 holding 42 exits 42 (`06-symbol-slot.asm`). A resolved address of `0x20` exits 32 (`23-stretch-symbol-resolve.asm`). The integer type tag is 1 (`20-type-check-int.asm`). An ELF header is 64 bytes. `22-stretch-emit-elf-note.asm` exits 64. It does not emit `e_ident`, a program header, or a single instruction byte. When you do emit bytes later, you still assemble or load them outside this drill.

## Exercises

24 drills under `exercises/`. Solutions mirror the names in `solutions/`. Build with `nasm -f elf64 FILE -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?`.

Scan: `02-lex-ident.asm`, `03-parse-let.asm` (first letter only), `09-lex-number.asm`, `10-lex-ident-len.asm`, `20-type-check-int.asm`. Fold and control: `04-codegen-add.asm`, `08-from-scratch-const-fold.asm`, `11-parse-binop.asm`, `12-parse-paren.asm`, `16-if-codegen.asm`, `17-while-codegen.asm`, `18-call-codegen.asm`, `21-debug-fold-bug.asm` (exit 10), `24-from-scratch-compile-add.asm`. Bytes and slots: `01-emit-mov-imm.asm`, `05-bytecode-interp.asm` (exit 9), `06-symbol-slot.asm`, `07-emit-syscall-exit.asm`, `13-codegen-mov.asm`, `14-codegen-add-regs.asm`, `15-local-slot-alloc.asm`, `19-bytecode-jump.asm` (exit 5), `22-stretch-emit-elf-note.asm` (exit 64, no ELF), `23-stretch-symbol-resolve.asm`.