# Lesson 00 — Tools, Registers, `mov`, First Syscalls

Assembly is not an opaque ritual. This lesson makes the toolchain cycle concrete: you type instructions in a text file, `nasm` translates them to machine code, `ld` packages the result as a Linux executable, and your CPU runs it. Once you understand how data moves between registers and how to request kernel services, you can write programs that do real work. By the end of this lesson, you will build executables from scratch, name every general-purpose register, and invoke Linux syscalls to print text and exit cleanly.

## What this lesson asks of you

You must be able to assemble and link a freestanding x86-64 ELF binary using `nasm -f elf64` and `ld`, write a program that uses the `write` (syscall 1) and `exit` (syscall 60) system calls to print text and terminate, and name the general-purpose registers and their size variants (64/32/16/8-bit). You will also distinguish between `mov` (data transfer) and `xor reg, reg` (the idiomatic zero), and interpret basic tool output from `objdump` and `readelf` to confirm your program matches your intent. These are not language features to memorize — they are the observable mechanics of how a Linux process starts, runs, and stops.

## Toolchain: from source text to runnable ELF

This course targets **Arch Linux on WSL** (`wsl -d arch` from Windows). Install the toolchain with `sudo pacman -Syu --needed nasm binutils make gdb`. Verify with `nasm -v` and `which ld make`.

The basic build cycle has two steps. First, `nasm -f elf64 program.asm -o program.o` assembles your source text (`program.asm`) into an object file (`program.o`) containing machine code and metadata. The `-f elf64` flag tells `nasm` to produce a 64-bit ELF (Executable and Linkable Format) object. Second, `ld program.o -o program` links the object file into an executable binary named `program`. The linker resolves symbols, lays out sections, and produces a file the Linux kernel can load. Run the program with `./program` and check its exit status with `echo $?`.

Repeat this cycle until it becomes automatic: edit `.asm`, assemble with `nasm`, link with `ld`, run, inspect. This is your feedback loop.

## How your program talks to Linux: the syscall interface

Your program is a sequence of instructions and data loaded into memory. The CPU fetches each instruction from memory, decodes it, executes it, and moves to the next. Instructions can read and write registers (small, fast storage inside the CPU) and memory (larger, slower, addressed storage). But the CPU alone cannot read files, print to the terminal, or allocate more memory — those operations require cooperation from the Linux kernel.

You request kernel services using the `syscall` instruction. On x86-64 Linux, you place a **syscall number** in `rax` to identify which service you want. For example, `write` is syscall 1 and `exit` is syscall 60. Arguments go into specific registers in this order: `rdi` (arg1), `rsi` (arg2), `rdx` (arg3), `r10` (arg4), `r8` (arg5), `r9` (arg6). Note `r10`, not `rcx` — `syscall` itself clobbers `rcx` and `r11` as part of its mechanism. After `syscall` completes, the return value (or an error code) is in `rax`.

For `write(fd, buf, count)`, you set `rax=1` (syscall number), `rdi` to the file descriptor (1 for stdout), `rsi` to the address of the buffer, and `rdx` to the byte count. For `exit(status)`, you set `rax=60` and `rdi` to the exit status. This is a calling convention, just like C function calls have conventions — follow it precisely and the kernel will do what you asked.

## General-purpose registers and their size variants

x86-64 provides sixteen general-purpose registers (GPRs). Each has multiple names depending on how many bits you want to access:

| 64-bit | 32-bit | 16-bit | 8-bit low | Notes |
|--------|--------|--------|-----------|-------|
| `rax` | `eax` | `ax` | `al` | Accumulator; syscall number and return value |
| `rbx` | `ebx` | `bx` | `bl` | General use; callee-saved in some conventions |
| `rcx` | `ecx` | `cx` | `cl` | Count register; clobbered by `syscall` |
| `rdx` | `edx` | `dx` | `dl` | Data register; syscall arg3 |
| `rsi` | `esi` | `si` | `sil` | Source index; syscall arg2 |
| `rdi` | `edi` | `di` | `dil` | Destination index; syscall arg1 |
| `rbp` | `ebp` | `bp` | `bpl` | Base pointer (stack frame, optional) |
| `rsp` | `esp` | `sp` | `spl` | Stack pointer (top of stack) |
| `r8`–`r15` | `r8d`–`r15d` | `r8w`–`r15w` | `r8b`–`r15b` | Additional registers introduced in 64-bit mode |

