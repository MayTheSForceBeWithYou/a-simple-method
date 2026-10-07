# 11 — Parsing & Data Structures

Lesson 10 gave you a byte buffer and a cursor. This lesson gives you the data structures that turn those bytes into meaning: **tokens** (lexeme text plus classification), **abstract syntax trees** (nodes with kinds and children), **linked lists** (heap-free chains), **arenas** (bump-pointer allocation), **stacks** and **queues** (explicit FIFO/LIFO without `rsp`). By the end you'll see that parsing and data-structure manipulation in assembly is not magic—it's pointer arithmetic, null checks, and knowing when to test before you load.

## What this lesson asks of you

- Classify bytes as digits or spaces, extract a lexeme (the source text slice a token was cut from), and store it with its length.
- Walk a linked list by following `next` pointers until you hit null (0), not a sentinel node.
- Allocate from a bump arena by adding the request size to a cursor, aligning the cursor up to 8 bytes when required.
- Push and pop an explicit stack (array + index), and enqueue/dequeue a ring buffer in FIFO order.
- Recognize operator precedence (`*` binds tighter than `+`) and store an AST node as three qwords (kind, left child, right child).

## Why parsing matters for the compiler milestone

Lesson 12's tiny compiler takes a text program and emits bytecode or assembly. Before you can emit, you must **parse**: break the text into tokens (lexing), then build an abstract syntax tree (parsing). The AST nodes are allocated in an arena, linked by pointers. The compiler evaluates the AST with a stack (not the CPU stack—your own array). The BFS pathfinder in lesson 17 uses the ring queue from this lesson. Every data structure here is a building block for later milestones.

## Lexing: from bytes to tokens

A **lexer** (or tokenizer) scans input text and produces a stream of **tokens**. Each token has a **kind** (number, identifier, operator, keyword, EOF) and a **lexeme** (the source text it was cut from, plus length).

### Token kinds

Represent kinds as integers:

| Kind | Value | Meaning |
|------|------:|---------|
| `TK_EOF` | 0 | End of file |
| `TK_NUM` | 1 | Number literal |
| `TK_IDENT` | 2 | Identifier (variable name) |
| `TK_PLUS` | 3 | `+` operator |
| `TK_STAR` | 4 | `*` operator |

**Drill:** `01-token-kind.asm` defines `TK_NUM = 1` and exits 1.

### Digit classification

A byte is a digit if it's in the inclusive range `'0'` (48) through `'9'` (57):

```asm
; input: al = byte
; output: ZF set if digit, clear if not
    cmp al, '0'
    jb .not_digit
    cmp al, '9'
    ja .not_digit
    ; is digit
.not_digit:
```

**Drill:** `02-lexer-digit.asm` tests byte `'7'` and exits 1 (true).

### Skipping whitespace

For simplicity, treat space (`32`) as the only whitespace. A real lexer would also skip tabs, newlines, and carriage returns.

```asm
; input: rsi = pointer into source text
; output: rsi advanced past spaces
.skip_ws:
    cmp byte [rsi], 32
    jne .done
    inc rsi
    jmp .skip_ws
.done:
```

**Drill:** `09-lexer-skip-ws.asm` skips two spaces in `"  7"` and exits 7 (the digit value `'7' - '0'`, not the token kind).

### Lexeme buffer

A token stores its lexeme text in a buffer, along with a length. For the input `"let"`, copy three bytes and store length 3. The null terminator (if copied) does **not** count toward the length.

```asm
section .data
    src: db "let", 0
section .bss
    lexbuf: resb 16
    lexlen: resq 1

section .text
global _start
_start:
    xor rcx, rcx
.copy:
    mov al, [src + rcx]
    test al, al
    jz .done
    mov [lexbuf + rcx], al
    inc rcx
    jmp .copy
.done:
    mov [lexlen], rcx      ; 3
    mov rdi, rcx
    mov rax, 60
    syscall
```

**Drill:** `10-token-buffer.asm` copies `"let"` and exits 3.

### Parsing a number

To parse a digit as a number, subtract `'0'`:

```asm
mov al, '3'
sub al, '0'             ; rax = 3
```

**Drill:** `06-rd-parse-num.asm` parses `'3'` and exits 3.

