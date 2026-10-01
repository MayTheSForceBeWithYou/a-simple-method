# Lesson 11 — Parsing & Data Structures

## Learning objectives

1. Classify a byte as a digit, skip spaces, and copy a lexeme (the raw text slice a token was cut from) with its length.
2. Walk a linked list only while the pointer is non-zero.
3. Bump an arena and align the cursor up to 8.
4. Push and pop an explicit stack, and dequeue a ring in FIFO order.
5. Evaluate `*` before `+` and store an AST node as three qwords.

Lesson 10 stored editor bytes. This lesson stores tokens, nodes, and a bump pointer. Emitting machine code or NASM text is lesson 12. These drills still exit through syscall 60. No libc allocator.

## Tokens

`TK_EOF` is 0 and `TK_NUM` is 1 (`01-token-kind.asm` exits 1). A digit is the inclusive range `'0'` through `'9'`. The byte `'7'` exits 1 (`02-lexer-digit.asm`). Spaces are the only whitespace `09-lexer-skip-ws.asm` skips. `"  7"` exits 7, which is the digit value, not the token kind. A one-character lexeme stores `'x'` and a length of 1 (`08-from-scratch-token-buf.asm`). Copying `"let"` puts the NUL in the buffer but not in the length, so the exit is 3 (`10-token-buffer.asm`).

Parsing one digit is `sub` from `'0'` (`06-rd-parse-num.asm` exits 3). Expecting `'('` at the first byte of `"(1)"` exits 1 (`15-rd-expect.asm`). That is the recursive-descent skeleton: small parse routines that consume the current input, with `expect` asserting the next character or failing. An error span in `23-stretch-error-span.asm` is an offset of 4. The length 1 is not the exit status.

## Lists and the null check

A node is two qwords: value, then next. A missing next is 0, not a sentinel node. One node whose value is 9 exits 9 (`03-list-node.asm`). Push-front writes the old head into the new node's next, then points `head` at the new node. Pushing 1 then 2 leaves the value 2 at the head (`11-ll-push-front.asm`).

Sum by walking `next` until the pointer is 0. `3 -> 4 -> 5` exits 12.

```asm
section .data
    n3 dq 5, 0
    n2 dq 4, n3
    n1 dq 3, n2
section .text
global _start
_start:
    lea rsi, [n1]
    xor rdi, rdi
.walk:
    test rsi, rsi
    jz .done
    add rdi, [rsi]
    mov rsi, [rsi+8]
    jmp .walk
.done:
    mov rax, 60             ; rdi == 12
    syscall
```

That is `12-ll-sum.asm`. `19-debug-null-deref-guard.asm` starts from a null head and loads `[rsi]` before the test, so the empty list never reaches the exit. The fix tests first and exits 0. Do not "fix" it by inventing a dummy node.

## Arena, vector, hash slot

A bump allocator is an integer cursor. Two 16-byte reservations leave it at 32, and `32 & 255` is still 32 (`04-arena-bump.asm`). Alignment up to 8 is `(bump + 7) & ~7`. From 1 that is 8 (`14-arena-align.asm`).

```asm
section .text
global _start
_start:
    mov rax, 1
    add rax, 7
    and rax, ~7
    mov rdi, rax            ; 8
    mov rax, 60
    syscall
```

There is no free-list in these drills. A vector with `cap` (capacity, the number of slots the buffer holds) 8 stores into `data[len]` and increments `len`. Three pushes exit 3 (`24-from-scratch-vector-push.asm`). The buffer is a static `resq 8`. The solution never grows `cap`.

A four-slot table puts 42 at index 2, which is `[slots+16]`, and exits 42 (`13-hashmap-put-get.asm`). There is no probe and no key compare. The mix `x ^ (x<<3)` on 5 is 45 in the low byte (`05-hash-mix.asm`). Interning (reusing one shared copy per distinct string) in `21-intern-string.asm` compares pointers, not bytes. The same address exits 1.

```asm
section .text
global _start
_start:
    mov rax, 5
    mov rbx, rax
    shl rbx, 3              ; 40
    xor rax, rbx            ; 45
    movzx rdi, al
    mov rax, 60
    syscall
```

## Stack, ring, precedence

An explicit stack is an array plus an index, not `rsp`. Push writes `stk[sp]` then increments. Pop decrements, then reads. Push 1, push 2, pop exits 2 (`07-stack-ds.asm`). The same stack adds: push 2, push 3, pop both, add, exit 5 (`16-expr-stack.asm`). A ring of capacity 4 enqueues at `tail` and dequeues at `head`. Enqueue 7 then 8, dequeue exits 7 (`20-queue-ring.asm`). The solution does not wrap with a mask. Do not dequeue from `tail`.

`*` binds tighter than `+`, so `2+3*4` is `3*4` first, then `+2`, and the exit is 14 (`17-precedence.asm`). Binding powers (numbers ranking how tightly each operator binds) in `22-stretch-pratt-stub.asm` are the constants 10 for `+` and 20 for `*`. The program exits 20. It does not parse. An AST node is three qwords: kind, left, right. `1+2+3` as those fields exits 6 (`18-ast-node.asm`). Emitting that node is the next lesson.

## Exercises

24 drills under `exercises/`. Solutions mirror the names in `solutions/`. Build with `nasm -f elf64 FILE -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?`.

Lex: `01-token-kind.asm`, `02-lexer-digit.asm`, `06-rd-parse-num.asm`, `08-from-scratch-token-buf.asm`, `09-lexer-skip-ws.asm`, `10-token-buffer.asm`, `15-rd-expect.asm`, `23-stretch-error-span.asm`. Lists: `03-list-node.asm`, `11-ll-push-front.asm`, `12-ll-sum.asm`, `19-debug-null-deref-guard.asm`. Memory and tables: `04-arena-bump.asm`, `05-hash-mix.asm` (exit 45), `13-hashmap-put-get.asm`, `14-arena-align.asm`, `21-intern-string.asm`, `24-from-scratch-vector-push.asm` (no realloc). Evaluation: `07-stack-ds.asm`, `16-expr-stack.asm`, `17-precedence.asm`, `18-ast-node.asm`, `20-queue-ring.asm`, `22-stretch-pratt-stub.asm` (exit 20, no parser).