# Lesson 00 — Tools, Registers, `mov`, First Syscalls

## Learning objectives

By the end of this lesson you will:

1. Assemble and link a freestanding x86-64 ELF with `nasm` + `ld`.
2. Name the general-purpose registers and their 64/32/16/8-bit views.
3. Use `mov` and `xor` idiomatically.
4. Invoke Linux syscalls `write` (1) and `exit` (60) via `syscall`.
5. Inspect exit status and basic ELF contents.

## Toolchain

Target: **Arch Linux WSL** (`wsl -d arch`).

```bash
sudo pacman -Syu --needed nasm binutils make gdb
nasm -v
which ld make
```

**Assemble + link** (repeat until reflexive):

```bash
nasm -f elf64 program.asm -o program.o
ld program.o -o program
./program
echo $?
```

Useful inspection:

```bash
objdump -d program
readelf -h program
strace ./program
```

## Mental model: CPU + memory + kernel

Your program is bytes in memory. The CPU fetches instructions, updates registers and memory.
To talk to the outside world you ask the **kernel** via `syscall`.

On Linux x86-64, syscall number goes in **`rax`**. Arguments use **`rdi, rsi, rdx, r10, r8, r9`**
(note: `r10`, not `rcx` — `syscall` clobbers `rcx`/`r11`). Return value in **`rax`**.

## General-purpose registers (GPRs)

| 64-bit | 32-bit | 16-bit | 8-bit low | Notes |
|--------|--------|--------|-----------|-------|
| rax | eax | ax | al | Accumulator; syscall # / return |
| rbx | ebx | bx | bl | Callee-saved (later) |
| rcx | ecx | cx | cl | Scratch; clobbered by `syscall` |
| rdx | edx | dx | dl | Arg3 |
| rsi | esi | si | sil | Arg2 |
| rdi | edi | di | dil | Arg1 |
| rbp | ebp | bp | bpl | Frame pointer (optional) |
| rsp | esp | sp | spl | Stack pointer |
| r8–r15 | r8d–r15d | r8w–r15w | r8b–r15b | Extra GPRs |

Writing `eax` zero-extends into `rax`. Writing `al` does **not** clear upper bits of `rax`.

## Instruction: `mov`

```asm
mov rax, 42
mov eax, 42          ; zero-extends to rax
mov rdi, rax
xor eax, eax         ; preferred zeroing
```

## First program: exit 0

```asm
section .text
    global _start
_start:
    mov rax, 60
    xor rdi, rdi
    syscall
```

## Hello via `write`

```asm
section .data
    msg db "Hello, asm", 10
    msg_len equ $ - msg

section .text
    global _start
_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, msg_len
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall
```

`$` is current assembly address; `equ` defines a constant; `db` emits bytes.

## Sections (preview)

| Section | Purpose |
|---------|---------|
| `.text` | Code |
| `.data` | Initialized r/w data |
| `.rodata` | Read-only data |
| `.bss` | Zero-filled r/w |

## Labels and `_start`

`ld` uses `_start` as ELF entry (not `main`). `global _start` exports the symbol.

## Common footguns

1. Forgetting `syscall`.
2. Overwriting `rax` before `syscall`.
3. Wrong length in `rdx`.
4. Using `gcc` without understanding CRT — early lessons use `ld`.

## Debugging

```bash
gdb ./program
(gdb) break _start
(gdb) run
(gdb) info registers
(gdb) stepi
```

## Exercises

Work in `exercises/`. Build commands are in each file header. Solutions mirror names under `solutions/`.
