# Lesson 01 — Addressing Modes & Data Sections

Most computation happens in registers, but real programs read and write memory. This lesson teaches you how to declare data in the right section, how to address it with immediate values, labels, register indirection, and scaled indexing, and crucially how to distinguish between computing an address (`lea`) and loading the value stored at that address (`mov`). Once you master these addressing modes, you can implement arrays, buffers, and structured data layouts.

## What this lesson asks of you

You must be able to choose the correct ELF section (`.data`, `.rodata`, `.bss`, `.text`) for initialized mutable data, read-only constants, zero-filled buffers, and executable code. You will use all the major addressing modes: immediate (constants), register-to-register, direct memory access via labels, register-indirect `[reg]`, base+displacement `[reg+offset]`, and full scaled-index-base `[base+index*scale+disp]`. You will also recognize that `lea` performs address arithmetic without touching memory, while `mov` with brackets loads or stores actual data. By the end, you should be able to index into an array, read and write buffers of different sizes (`byte`, `word`, `dword`, `qword`), and debug common mistakes like wrong sizes or uninitialized reads.

## ELF sections: where your data lives

An ELF binary divides memory into **sections**, each with different permissions and purposes. The linker and loader use these sections to decide what gets mapped as read-only, read-write, or executable.

| Section | Purpose | Permission | File bytes? |
|---------|---------|------------|-------------|
| `.text` | Executable code (instructions) | Read + execute | Yes |
| `.data` | Initialized read-write data | Read + write | Yes |
| `.rodata` | Read-only initialized data (constants, strings) | Read only | Yes |
| `.bss` | Uninitialized or zero-filled data | Read + write | No (size in headers) |

Use `.rodata` for string literals you never modify, like prompts or error messages. Use `.data` for variables you initialize and later change, like counters or status flags. Use `.bss` for buffers and large arrays that start at zero — the loader zeros `.bss` at load time, so the object file does not waste space storing zeros. Use `.text` for your instructions.

Here's how they look in practice:

```asm
section .rodata
    prompt db "Enter value: ", 0    ; null-terminated string (immutable)

section .data
    counter dq 0                     ; 8-byte initialized counter

section .bss
    buffer resb 256                  ; 256-byte zero-filled buffer

section .text
    global _start
_start:
    ; code goes here
```

The difference between `db` (define bytes) and `resb` (reserve bytes) is that `db` stores actual byte values in the object file, while `resb` only reserves space without storing anything — the loader fills it with zeros.

## Addressing modes: how to name memory locations

An **addressing mode** specifies where the operand lives: in a register, at a fixed address, at an address computed from registers, or as an immediate constant. x86-64 supports a rich set of modes.

### Immediate and register modes

```asm
mov rax, 42          ; immediate: rax = 42 (constant)
mov rbx, rax         ; register: rbx = rax (copy register)
```

Nothing touches memory here.

### Direct (label) addressing

```asm
mov rax, [counter]   ; load 8 bytes from address 'counter' into rax
mov [counter], rax   ; store rax into memory at address 'counter'
```

The label `counter` is a symbol resolved by the linker to a fixed address. Brackets mean "load from" or "store to" that address. Without brackets, `mov rax, counter` would load the *address* of `counter` as an immediate, not its contents.

### Register-indirect addressing

```asm
mov al, [rsi]        ; load 1 byte from the address in rsi into al
mov [rdi], al        ; store al to the address in rdi
```

The address is whatever value `rsi` or `rdi` currently holds. This is how you walk through buffers: increment `rsi` after each read to move to the next byte.

### Base + displacement

```asm
mov eax, [rbx+8]     ; load 4 bytes from address (rbx + 8) into eax
mov qword [rsp-16], rax   ; store rax at address (rsp - 16)
```

Useful for accessing struct fields at fixed offsets: if `rbx` points to the start of a struct, `[rbx+8]` accesses the field at offset 8. Also used for stack locals relative to `rsp` or `rbp`.

### Scaled index (array indexing)

```asm
mov al, [rsi+rcx]           ; address = rsi + rcx (1-byte elements)
mov rax, [rbx+rcx*8]        ; address = rbx + rcx*8 (8-byte elements)
mov eax, [rbx+rcx*4+16]     ; address = rbx + rcx*4 + 16 (full SIB form)
```

This is the hardware support for array indexing. If `rbx` points to the start of an array of 8-byte elements and `rcx` holds the index, then `[rbx+rcx*8]` accesses `array[rcx]` directly. The **scale** can be 1, 2, 4, or 8, matching common element sizes. The full **SIB (Scale-Index-Base)** form combines a base register, an index register, a scale, and a constant displacement.