The size you choose matters. Writing to a 32-bit register name (`eax`) **zero-extends** the value into the full 64-bit register (`rax`), meaning the upper 32 bits are cleared. Writing to an 8-bit register name (`al`) leaves the upper 56 bits of `rax` **unchanged**. This is an architectural rule you must internalize: `mov eax, 42` sets `rax` to exactly 42 (clearing the high bits), but `mov al, 42` only modifies the lowest byte.

## Moving data with `mov` and the zero idiom

The `mov` instruction copies data from source to destination. The destination comes second (Intel/NASM syntax): `mov rax, 42` puts the immediate value 42 into `rax`, and `mov rdi, rax` copies the contents of `rax` into `rdi`. You cannot `mov` directly from memory to memory; one operand must be a register.

To zero a register, you could write `mov rax, 0`, which works but requires encoding the immediate value 0 in the instruction. The idiomatic way is `xor rax, rax` — exclusive-OR of a value with itself always produces zero, and this encoding is shorter and recognized by the CPU's dependency-tracking logic. You will see `xor edi, edi` (zeroing the 32-bit `edi`, which zero-extends to `rdi`) frequently in examples.

## ELF sections and data declarations

An assembly source file is divided into **sections**. The `.text` section holds executable code. The `.data` section holds initialized read-write data (like a string you want to modify). The `.rodata` section (read-only data) holds immutable constants. The `.bss` section reserves zero-filled space for uninitialized variables and occupies no file bytes — the loader zeros it at runtime.

You declare data with directives like `db` (define byte), `dw` (define word, 2 bytes), `dd` (define doubleword, 4 bytes), and `dq` (define quadword, 8 bytes). For example, `msg db "Hello", 10` declares a byte sequence containing the ASCII codes for "Hello" followed by byte 10 (newline). The special symbol `$` represents the current assembly address, so `msg_len equ $ - msg` defines `msg_len` as the distance in bytes from label `msg` to the current position — in other words, the length of `msg`.

## Entry point: `_start` and the linker

When you link with `ld`, the linker looks for a symbol called `_start` as the program's entry point (unlike C programs linked with `gcc`, which start at `main` and rely on the C runtime to set things up). You must declare `_start` as `global` so the linker can see it:

```asm
section .text
    global _start
_start:
    ; your code here
```

This is a **linker convention**, not a language keyword. If you forget `global _start`, the linker will complain about an undefined entry point.

## Worked example: printing "Hello" and exiting

Let's walk through a complete program that prints "Hello, asm\n" to stdout and exits with status 0. Here is the source:

```asm
section .data
    msg db "Hello, asm", 10
    msg_len equ $ - msg

section .text
    global _start
_start:
    mov rax, 1        ; syscall number for write
    mov rdi, 1        ; file descriptor 1 (stdout)
    mov rsi, msg      ; address of the message buffer
    mov rdx, msg_len  ; number of bytes to write
    syscall           ; invoke the kernel

    mov rax, 60       ; syscall number for exit
    xor rdi, rdi      ; exit status 0
    syscall           ; invoke the kernel
```

Step through the reasoning. In `.data`, we declare `msg` as a sequence of bytes: the ASCII codes for "Hello, asm" followed by byte 10 (newline). The assembler will place this data in the `.data` section of the ELF file. `msg_len equ $ - msg` computes the length by subtracting the address of `msg` from the current address `$` — after assembling the string, `$` points to the byte after the newline, so `msg_len` equals 11.

In `.text`, we declare `_start` as the entry point and mark it `global`. The first five instructions set up the arguments for the `write` syscall: syscall number 1 in `rax`, file descriptor 1 in `rdi` (stdout is always fd 1), the address of our message in `rsi`, and the byte count in `rdx`. Then `syscall` transfers control to the kernel, which writes 11 bytes from `msg` to stdout and returns. The return value in `rax` will be the number of bytes written (11) or a negative error code.

Next, we prepare the `exit` syscall: number 60 in `rax`, exit status 0 in `rdi`. We use `xor rdi, rdi` to zero `rdi` idiomatically. The final `syscall` terminates the process. The kernel will not return from this call — the process ends.

### A plausible wrong reading (and why it fails)

