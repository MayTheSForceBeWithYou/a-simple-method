# Lesson 04 — Stack & System V AMD64 Calling Convention

## Learning objectives

1. Use `push`/`pop` and reason about `rsp`.
2. State the System V AMD64 user-space calling convention.
3. Write leaf and non-leaf procedures with correct prologue/epilogue.
4. Pass args in `rdi,rsi,rdx,rcx,r8,r9` and via stack when needed.
5. Respect 16-byte stack alignment before `call` (and before libc later).
6. Know caller-saved vs callee-saved registers.

## The stack

Stack grows **down**. `push rax` is roughly:

```asm
sub rsp, 8
mov [rsp], rax
```

`pop` reverses. `call` pushes return address; `ret` pops into `rip`.

### Red zone (System V)

128 bytes below `rsp` are reserved for leaf functions without adjusting `rsp` — **do not** rely on this when signals/`call` intervene. Prefer explicit allocation for learning.

## System V AMD64 ABI (user space)

| Role | Registers |
|------|-----------|
| Args 1–6 | rdi, rsi, rdx, rcx, r8, r9 |
| Args 7+ | stack (right-to-left push order; 7th at `[rsp+8]` after call) |
| Return | rax (rdx for 128-bit) |
| Caller-saved (volatile) | rax, rcx, rdx, rsi, rdi, r8–r11 |
| Callee-saved | rbx, rbp, r12–r15 |
| Stack alignment | `rsp ≡ 8 (mod 16)` at `call` entry → ≡ 0 (mod 16) before call |

Syscall arg4 uses **r10**, not rcx — different from function calls.

## Prologue / epilogue

```asm
myfunc:
    push rbp
    mov rbp, rsp
    sub rsp, 32          ; locals
    ; ...
    mov rsp, rbp
    pop rbp
    ret
```

Or without frame pointer: `sub rsp, N` / `add rsp, N` / `ret`.

## Example: add two longs

```asm
; long add(long a, long b) -> a+b
add_fn:
    mov rax, rdi
    add rax, rsi
    ret

_start:
    mov rdi, 20
    mov rsi, 22
    call add_fn
    mov rdi, rax
    mov rax, 60
    syscall
```

## Exercises

28 drills: push/pop, call/ret, ABI args, callee-saved, alignment, nesteds, bug hunts.