For multi-digit numbers, accumulate: `value = value * 10 + digit`. Lesson 12 will show the full loop. For this lesson, one digit is enough.

### Expect: asserting the next character

Recursive-descent parsers have a helper `expect(char)` that checks the next input byte and advances if it matches, or errors if it doesn't.

```asm
; input: rsi = current position, al = expected char
; output: rsi advanced by 1, or error
expect:
    cmp byte [rsi], al
    jne .error
    inc rsi
    ret
.error:
    ; handle error (exit, print message, etc.)
```

**Drill:** `15-rd-expect.asm` expects `'('` at the first byte of `"(1)"` and exits 1 (success).

### Error spans

When a parse error occurs, report the **offset** (index into the source string) where it happened, and optionally a length. This is an **error span**.

**Drill:** `23-stretch-error-span.asm` stores an error offset of 4 (and a length of 1, not used for the exit). It exits 4.

## Linked lists and the null check

A **linked list** is a chain of nodes, each holding data and a pointer to the next node. The end of the list is marked by a null pointer (0), not a sentinel node.

### Node structure

A minimal node is two qwords:

```asm
struc Node
    .value: resq 1          ; 8 bytes
    .next: resq 1           ; 8 bytes (pointer to next node, or 0)
endstruc
```

In memory, allocate nodes in `.data` or from an arena (bump allocator, covered below).

**Drill:** `03-list-node.asm` defines one node with value 9 and next 0, exits 9.

### Push-front (cons)

To add a node to the front of a list:

1. Allocate a new node.
2. Set `new.next = old_head`.
3. Update `head = new`.

```asm
section .bss
    head: resq 1
    node1: resq 2           ; value, next
    node2: resq 2

section .text
global _start
_start:
    ; push 1
    mov qword [node1], 1
    mov rax, [head]         ; old head (0)
    mov [node1 + 8], rax
    lea rax, [node1]
    mov [head], rax

    ; push 2
    mov qword [node2], 2
    mov rax, [head]
    mov [node2 + 8], rax
    lea rax, [node2]
    mov [head], rax         ; head now points to node2 (value 2)

    ; exit with head value
    mov rsi, [head]
    mov rdi, [rsi]          ; 2
    mov rax, 60
    syscall
```

