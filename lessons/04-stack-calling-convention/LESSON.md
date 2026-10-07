# Lesson 04 — Stack & System V AMD64 Calling Convention

The stack is a discipline, not just a data structure. This lesson teaches you how `rsp` tracks the stack pointer, how `push` and `pop` manipulate it, and why the stack is where function calls store return addresses, arguments, and local variables. You will learn the System V AMD64 ABI (Application Binary Interface) for Linux user-space function calls: which registers hold arguments, which registers the caller must save, which the callee must save, and why 16-byte alignment matters. By mastering this convention, you can write functions that call other functions, pass arguments correctly, and interoperate with C libraries.

## What this lesson asks of you

You must be able to use `push` and `pop` to save and restore registers, and understand that the stack grows downward (toward lower addresses) with `rsp` pointing to the top. You will implement leaf procedures (functions that call no one) and non-leaf procedures (functions that call others) with correct prologues and epilogues, allocating stack space for local variables and saved registers. You will pass the first six integer/pointer arguments in `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9`, and additional arguments on the stack. You will respect 16-byte stack alignment before every `call` to avoid crashes when calling standard library functions. Finally, you will distinguish caller-saved registers (which the caller must save before a call if it needs them afterward) from callee-saved registers (which the callee must save and restore if it uses them).

## The stack: growing downward from high memory

The **stack** is a region of memory used for temporary storage. On x86-64 Linux, the stack starts at a high address (near the top of the virtual address space) and **grows downward** toward lower addresses. The `rsp` register (stack pointer) always points to the **top** of the stack (the lowest address currently in use).

Pushing a value onto the stack moves `rsp` down (decrements it) and stores the value at the new location. Popping a value moves `rsp` up (increments it) and reads the value from the old location.

### `push` and `pop`

```asm
push rax              ; rsp -= 8; [rsp] = rax
pop rbx               ; rbx = [rsp]; rsp += 8
```

Concretely, `push rax` is equivalent to:
```asm
sub rsp, 8
mov [rsp], rax
```

And `pop rbx` is equivalent to:
```asm
mov rbx, [rsp]
add rsp, 8
```

The stack stores quadwords (8 bytes) at a time for 64-bit values. If you push `rax` (8 bytes), `rsp` decrements by 8. If you later pop into `rbx`, `rsp` increments by 8 and you recover the value.

The stack is LIFO (last in, first out). If you push A, then push B, you must pop B before you can pop A. Forgetting to balance pushes and pops corrupts `rsp` and causes crashes.

### `call` and `ret`

The `call` instruction pushes the address of the next instruction (the return address) onto the stack, then jumps to the target address. The `ret` instruction pops the return address from the stack and jumps to it. This is how function calls work:

```asm
call myfunc           ; push return address; jmp myfunc
; ... when myfunc finishes, it executes ret:
ret                   ; pop return address into rip
```

If you call a function and it does not `ret`, or if you corrupt `rsp` so `ret` pops the wrong value, your program jumps to a garbage address and crashes.

### The red zone (System V ABI detail)

The System V AMD64 ABI defines a **red zone**: 128 bytes below `rsp` (at addresses `rsp-1` through `rsp-128`) are reserved for the current function's use without explicitly adjusting `rsp`. Leaf functions can use this space for temporary values without a prologue or epilogue. However, if a signal arrives or if you call another function, the red zone may be clobbered. For learning, prefer explicit `sub rsp, N` to allocate stack space.

## System V AMD64 calling convention

When you call a function (or when a function you write is called), both sides must agree on how arguments are passed, which registers hold the return value, and which registers each side is responsible for preserving. The System V AMD64 ABI is the standard for Linux user-space function calls.

### Argument passing

| Argument | Location |
|----------|----------|
| 1st | `rdi` |
| 2nd | `rsi` |
| 3rd | `rdx` |
| 4th | `rcx` |
| 5th | `r8` |
| 6th | `r9` |
| 7th and beyond | Stack, pushed right-to-left (7th argument at `[rsp]` after the return address) |

For example, calling `foo(a, b, c, d, e, f, g)` looks like:

```asm
push g_value          ; 7th argument on stack
mov rdi, a_value      ; 1st argument
mov rsi, b_value      ; 2nd argument
mov rdx, c_value      ; 3rd argument
mov rcx, d_value      ; 4th argument
mov r8, e_value       ; 5th argument
mov r9, f_value       ; 6th argument
call foo
add rsp, 8            ; clean up stack argument after call
```

Note: syscalls use `r10` for the 4th argument (instead of `rcx`, which `syscall` clobbers), but **function calls** use `rcx`. Do not confuse the two conventions.

### Return value

The return value is placed in `rax`. For 128-bit returns (rare), the high 64 bits go in `rdx` and the low 64 bits in `rax`.

### Caller-saved vs callee-saved registers

Registers fall into two categories:

