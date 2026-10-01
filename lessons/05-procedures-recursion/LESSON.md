# Lesson 05 — Procedures & Recursion

## Learning objectives

1. Allocate several locals in a non-leaf frame and address them from `rbp`.
2. Spill every callee-saved register you write.
3. Recurse by saving the live argument across `call` (rdi is caller-saved).
4. Mutual-recurse with `jmp` once the stack is already balanced.
5. Replace that tail shape with an accumulator loop. NASM will not do it for you.

Deepen call/ret: multiple locals, spilling, recursion depth, mutual recursion, and when a tail call is only a `jmp` you wrote yourself.

Lesson 04 already set the ABI and prologue. This lesson is the frame you keep getting wrong under a second call.

## Multi-local frames

`call` enters with `rsp ≡ 8 (mod 16)`. `push rbp` makes it `≡ 0`. Three qwords need 24 bytes; `sub rsp, 32` is the pad that keeps that alignment. Locals live at `[rbp-8]`, `[rbp-16]`, `[rbp-24]`. `leave` is `mov rsp, rbp` / `pop rbp`.

`sum_locals(10)` stores `n`, `n+1`, `n+2` and returns 33. Same shape as `exercises/01-locals-three.asm`.

```asm
section .text
global _start

sum_locals:
    push rbp
    mov rbp, rsp
    sub rsp, 32              ; 24 bytes of locals + 8 of alignment
    mov [rbp-8], rdi
    lea rax, [rdi+1]
    mov [rbp-16], rax
    lea rax, [rdi+2]
    mov [rbp-24], rax
    mov rax, [rbp-8]
    add rax, [rbp-16]
    add rax, [rbp-24]
    leave
    ret

_start:
    mov rdi, 10
    call sum_locals
    mov rdi, rax             ; 33
    mov rax, 60
    syscall
```

`sub rsp, 24` would assemble and return 33 here, and break the next `call`. Nested frames (`12-nested-frame.asm`) and a context pointer in `r12` (`17-closure-sim.asm`) use the same prologue.

## Callee-saved spills

You may write `rbx` and `r12`–`r15` only if you `push` them first and `pop` them before `ret`. `rbp` is already your frame. Caller-saved `rax`, `rcx`, `rdx`, `rsi`, `rdi`, `r8`–`r11` die across `call`.

```asm
section .text
global _start

wipe:
    push r12
    xor r12, r12
    pop r12
    ret

_start:
    mov r12, 42
    call wipe
    mov rdi, r12             ; 42, not 0
    mov rax, 60
    syscall
```

That is `05-save-r12.asm`. `09-fib-iter-proc.asm` uses `rbx` and does not save it. Exit status is still 55 because `_start` never reads `rbx` again. The procedure is still wrong.

## Recursion is a spill

`sum_to(n)` is `n + sum_to(n-1)`, and `0` at the base. `rdi` does not survive the recursive `call`. Push it, recurse, pop, then add.

```asm
section .text
global _start

sum_to:
    cmp rdi, 0
    jg .rec
    xor rax, rax
    ret
.rec:
    push rdi
    dec rdi
    call sum_to
    pop rdi
    add rax, rdi
    ret

_start:
    mov rdi, 5
    call sum_to
    mov rdi, rax             ; 15
    mov rax, 60
    syscall
```

Same spill in `08-from-scratch-rec-pow.asm` (`imul` after the pop), `10-gcd-proc.asm` (`div` writes `rax` and `rdx` before the recurse), `04-tree-sum-flat.asm` (index and partial sum, no `rbp`), and `24-from-scratch-rec-sum-array.asm`. `16-debug-missing-pop.asm` is factorial with the pop deleted: `fact(3)` must exit 6 once `pop rdi` sits before `imul`.

`06-ack-lite.asm` is Ackermann with two arguments. The `m=0` and `m>0,n=0` cases are tail calls: stack already balanced, so `jmp ack`. The general case is not: you must hold `m` while `ack(m, n-1)` runs.

## Mutual recursion

`is_even` / `is_odd` never need a new frame. After `dec rdi` the argument is the only live value, so `jmp` the other label. A `call` would push a return address you never use.

```asm
section .text
global _start

is_even:
    test rdi, rdi
    jnz .go
    mov rax, 1
    ret
.go:
    dec rdi
    jmp is_odd

is_odd:
    test rdi, rdi
    jnz .go
    xor rax, rax
    ret
.go:
    dec rdi
    jmp is_even

_start:
    mov rdi, 4
    call is_even
    mov rdi, rax             ; 1
    mov rax, 60
    syscall
```

`02-mutual-even-odd.asm` and `14-mutual-parity-count.asm` are this pattern. The CPU does not turn `call` into `jmp`. If anything is still on the stack (a saved `rdi`, a frame), `jmp` skips the matching `pop` and `ret` goes to the wrong address.

## Recursion to a loop

When the recursive result is only “add n, then the rest”, an accumulator does the same work and the stack stays put. `sum_acc(6)` exits 21, matching `sum_to(6)`.

```asm
section .text
global _start

sum_acc:
    xor rax, rax
.next:
    test rdi, rdi
    jz .done
    add rax, rdi
    dec rdi
    jmp .next
.done:
    ret

_start:
    mov rdi, 6
    call sum_acc
    mov rdi, rax             ; 21
    mov rax, 60
    syscall
```

That is `07-tail-ish-loop.asm`. `18-trampoline-depth.asm` is still real recursion (`bump` increments after the call). Do not rewrite it as this loop.

## Exercises

24 drills under `exercises/`. Solutions mirror the names in `solutions/`. Build line is in each file header.

Frames and spills: `01-locals-three.asm`, `05-save-r12.asm`, `12-nested-frame.asm`, `17-closure-sim.asm`. Recursion: `03-rec-sum.asm`, `04-tree-sum-flat.asm`, `06-ack-lite.asm`, `08-from-scratch-rec-pow.asm`, `10-gcd-proc.asm`, `15-rec-strlen.asm`, `16-debug-missing-pop.asm`, `21-rec-binary-digits.asm`, `23-stretch-memo-fib-slot.asm`, `24-from-scratch-rec-sum-array.asm`. Mutual `jmp`: `02-mutual-even-odd.asm`, `14-mutual-parity-count.asm`. Loop instead of a stack: `07-tail-ish-loop.asm`, `09-fib-iter-proc.asm`. Also `11-map-array-proc.asm`, `13-variadic-max.asm`, `19-compare-procs.asm`, `20-fold-list.asm`, `22-stretch-quicksort-partition.asm`.

## Build

```bash
nasm -f elf64 FILE -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
```

## Status

**FULL:** 24 exercises + solutions. This file is the prose for that set.