### Size specifiers

When the instruction does not imply the operand size, you must specify it explicitly:

```asm
mov byte  [buffer], 65       ; store 1 byte (ASCII 'A')
mov word  [buffer], 0x4241   ; store 2 bytes ('AB' in little-endian)
mov dword [buffer], 1        ; store 4 bytes
mov qword [buffer], rax      ; store 8 bytes
```

Without the size specifier, `mov [buffer], 65` is ambiguous — does it store a byte, a word, a doubleword, or a quadword? NASM will reject it. When the destination is a register, the size is clear from the register name (`al` = 1 byte, `eax` = 4 bytes, `rax` = 8 bytes).

## Load effective address: `lea` vs `mov`

The `lea` instruction computes an address expression and stores the **result address** in a register, without accessing memory. In contrast, `mov` with brackets accesses memory at that address.

```asm
lea rax, [rbx+rcx*4+8]      ; rax = rbx + rcx*4 + 8 (no memory access)
mov rax, [rbx+rcx*4+8]      ; rax = qword loaded from address (rbx + rcx*4 + 8)
```

Why is `lea` useful? It lets you do integer arithmetic in one instruction. For example, `lea rax, [rax+rax*2]` computes `rax = rax * 3` without a multiply instruction. It also computes the address of an array element without dereferencing it:

```asm
lea rdi, [buffer+rsi]       ; rdi = address of buffer[rsi]
```

Now `rdi` points to that element, but you have not loaded its value. You might pass this address to a function or use it later.

A common mistake is to write `lea rax, [rbx]` thinking it does something special — it simply copies `rbx` to `rax`, equivalent to `mov rax, rbx`, and is pointless. Use `lea` when you actually need address arithmetic.

Another distinction: `lea rdi, [rel msg]` computes the RIP-relative address of `msg`, which is needed for position-independent code (PIC). For freestanding programs linked with `ld`, `mov rsi, msg` (loading the symbol as an immediate) works fine and is simpler.

## Worked example: indexing into an array and summing elements

Let's write a program that declares an array of quadwords, iterates over it, and sums the values. Here is the source:

```asm
section .data
    arr dq 10, 20, 30, 40       ; array of four 64-bit values
    arr_len equ ($ - arr) / 8   ; number of elements (32 bytes / 8)

section .text
    global _start
_start:
    xor rax, rax                ; rax will hold the sum (start at 0)
    xor rcx, rcx                ; rcx is the loop index (start at 0)

.loop:
    cmp rcx, arr_len            ; compare index to length
    jge .done                   ; if index >= length, exit loop

    add rax, [arr+rcx*8]        ; add arr[rcx] to the sum
    inc rcx                     ; increment index
    jmp .loop                   ; repeat

.done:
    mov rdi, rax                ; exit status = sum (should be 100)
    mov rax, 60                 ; syscall number for exit
    syscall
```

Build and run:
```bash
nasm -f elf64 sum_array.asm -o sum_array.o
ld sum_array.o -o sum_array
./sum_array
echo $?   # should print 100
```

Trace the reasoning. In `.data`, we declare `arr` with four quadwords (10, 20, 30, 40). The expression `($ - arr) / 8` computes the number of elements: `$` is the current address after the array, so `$ - arr` is 32 bytes, and dividing by 8 (the size of each element) gives 4.

In the loop, `rcx` starts at 0. We compare `rcx` to `arr_len` and jump to `.done` if the index is out of bounds. Inside the loop body, `add rax, [arr+rcx*8]` uses **scaled-index addressing**: the address is `arr + rcx*8`, which is the address of `arr[rcx]`. The square brackets load the quadword at that address, and `add` adds it to `rax`. After incrementing `rcx`, we jump back to `.loop`. When `rcx` reaches 4, the comparison fails and we exit with the sum (100) as the exit status.

### A plausible wrong reading (and why it fails)

A common mistake is to write `add rax, [arr+rcx]` (scale 1 instead of scale 8). The intent is to access `arr[rcx]`, but without the correct scale, the address is only `arr + rcx` — if `rcx` is 0, this accesses `arr[0]` correctly, but if `rcx` is 1, it accesses the byte at offset 1, which is in the middle of the first quadword. The CPU will load 8 bytes starting from that misaligned address, reading parts of two elements and producing nonsense. On the second iteration, you get a garbage value (likely the high bytes of 10 and the low bytes of 20 concatenated), and the sum is wrong.

