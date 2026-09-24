# Lesson 01 — Addressing Modes & Data Sections

## Learning objectives

1. Choose `.data`, `.rodata`, `.bss`, and `.text` appropriately.
2. Use immediate, direct (label), register-indirect, base+displacement, and scaled-index addressing.
3. Distinguish `lea` (address arithmetic) from `mov` (memory load/store).
4. Declare `db`/`dw`/`dd`/`dq` and `resb`/`resq` correctly.
5. Build small programs that read/write static buffers.

## Sections in practice

```asm
section .rodata
    prompt db "n=", 0          ; often immutable strings

section .data
    count dq 0                 ; initialized mutable

section .bss
    buf resb 64                ; uninitialized; linker zeros at load

section .text
    global _start
```

`.bss` occupies no file bytes for the payload; size is in the ELF headers.

## Addressing modes (NASM)

| Form | Meaning | Example |
|------|---------|---------|
| imm | constant | `mov rax, 5` |
| reg | register | `mov rbx, rax` |
| `[label]` | absolute/direct | `mov rax, [count]` |
| `[reg]` | register indirect | `mov al, [rsi]` |
| `[reg+disp]` | base + disp | `mov eax, [rbx+8]` |
| `[reg+reg*scale]` | index | `mov al, [rsi+rcx]` |
| `[base+index*scale+disp]` | full SIB | `mov rax, [rbx+rcx*8+16]` |

Scale is 1, 2, 4, or 8.

### `lea` vs `mov`

```asm
lea rax, [rbx+rcx*4+8]   ; rax = address expression (no memory read)
mov rax, [rbx+rcx*4+8]   ; rax = qword loaded from that address
lea rdi, [rel msg]       ; RIP-relative address of msg (PIC-friendly)
```

For freestanding non-PIC early work, `mov rsi, msg` (symbol as imm) is fine with `ld`.

## Stores and sizes

```asm
mov byte  [buf], 65
mov word  [buf], 0x4241
mov dword [buf], 1
mov qword [buf], rax
```

NASM often needs an explicit size when the register doesn't imply it.

## Arrays

```asm
section .data
    arr dq 10, 20, 30, 40

; arr[i] for i in rcx:
lea rbx, [arr]
mov rax, [rbx+rcx*8]
```

## Exercises

28 drills: declarations, loads/stores, LEA, indexing, bug hunts, stretch buffer work.