**Drill:** `11-ll-push-front.asm` pushes 1 then 2, exits 2 (the new head's value).

### Walking and summing

To traverse a list, follow `next` pointers until you hit null. **Critical:** test the pointer **before** dereferencing it.

```asm
section .data
    n3: dq 5, 0
    n2: dq 4, n3
    n1: dq 3, n2

section .text
global _start
_start:
    lea rsi, [n1]
    xor rdi, rdi            ; sum = 0
.walk:
    test rsi, rsi           ; null check BEFORE load
    jz .done
    add rdi, [rsi]          ; value
    mov rsi, [rsi + 8]      ; next
    jmp .walk
.done:
    mov rax, 60             ; rdi = 3 + 4 + 5 = 12
    syscall
```

**Drill:** `12-ll-sum.asm` sums `3 -> 4 -> 5` and exits 12.

**Common mistake:** Loading `[rsi]` before the null check. If the list is empty (head is null), you'll segfault.

**Drill:** `19-debug-null-deref-guard.asm` starts with a null head, loads `[rsi]` **before** testing, and segfaults. The fix moves the `test rsi, rsi` before the load, exiting 0 for an empty list.

## Arena (bump allocator)

An **arena** is a contiguous block of memory with a **bump pointer** (cursor). To allocate N bytes, return the current cursor and add N to it. No free, no fragmentation—just a monotonically increasing integer.

```asm
section .bss
    arena: resb 4096
    bump: resq 1

section .text
alloc:
    ; input: rdi = size
    ; output: rax = pointer
    mov rax, [bump]
    add rax, arena          ; absolute address
    add qword [bump], rdi
    ret
```

**Drill:** `04-arena-bump.asm` allocates two 16-byte chunks, leaving `bump = 32`. It exits `32 & 0xFF` = 32.

### Alignment

Pointers to 8-byte values (qwords) should be 8-byte aligned (address is a multiple of 8). To align a bump pointer up to 8:

```
aligned = (bump + 7) & ~7
```

**Drill:** `14-arena-align.asm` starts with `bump = 1`, computes `(1 + 7) & ~7` = 8, and exits 8.

The formula works because:
- `bump + (align - 1)` pushes you past the next boundary if you're not already on one.
- `& ~(align - 1)` masks off the low bits, rounding down to the boundary.

For `bump = 8` (already aligned), `(8 + 7) & ~7` = 15 & 0xFFFFFFF8 = 8 (no change).

## Vector: dynamic array (fixed capacity in these drills)

A **vector** is a growable array: data buffer, length (number of used slots), and capacity (number of allocated slots).

```asm
section .bss
    vec_data: resq 8        ; capacity 8
    vec_len: resq 1
    vec_cap: resq 1

section .text
vector_push:
    ; input: rdi = value
    mov rax, [vec_len]
    cmp rax, [vec_cap]
    jae .full               ; len >= cap, need to grow
    mov rcx, [vec_len]
    mov [vec_data + rcx*8], rdi
    inc qword [vec_len]
    ret
.full:
    ; (real code would realloc; these drills do not)
    ret
```

**Drill:** `24-from-scratch-vector-push.asm` pushes three values into a fixed-capacity buffer, exits 3 (the length). No reallocation—if you push beyond capacity, the drill misbehaves (or segfaults in the TODO stub).

## Hash table slot (no probing)

A **hash table** maps keys to values by hashing the key to an index. A minimal hash mix:

```asm
; input: rax = key (integer or hash of string)
; output: rax = mixed hash
    mov rbx, rax
    shl rbx, 3              ; x << 3
    xor rax, rbx            ; x ^ (x << 3)
```

**Drill:** `05-hash-mix.asm` mixes 5 → 5 ^ 40 = 45, exits 45 (low byte).

### Put and get (no collision handling)

A four-slot table stores a value at index 2 (`slots + 16` bytes):

```asm
section .bss
    slots: resq 4

section .text
global _start
_start:
    mov qword [slots + 16], 42  ; index 2
    mov rdi, [slots + 16]
    mov rax, 60
    syscall
```

**Drill:** `13-hashmap-put-get.asm` exits 42. There's no hash computation, no probing, no key comparison—just direct indexing. A real hash table would hash the key, probe on collision, and store key-value pairs.

### String interning (pointer equality after deduplication)

**Interning** reuses a single shared copy of each distinct string. After interning, you can compare strings by pointer equality instead of `memcmp`.

**Drill:** `21-intern-string.asm` compares two pointers to the same address and exits 1 (equal). The drill does **not** show the content-based lookup that populated the intern table—it only shows the pointer comparison after interning is done.

## Stack and queue: explicit data structures

The CPU's `rsp` and `call`/`ret` are for **procedure calls**. For your own LIFO or FIFO, use an explicit stack or queue.

### Explicit stack

```asm
section .bss
    stk: resq 16
    sp: resq 1

section .text
push_val:
    ; input: rdi = value
    mov rcx, [sp]
    mov [stk + rcx*8], rdi
    inc qword [sp]
    ret

pop_val:
    ; output: rax = value
    dec qword [sp]
    mov rcx, [sp]
    mov rax, [stk + rcx*8]
    ret
```

**Drill:** `07-stack-ds.asm` pushes 1, pushes 2, pops, exits 2 (LIFO).

**Drill:** `16-expr-stack.asm` pushes 2, pushes 3, pops both, adds, exits 5.

### Ring buffer (FIFO queue)

A **ring buffer** (circular queue) has a fixed capacity and two indices: `head` (dequeue) and `tail` (enqueue). After incrementing past the end, wrap with a mask.

**Naive (non-wrapping) version:**

```asm
section .bss
    q: resq 4
    head: resq 1
    tail: resq 1

section .text
enqueue:
    ; input: rdi = value
    mov rcx, [tail]
    mov [q + rcx*8], rdi
    inc qword [tail]
    ret

dequeue:
    ; output: rax = value
    mov rcx, [head]
    mov rax, [q + rcx*8]
    inc qword [head]
    ret
```

**Drill:** `20-queue-ring.asm` enqueues 7 and 8, dequeues, exits 7 (FIFO). The drill does **not** wrap indices—after four enqueues, the fifth would overflow the buffer. The lesson explicitly says "The solution does not wrap with a mask."

**Correct ring behavior:** After each increment, mask the index:

```asm
inc qword [tail]
and qword [tail], 3     ; wrap to [0..3] for capacity 4
```

You also need to track a count (or keep one slot empty) to distinguish a full ring from an empty ring (both have `head == tail` without extra state).

## Operator precedence and AST nodes

### Precedence (binding power)

`*` binds tighter than `+`, so `2 + 3 * 4` is parsed as `2 + (3 * 4)` = 14, not `(2 + 3) * 4` = 20.

**Drill:** `17-precedence.asm` evaluates `2 + 3 * 4` and exits 14.

Represent precedence as integers (binding powers): `+` = 10, `*` = 20. Higher values bind tighter.

**Drill:** `22-stretch-pratt-stub.asm` defines constants `BP_ADD = 10` and `BP_MUL = 20`, exits 20. It does not parse—it's just the constant definitions.

### AST node structure

An **abstract syntax tree** node is three qwords:

```asm
struc ASTNode
    .kind: resq 1           ; node type (NUM, ADD, MUL, etc.)
    .left: resq 1           ; pointer to left child (or value for NUM)
    .right: resq 1          ; pointer to right child
endstruc
```

**Drill:** `18-ast-node.asm` represents `1 + 2 + 3` (actually parsed as `(1 + 2) + 3`) with three nodes. The root node's kind + left + right sum to 6 (arbitrary encoding for the drill), and the exit is 6.

Lesson 12 will show how to walk this tree and emit code.

## Worked example: is `20-queue-ring.asm` a true ring buffer?

**Task:** The file `20-queue-ring.asm` is labeled "Ring buffer cap 4". It enqueues 7, then 8, then dequeues. Does it wrap indices when the queue fills?

**Code:**

```asm
    mov rcx, [tail]
    mov qword [q + rcx*8], 7
    inc qword [tail]
    mov rcx, [tail]
    mov qword [q + rcx*8], 8
    inc qword [tail]
    mov rcx, [head]
    mov rdi, [q + rcx*8]    ; dequeue
    inc qword [head]
```

**Plausible wrong reading:**

*"This is a ring buffer of capacity 4. If I kept enqueueing, the fifth value would wrap around to slot 0 because `q` is only four qwords."*

**Why it's wrong:** Nothing in the code wraps. `tail` and `head` are only incremented with `inc qword`. There's no `and`, no modulo. After four more enqueues, `tail` would be 6, and `[q + 6*8]` is 48 bytes past the start of `q`, which writes into `head`, `tail`, or beyond. The drill is **correct for two enqueues and one dequeue** (it exits 7), but it's not a general ring buffer.

**The correct reading:** This drill demonstrates FIFO order (first-in, first-out) with monotonically increasing indices. To make it a true ring buffer, add after each increment:

```asm
and qword [tail], 3     ; wrap to [0..3]
```

Also track a count or reserve one empty slot to distinguish full from empty (both have `head == tail` otherwise).

## Distinctions worth keeping straight

| Confusion | Reality |
|-----------|---------|
| Null is a sentinel node | Null is the value 0 (no node); a sentinel would waste memory and complicate allocation |
| The lexeme length includes the null terminator | The length is the count of payload bytes; the null (if stored) is not counted |
| `test rsi, rsi` can come after `mov rax, [rsi]` | You must test **before** dereferencing; loading null segfaults |
| Arena alignment is `bump & 7` | Alignment is `(bump + 7) & ~7` (round up); `bump & 7` gives the misalignment |
| A stack is `rsp` | `rsp` is for procedure calls; your own stack is an array + index |
| The ring buffer in drill 20 wraps indices | It does not; it's correct only for a few operations before `tail` overflows |
| Precedence is textual order | Precedence is binding power; `*` binds tighter than `+` regardless of order |

## Check yourself

1. In `12-ll-sum.asm`, why is `test rsi, rsi` placed **before** `add rdi, [rsi]` and not after?

2. `07-stack-ds.asm` and `20-queue-ring.asm` both store two values into a qword array. Which index does each read from when popping/dequeuing, and why do the exits differ (2 vs 7)?

3. `14-arena-align.asm` computes `(1 + 7) & ~7` = 8. What does the same formula give for a bump of 8 (already aligned), and why is that the right answer?

4. `20-queue-ring.asm` enqueues 7 and 8 (tail becomes 2), then dequeues from head 0. If you enqueue two more values (9 and 10, tail becomes 4), then two more (11 and 12, tail becomes 6), what happens when you try to dequeue the fifth value (index 4)? Is it in the `q` array?

5. You parse `3 + 4 * 5`. If you evaluate left-to-right without precedence, you'd get `(3 + 4) * 5` = 35. With correct precedence (`*` binds tighter), what is the result?

## Key takeaways

- A lexer classifies bytes (digit, space) and extracts lexeme text with length; the null terminator (if stored) does not count toward the length.
- Linked lists use null (0) for the end marker, not a sentinel node; **always** test the pointer before dereferencing.
- An arena (bump allocator) returns the current cursor and adds the size; alignment up to 8 is `(bump + 7) & ~7`.
- Explicit stacks (LIFO) and queues (FIFO) use arrays and indices; the drill's queue does not wrap indices (it's correct for short sequences only).
- Operator precedence (binding power) determines parse order: `*` (20) binds tighter than `+` (10), so `2 + 3 * 4` = 14.
- An AST node is three qwords: kind, left child, right child (allocated in an arena, linked by pointers).