The lesson: the **scale** must match the element size. For an array of quadwords (8 bytes each), use `*8`. For an array of doublewords (4 bytes), use `*4`. For an array of words (2 bytes), use `*2`. For byte arrays, use `*1` or omit the scale (they are equivalent). Failing to match the scale is the most common indexing error.

## Distinctions worth keeping straight

| Confusion | What actually separates them |
|-----------|------------------------------|
| `.data` vs `.rodata` | Both hold initialized data, but `.data` is writable and `.rodata` is read-only. Attempting to write to `.rodata` causes a segmentation fault. Use `.rodata` for string literals and constants you never modify. |
| `.bss` vs `.data` | `.bss` is zero-filled at load and occupies no file bytes; `.data` stores actual bytes in the object file. Use `.bss` for large buffers that start at zero to save disk space. |
| `db` / `dw` / `dd` / `dq` vs `resb` / `resw` / `resd` / `resq` | The first group defines bytes with initial values; the second group only reserves space (for `.bss`). You cannot use `db` in `.bss`, and you would not use `resb` in `.data` unless you want uninitialized data (which the loader zeros anyway). |
| `mov rax, [label]` vs `mov rax, label` | The first loads the value stored at `label`; the second loads the *address* of `label` as an immediate. Forgetting the brackets is a common error. |
| `lea rax, [rbx+8]` vs `mov rax, [rbx+8]` | `lea` computes `rbx+8` and stores that address in `rax` without touching memory. `mov` loads the quadword at address `rbx+8` into `rax`. If `rbx` is uninitialized, `mov` will crash or read garbage; `lea` will just compute garbage+8, which may or may not cause a later error. |
| `mov [buffer], 42` vs `mov byte [buffer], 42` | The first is ambiguous and NASM rejects it. You must specify `byte`, `word`, `dword`, or `qword` when the size is not implied by a register operand. |
| Scale `*1` vs `*2` vs `*4` vs `*8` | The scale must match the element size in bytes. Arrays of quadwords need `*8`, arrays of doublewords need `*4`, arrays of words need `*2`, and byte arrays need `*1` (or no scale). Using the wrong scale produces misaligned access and wrong data. |

## Check yourself

1. You declare a string in `.rodata` and try to modify it at runtime with `mov byte [str], 65`. What happens, and why?
2. An array of doublewords (4-byte integers) starts at label `nums`. You want to load `nums[3]` into `eax`. Write the instruction using scaled-index addressing.
3. Explain the difference between `lea rsi, [buffer+10]` and `mov rsi, [buffer+10]`. What does each instruction put in `rsi`, and does either touch memory at address `buffer+10`?
4. You declare `counter resq 1` in `.bss` and assemble successfully, but the linker produces a large object file. Where did you go wrong?
5. Trace the value of `rax` after each iteration of the worked example above. What is `rax` after the first iteration (when `rcx=1`)? After the second? After the third? After the fourth, just before exiting the loop?

## Key takeaways

- ELF sections (`.text`, `.data`, `.rodata`, `.bss`) separate code, mutable data, immutable constants, and zero-filled buffers, each with different permissions and file representation.
- Brackets `[]` mean "load from" or "store to" memory at the computed address; without brackets, a label is an immediate address constant.
- Scaled-index addressing `[base+index*scale+disp]` is hardware support for array indexing — the scale must match the element size or you will access wrong offsets.
- `lea` computes an address expression and stores the result in a register without accessing memory; `mov` with brackets actually loads or stores data.
- Size specifiers (`byte`, `word`, `dword`, `qword`) are mandatory when the operand size is ambiguous — NASM will reject undersized or ambiguous stores.
- Writing to `.rodata` causes a runtime segmentation fault because the loader maps it read-only; attempting to execute `.data` or `.bss` will also fault.

## Lookup

- **NASM addressing syntax:** NASM manual, Chapter 3 (effective addresses, size specifiers)
- **ELF section attributes:** `man 5 elf`, `readelf -S <file>` (show section headers)
- **x86-64 addressing modes:** Intel® 64 and IA-32 Architectures Software Developer's Manual, Volume 1, Chapter 3.7 (operand addressing)
- **Data directives:** NASM manual, Section 3.2 (`db`, `dw`, `dd`, `dq`, `resb`, `resw`, `resd`, `resq`)

## Exercises

28 drills: declarations, loads/stores, LEA, indexing, bug hunts, stretch buffer work.