A common mistake is to put the byte count in `rsi` and the buffer address in `rdx`, swapping the second and third arguments. Someone familiar with C's `write(fd, buf, count)` might map the parameters by position and assume `rsi` holds the count because it is "argument 2." But the x86-64 Linux syscall ABI is **not** the same as the C function ABI. In C function calls, `rsi` is indeed the second argument — but `write` takes `buf` as its second parameter. When you invoke `write` as a syscall, the mapping is:
- `rdi` = fd (arg1)
- `rsi` = buf (arg2)
- `rdx` = count (arg3)

If you reverse `rsi` and `rdx`, the kernel interprets your count (11) as an address and tries to read 11 bytes starting from address 11, which is unmapped memory. The syscall returns an error code (likely -14, `EFAULT`), and no output appears. The lesson: syscall argument order is a fixed contract. Consult `man 2 write` and map parameters by **role** (fd, buffer, count), not by C function parameter number.

## Distinctions worth keeping straight

| Confusion | What actually separates them |
|-----------|------------------------------|
| `mov rax, 42` vs `mov eax, 42` | Both set the low bits to 42, but `mov eax, 42` also clears the upper 32 bits of `rax` (zero-extension). `mov rax, 42` is a 64-bit immediate move. |
| `mov al, 42` vs `mov eax, 42` | `mov al, 42` only changes the lowest byte of `rax`; the upper bits remain unchanged. `mov eax, 42` zero-extends and clears all upper bits. |
| `xor rdi, rdi` vs `mov rdi, 0` | Both set `rdi` to zero, but `xor rdi, rdi` produces a shorter encoding and is the idiomatic form. |
| `syscall` vs `int 0x80` | On x86-64 Linux, use `syscall` (fast system call). `int 0x80` is the 32-bit legacy mechanism and has different register assignments. |
| `_start` vs `main` | When linking with `ld`, the entry point is `_start` (no C runtime). When linking with `gcc`, the C runtime calls your `main`. Early lessons use `ld`, so use `_start`. |
| `nasm -f elf64` vs `nasm` alone | The `-f elf64` flag specifies the output format (64-bit ELF object). Without it, `nasm` defaults to a flat binary, which `ld` cannot link. |

## Check yourself

1. What happens to the upper 32 bits of `rax` when you execute `mov eax, 100`? What about when you execute `mov al, 100`?
2. Trace the register values after each instruction in the "Hello" example above. What is in `rax`, `rdi`, `rsi`, and `rdx` just before the first `syscall`? What is in `rax` after that `syscall` returns (assuming success)?
3. If you forget the `global _start` declaration, the program assembles without error. What happens when you try to link with `ld`, and why?
4. Why is `r10` used for the fourth syscall argument instead of `rcx`, even though `rcx` is the fourth register in the C function calling convention?
5. Rewrite the exit sequence to exit with status 42 instead of 0. Which register changes, and what value does it hold?

## Key takeaways

- Assembly source is text that `nasm` translates to machine code in an object file; `ld` then links that object into an ELF executable the kernel can load.
- On x86-64, every general-purpose register has 64-, 32-, 16-, and 8-bit views; writing to the 32-bit name zero-extends into the full 64 bits, but writing to the 8- or 16-bit view leaves upper bits unchanged.
- Linux syscalls on x86-64 put the syscall number in `rax` and arguments in `rdi`, `rsi`, `rdx`, `r10`, `r8`, `r9`; the `syscall` instruction invokes the kernel, which returns a value (or error) in `rax`.
- The linker expects a global symbol named `_start` as the entry point when you build a freestanding binary with `ld` — this is not a language feature but a linker convention.
- `xor reg, reg` is the idiomatic way to zero a register because it produces shorter code and is recognized by CPU optimizations.
- Syscall argument order is a fixed ABI contract; reversing parameters or using the wrong registers causes silent failures or errors.

## Lookup

- **Syscall numbers and signatures:** `man 2 syscalls`, `man 2 write`, `man 2 exit` (or see `/usr/include/asm/unistd_64.h`)
- **x86-64 instruction reference:** Intel® 64 and IA-32 Architectures Software Developer's Manual, Volume 2 (Instruction Set Reference)
- **ELF format:** `man 5 elf`, `readelf -h <file>`
- **Debugger commands:** `man gdb`; inside gdb: `help`, `info registers`, `stepi`, `x` (examine memory)
- **Tool inspection:** `objdump -d <file>` (disassemble), `strace <file>` (trace syscalls)

## Exercises

Work in `exercises/`. Build commands are in each file header. Solutions mirror names under `solutions/`.