## Lookup

- Recursive-descent parsing: [Crafting Interpreters Chapter 6](https://craftinginterpreters.com/parsing-expressions.html)
- Pratt parsing (operator precedence): [Matklad: Simple but Powerful Pratt Parsing](https://matklad.github.io/2020/04/13/simple-but-powerful-pratt-parsing.html)
- Linked lists and memory safety: [Learn C The Hard Way, Exercise 32](https://learncodethehardway.org/c/ex32.html)
- Arena allocators: [Wikipedia: Region-based memory management](https://en.wikipedia.org/wiki/Region-based_memory_management)

## Exercises

Twenty-four drills under `exercises/`. Solutions mirror the names under `solutions/`. Build with:

```bash
nasm -f elf64 FILE.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
```

**Lexing:**
- `01-token-kind.asm` — define `TK_NUM = 1`, exit 1
- `02-lexer-digit.asm` — test `'7'`, exit 1 (is digit)
- `06-rd-parse-num.asm` — parse `'3'`, exit 3
- `08-from-scratch-token-buf.asm` — lexeme `'x'`, length 1
- `09-lexer-skip-ws.asm` — skip spaces in `"  7"`, exit 7
- `10-token-buffer.asm` — copy `"let"`, length 3, exit 3
- `15-rd-expect.asm` — expect `'('` in `"(1)"`, exit 1
- `23-stretch-error-span.asm` — error offset 4, exit 4

**Lists:**
- `03-list-node.asm` — one node, value 9, exit 9
- `11-ll-push-front.asm` — push 1, push 2, exit 2 (head)
- `12-ll-sum.asm` — sum `3 -> 4 -> 5`, exit 12
- `19-debug-null-deref-guard.asm` — fix: test before load, exit 0

**Memory and tables:**
- `04-arena-bump.asm` — two 16-byte allocations, `bump = 32`, exit 32
- `05-hash-mix.asm` — mix 5 → 45, exit 45
- `13-hashmap-put-get.asm` — store 42 at index 2, exit 42
- `14-arena-align.asm` — align 1 → 8, exit 8
- `21-intern-string.asm` — pointer equality, exit 1
- `24-from-scratch-vector-push.asm` — push 3 values, exit 3 (no realloc)

**Evaluation:**
- `07-stack-ds.asm` — push 1, 2, pop, exit 2 (LIFO)
- `16-expr-stack.asm` — push 2, 3, pop both, add, exit 5
- `17-precedence.asm` — `2 + 3 * 4`, exit 14
- `18-ast-node.asm` — `1 + 2 + 3` AST, sum fields, exit 6
- `20-queue-ring.asm` — enqueue 7, 8, dequeue, exit 7 (FIFO, no wrap)
- `22-stretch-pratt-stub.asm` — `BP_MUL = 20`, exit 20 (no parser)