| Category | Registers | Responsibility |
|----------|-----------|----------------|
| **Caller-saved (volatile)** | `rax`, `rcx`, `rdx`, `rsi`, `rdi`, `r8`–`r11` | The **caller** must save these before calling another function if it needs their values afterward. The callee may clobber them freely. |
| **Callee-saved (nonvolatile)** | `rbx`, `rbp`, `r12`–`r15` | The **callee** must save these if it uses them, and restore them before returning. The caller can assume they are unchanged. |

For example, if you are writing a function and you need to use `rbx`, you must `push rbx` at the start and `pop rbx` before returning. If you use `rax` or `rcx`, you do not need to save them (they are caller-saved).

If you are writing code that calls a function, you must save `rdi`, `rsi`, `rdx`, `rcx`, `r8`–`r11` before the call if you need them afterward, because the called function may overwrite them.

### Stack alignment

Before executing a `call` instruction, `rsp` must be aligned to **16 bytes**. Specifically, `rsp ≡ 8 (mod 16)` at the point of `call`, because `call` pushes an 8-byte return address, making `rsp ≡ 0 (mod 16)` inside the called function. Many standard library functions (especially those using SSE/AVX) require 16-byte alignment and will crash or misbehave if the stack is misaligned.

If you have pushed an odd number of quadwords before a `call`, add or subtract 8 from `rsp` to restore alignment:

```asm
push rax              ; rsp is now misaligned (rsp ≡ 0 mod 16)
sub rsp, 8            ; restore alignment (rsp ≡ 8 mod 16)
call some_function
add rsp, 8            ; undo alignment adjustment
pop rax
```

## Procedure prologue and epilogue

A **prologue** sets up the stack frame (allocates space for locals, saves callee-saved registers). An **epilogue** tears it down (restores registers, deallocates space) and returns.

### With frame pointer (`rbp`)

```asm
myfunc:
    push rbp              ; save old frame pointer
    mov rbp, rsp          ; set up new frame pointer
    sub rsp, 32           ; allocate 32 bytes for locals

    ; function body (access locals as [rbp-N])

    mov rsp, rbp          ; deallocate locals
    pop rbp               ; restore old frame pointer
    ret
```

Using `rbp` as a frame pointer makes debugging easier (debuggers and stack unwinders can walk frames), but it is optional for optimization.

### Without frame pointer

```asm
myfunc:
    sub rsp, 32           ; allocate 32 bytes for locals

    ; function body (access locals as [rsp+N])

    add rsp, 32           ; deallocate locals
    ret
```

This saves two instructions but makes debugging harder. For hand-written assembly in this course, either style is fine.

### Leaf vs non-leaf functions

A **leaf function** is one that does not call any other functions. It does not need to save the return address or adjust the stack beyond its own locals (and can use the red zone if desired).

A **non-leaf function** calls other functions, so it must save any caller-saved registers it needs to preserve across the call, respect stack alignment, and ensure `rsp` is correct when it calls and when it returns.

## Worked example: a function that sums three numbers

Let's write a function `sum3(a, b, c)` that takes three 64-bit integers and returns their sum. Then we call it from `_start` and exit with the result.

```asm
section .text
    global _start

; long sum3(long a, long b, long c)
; Arguments: rdi=a, rsi=b, rdx=c
; Return: rax = a+b+c
sum3:
    mov rax, rdi          ; rax = a
    add rax, rsi          ; rax = a + b
    add rax, rdx          ; rax = a + b + c
    ret

_start:
    mov rdi, 10           ; first argument
    mov rsi, 20           ; second argument
    mov rdx, 30           ; third argument
    call sum3             ; rax = sum3(10, 20, 30) = 60

    mov rdi, rax          ; exit status = 60
    mov rax, 60           ; syscall number for exit
    syscall
```

Build and run:
```bash
nasm -f elf64 sum3.asm -o sum3.o
ld sum3.o -o sum3
./sum3
echo $?   # prints 60
```

Trace the reasoning. The function `sum3` expects its arguments in `rdi`, `rsi`, and `rdx` (the first three argument registers). It copies `rdi` to `rax`, adds `rsi`, then adds `rdx`, leaving the sum in `rax`. It does not push or pop anything because it does not use any callee-saved registers and does not call other functions (it is a leaf function). It simply returns with `ret`.

In `_start`, we load 10, 20, and 30 into `rdi`, `rsi`, and `rdx`, then `call sum3`. The `call` instruction pushes the return address onto the stack and jumps to `sum3`. When `sum3` executes `ret`, it pops the return address and returns to the instruction after `call sum3`. At that point, `rax` holds 60. We move it to `rdi` and exit with status 60.

### A plausible wrong reading (and why it fails)

A common mistake is to forget that `call` pushes the return address onto the stack, and to assume the stack is unchanged after a call. Suppose you push a value onto the stack before calling a function, intending to pop it afterward:

```asm
mov rax, 100
push rax              ; save 100 on stack
call myfunc
pop rax               ; expect to recover 100
```

If `myfunc` is a well-behaved function that balances its pushes and pops and returns with `ret`, this works — `ret` pops the return address, and the stack is back to where it was before `call`, so `pop rax` recovers 100. But if you forget that `call` itself pushes the return address, you might think the stack layout is different. For example, if `myfunc` tries to access `[rsp]` expecting it to be its first stack argument, it will instead see the return address (because the return address is at `[rsp]` immediately after `call` pushes it).

Another common mistake is to assume `rax` or `rcx` are preserved across a call. They are **caller-saved**, meaning the callee can clobber them. If you need the value of `rax` after a call, save it before the call:

```asm
mov rax, 42
push rax              ; save rax
call some_function
pop rcx               ; restore old rax into rcx (rax may be clobbered)
```

Or move it to a callee-saved register like `rbx` (after saving `rbx` yourself).

## Distinctions worth keeping straight

| Confusion | What actually separates them |
|-----------|------------------------------|
| `push` vs `sub rsp, 8; mov [rsp], reg` | They are equivalent, but `push` is a single instruction and easier to read. Use `push` for saving registers, `sub rsp` for allocating larger blocks. |
| `call` vs `jmp` | `call` pushes the return address before jumping; `jmp` does not. Use `call` for functions that return, `jmp` for tail calls or control flow. |
| `ret` vs `pop rip` | You cannot write `pop rip` directly — `ret` is the instruction that pops the return address into `rip` and jumps to it. |
| Caller-saved vs callee-saved | Caller-saved registers (`rax`, `rcx`, `rdx`, `rsi`, `rdi`, `r8`–`r11`) can be clobbered by any function you call; the caller must save them if needed. Callee-saved registers (`rbx`, `rbp`, `r12`–`r15`) must be preserved by the callee if it uses them. |
| Function call arg4 (`rcx`) vs syscall arg4 (`r10`) | Function calls use `rcx` for the 4th argument. Syscalls use `r10` because `syscall` clobbers `rcx`. Do not confuse the two. |
| Stack grows down vs array indexing grows up | The stack grows toward lower addresses (pushing decrements `rsp`), but arrays grow toward higher addresses (indexing increments). If you allocate an array on the stack, the first element is at the *highest* address (closest to the original `rsp`). |
| 16-byte alignment | Before `call`, `rsp` must be `≡ 8 (mod 16)` so that after `call` pushes the return address, `rsp ≡ 0 (mod 16)`. If you push an odd number of quadwords before a call, adjust `rsp` by 8 to restore alignment. |
| Prologue with vs without `rbp` | Using `rbp` as a frame pointer (push `rbp`, `mov rbp, rsp`) makes debugging easier but costs two instructions. Without it, you access locals relative to `rsp`, which changes as you push/pop. Both are valid. |

## Check yourself

1. After `push rax`, where does `rsp` point? If `rsp` was `0x7fffffffe000` before the push, what is `rsp` afterward?
2. You write a function that uses `rbx` and `r12`. Which of these must you save and restore, and in which category (caller-saved or callee-saved) do they fall?
3. Trace the stack pointer through this sequence: `call myfunc` (where `myfunc` does `push rbp`, then `ret` without popping `rbp`). What goes wrong?
4. You call a function with 8 arguments. The first 6 go in registers. Where do the 7th and 8th arguments go, and in what order?
5. Why does `rsp` need to be `≡ 8 (mod 16)` just before `call`, not `≡ 0 (mod 16)`? What happens during `call` that changes the alignment?

## Key takeaways

- The stack grows downward (toward lower addresses); `rsp` points to the top (lowest address in use); `push` decrements `rsp` and stores, `pop` loads and increments `rsp`.
- The System V AMD64 ABI passes the first six integer/pointer arguments in `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9`; additional arguments go on the stack, and the return value goes in `rax`.
- Caller-saved registers (`rax`, `rcx`, `rdx`, `rsi`, `rdi`, `r8`–`r11`) may be clobbered by any call; the caller must save them if needed. Callee-saved registers (`rbx`, `rbp`, `r12`–`r15`) must be preserved by the callee.
- Before every `call`, `rsp` must be 16-byte aligned (`rsp ≡ 8 mod 16`) so that after `call` pushes the return address, `rsp ≡ 0 mod 16` inside the callee — required for standard library functions.
- A prologue allocates stack space and saves registers; an epilogue deallocates and restores; both are required for correct function entry and exit.
- Syscalls use `r10` for arg4; function calls use `rcx` — do not confuse the two conventions.

## Lookup

- **System V AMD64 ABI:** [System V ABI AMD64 Architecture Processor Supplement (Draft 0.99.7)](https://gitlab.com/x86-psABIs/x86-64-ABI), Section 3.2 (function calling sequence)
- **Stack instructions:** Intel® 64 and IA-32 Architectures Software Developer's Manual, Volume 2, entries for `push`, `pop`, `call`, `ret`
- **Red zone:** System V ABI, Section 3.2.2 (128-byte region below `rsp`)
- **Alignment requirements:** System V ABI, Section 3.2.2 (stack alignment)

## Exercises

28 drills: push/pop, call/ret, ABI args, callee-saved, alignment, nesteds, bug hunts.
