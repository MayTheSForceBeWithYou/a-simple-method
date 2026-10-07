# Lesson 06 — Strings, Memory, Arrays

Strings are not special types — they are byte sequences with conventions about terminators and copying. This lesson teaches you to implement `strlen`, `strcpy`, and `memcpy` from scratch, distinguish null-terminated strings from counted buffers, and index arrays of structures (AoS), structures of arrays (SoA), and row-major matrices. You will use `rep movsb` for bulk copying after ensuring the direction flag is clear, and understand the difference between operations that stop at NUL (string functions) and operations that stop at a count (memory functions).

## What this lesson asks of you

You must be able to write a loop that scans a null-terminated string (ending in byte 0) to compute its length or find a character, copy one string to another including the terminator, and compare two byte sequences for equality. You will implement counted operations (`memcpy`, `memcmp`, `memset`) that do not interpret terminators but instead process an explicit byte count. You will use `rep movsb` (repeat move string byte) to copy memory efficiently after `cld` clears the direction flag. Finally, you will index arrays of structures (where each record's fields are adjacent), structures of arrays (where each field spans all records), and two-dimensional row-major matrices using stride arithmetic.

## Null-terminated strings: walking until NUL

A **null-terminated string** is a sequence of bytes ending with 0. The length of the string is the number of bytes before the terminator, not including the terminator itself. To compute the length, start a pointer at the beginning, scan forward until you find byte 0, and return the distance traveled:

```asm
strlen:
    mov rax, rdi          ; rax = pointer (start at rdi)
.scan:
    cmp byte [rax], 0     ; check if current byte is NUL
    je .done              ; if so, stop
    inc rax               ; move to next byte
    jmp .scan             ; repeat
.done:
    sub rax, rdi          ; length = end pointer - start pointer
    ret
```

If the string is `"hello"` (5 ASCII bytes followed by 0), `strlen` returns 5. The terminator is not counted.

### Searching for a character: `strchr`

To find the first occurrence of a byte in a string, scan until you find it or hit the terminator:

```asm
strchr:
    ; rdi = string, rsi = character to find
    mov rax, rdi
.scan:
    cmp byte [rax], sil    ; does current byte match?
    je .found
    cmp byte [rax], 0      ; end of string?
    je .not_found
    inc rax
    jmp .scan
.found:
    sub rax, rdi           ; return index
    ret
.not_found:
    mov rax, -1            ; or use a sentinel like 255
    ret
```

This returns the **index** (offset from the start), not the pointer. If the character is not found, return a sentinel value (like -1 or 255).

## Copying strings: including the terminator

`strcpy(dst, src)` copies bytes from `src` to `dst` until it copies the NUL terminator. The critical rule: **copy the byte, then test it**. If you test before copying, the NUL is never written and the destination is not a valid string.

```asm
strcpy:
    ; rdi = dst, rsi = src
.loop:
    mov cl, [rsi]         ; load byte from source
    mov [rdi], cl         ; store byte to destination (including NUL)
    inc rsi
    inc rdi
    test cl, cl           ; was it NUL?
    jnz .loop             ; if not, continue
    ret
```

After this function returns, `dst` contains a copy of `src`, including the terminating 0.

### Bounded copy: stopping at a length

`strncpy(dst, src, n)` copies at most `n` bytes from `src` to `dst`. If `src` is shorter than `n`, copy its terminator and stop. If `src` is longer, copy `n` bytes and **add a terminator at dst[n]** to ensure `dst` is a valid string. This requires a buffer of size `n+1`.

## Counted operations: `memcpy`, `memcmp`, `memset`

**Memory functions** do not interpret null bytes as terminators — they process an explicit byte count.

### `memcpy(dst, src, count)`

Copy `count` bytes from `src` to `dst`, regardless of content:

```asm
memcpy:
    ; rdi = dst, rsi = src, rdx = count
    xor rcx, rcx
.loop:
    cmp rcx, rdx
    jge .done
    mov al, [rsi+rcx]
    mov [rdi+rcx], al
    inc rcx
    jmp .loop
.done:
    ret
```

If the source contains embedded null bytes, they are copied like any other byte.

### `memcmp(a, b, count)`

Compare `count` bytes of `a` and `b`, returning 0 if equal, nonzero if different:

```asm
memcmp:
    ; rdi = a, rsi = b, rdx = count
    xor rcx, rcx
.loop:
    cmp rcx, rdx
    jge .equal
    mov al, [rdi+rcx]
    cmp al, [rsi+rcx]
    jne .not_equal
    inc rcx
    jmp .loop
.equal:
    xor rax, rax          ; return 0
    ret
.not_equal:
    mov rax, 1            ; return nonzero
    ret
```

### `memset(dst, value, count)`

Fill `count` bytes of `dst` with `value`:

```asm
memset:
    ; rdi = dst, rsi = value (byte), rdx = count
    xor rcx, rcx
.loop:
    cmp rcx, rdx
    jge .done
    mov [rdi+rcx], sil
    inc rcx
    jmp .loop
.done:
    ret
```

## Bulk copy with `rep movsb`

The `movsb` instruction copies one byte from `[rsi]` to `[rdi]`, then adjusts both pointers. The direction of adjustment depends on the Direction Flag (DF): if DF=0, pointers increment (forward); if DF=1, pointers decrement (backward). Always clear DF with `cld` before using `rep movsb`.

The `rep` prefix repeats `movsb` `rcx` times:

```asm
    lea rsi, [src]
    lea rdi, [dst]
    mov rcx, count
    cld                   ; clear direction flag (forward)
    rep movsb             ; copy rcx bytes from [rsi] to [rdi]
```

After `rep movsb`, `rcx` is 0, and `rsi` and `rdi` point past the end of the copied range. This is faster than a loop for large blocks, but **only works correctly for non-overlapping ranges**. If `dst` starts inside `src` (forward overlap), later source bytes are overwritten before being read. For overlapping ranges, copy backward or use a different approach.

Similarly, `rep stosb` fills `rcx` bytes at `[rdi]` with the byte in `al`:

```asm
    lea rdi, [buffer]
    mov al, 0
    mov rcx, 256
    cld
    rep stosb             ; fill 256 bytes with 0
```

## Arrays of structures (AoS) vs structures of arrays (SoA)

When you have multiple records, each with several fields, you can lay them out in two ways.

### Array of structures (AoS)

Each record's fields are adjacent in memory:

```asm
section .data
    points dq 1, 2, 3, 4, 5, 6   ; three points: (1,2), (3,4), (5,6)
```

To access point `i`, compute `address = base + i * sizeof(point)`. For a structure with two quadwords (x, y), `sizeof(point) = 16`:

```asm
    mov rax, 1                   ; index of second point
    imul rax, 16                 ; stride = 16 bytes
    lea rbx, [points]
    mov rcx, [rbx+rax]           ; x of second point = 3
    mov rdx, [rbx+rax+8]         ; y of second point = 4
```

Use AoS when you usually process one entire record at a time.

### Structure of arrays (SoA)

Each field is an array spanning all records:

```asm
section .data
    xs dq 1, 3, 5
    ys dq 2, 4, 6
```

To access the `i`-th element, use `xs[i]` and `ys[i]`:

```asm
    mov rax, 1                   ; index
    mov rcx, [xs+rax*8]          ; xs[1] = 3
    mov rdx, [ys+rax*8]          ; ys[1] = 4
```

Use SoA when you often process one field across many records (e.g., sum all x-coordinates).

## Row-major matrix indexing

A two-dimensional matrix with `rows` rows and `cols` columns is stored in memory row-by-row. To access element `(row, col)`, use the formula:

```
index = row * cols + col
address = base + index * sizeof(element)
```

For a 3×3 matrix of quadwords:

```asm
section .data
    matrix dq 1, 2, 3, 4, 5, 6, 7, 8, 9   ; 3 rows, 3 columns

; access matrix[1][2] (second row, third column)
    mov rax, 1                   ; row
    imul rax, 3                  ; cols
    add rax, 2                   ; col
    mov rdi, [matrix+rax*8]      ; element at (1,2) = 6
```

Always multiply the row by the number of columns, then add the column. Reversing this (column * rows + row) accesses the transposed matrix.

## Worked example: copying a string with length check

Let's write a function that copies a string and returns the length of the copied string (not including the terminator):

```asm
section .data
    src db "hello", 0
section .bss
    dst resb 10

section .text
    global _start

strcpy_len:
    ; rdi = dst, rsi = src
    ; returns: rax = length
    xor rax, rax              ; length = 0
.loop:
    mov cl, [rsi+rax]         ; load byte
    mov [rdi+rax], cl         ; store byte (including NUL)
    test cl, cl               ; was it NUL?
    jz .done                  ; if so, stop (length is correct)
    inc rax                   ; increment length
    jmp .loop
.done:
    ret                       ; rax = length (not counting NUL)

_start:
    lea rdi, [dst]
    lea rsi, [src]
    call strcpy_len
    mov rdi, rax              ; exit with length (5)
    mov rax, 60
    syscall
```

Build and run:
```bash
nasm -f elf64 strcpy_len.asm -o strcpy_len.o
ld strcpy_len.o -o strcpy_len
./strcpy_len
echo $?   # prints 5
```

Trace the execution: `rax` starts at 0. We load `src[0]` ('h'), store it at `dst[0]`, test it (nonzero), increment `rax` to 1, and repeat. After copying 'h', 'e', 'l', 'l', 'o', we load `src[5]` (0), store it at `dst[5]`, test it (zero), and stop without incrementing `rax`. So `rax` ends at 5, the correct length.

### A plausible wrong reading (and why it fails)

A common mistake is to test the byte **before** storing it, intending to avoid copying the NUL:

```asm
.loop:
    mov cl, [rsi+rax]
    test cl, cl               ; check if NUL
    jz .done                  ; if so, stop
    mov [rdi+rax], cl         ; BUG: NUL is never written
    inc rax
    jmp .loop
```

With this code, the loop stops as soon as it sees the NUL, without storing it. The destination ends with `"hello"` but no terminator, so `strlen(dst)` will scan past the end of the buffer, reading garbage until it finds a zero somewhere in memory (or crashes). The lesson: always copy the byte **before** testing it when writing string functions.

## Distinctions worth keeping straight

| Confusion | What actually separates them |
|-----------|------------------------------|
| String functions (`strlen`, `strcpy`) vs memory functions (`memcpy`, `memcmp`) | String functions stop at the first NUL byte (0); memory functions process an explicit byte count and do not interpret NUL as special. |
| Copying before vs after testing NUL | When copying a string, store the byte **then** test it. Testing first leaves the terminator uncopied, and the destination is not a valid string. |
| `movsb` forward vs backward | `movsb` increments pointers if DF=0 (forward), decrements if DF=1 (backward). Always `cld` before `rep movsb` unless you explicitly want backward copy. |
| `rep movsb` on overlapping ranges | `rep movsb` forward works only if `dst` does not overlap `src` or if `dst` starts before `src`. If `dst` starts inside `src`, later source bytes are clobbered. Use backward copy or an explicit loop for overlaps. |
| AoS vs SoA | Array of structures (AoS) keeps one record's fields adjacent (stride = sizeof(record)); structure of arrays (SoA) keeps one field of all records adjacent (stride = sizeof(element)). Use AoS when processing whole records, SoA when processing one field across many records. |
| Row-major vs column-major | Row-major stores rows consecutively: `index = row * cols + col`. Column-major stores columns consecutively: `index = col * rows + row`. x86-64 C/C++ uses row-major by default. |
| `strlen` return vs `strcpy` terminator | `strlen` returns the count of bytes **before** the NUL (length 5 for "hello"). `strcpy` copies **including** the NUL, so the destination needs `strlen(src) + 1` bytes of space. |

## Check yourself

1. Write a loop that computes the length of a null-terminated string at `rdi`, returning the count in `rax`. What condition do you check, and when do you stop incrementing the pointer?
2. You call `strcpy(dst, "abc")`. How many bytes are written to `dst`, and what is the value of the last byte written?
3. Explain why `rep movsb` fails for `memcpy(dst, dst+4, 8)` (copying 8 bytes from `dst+4` to `dst` forward). What bytes end up being copied?
4. An array of 10 structures, each containing 3 quadwords, starts at `base`. Write the expression to access the second quadword of the 5th structure (index 4).
5. A 4×5 matrix (4 rows, 5 columns) of quadwords starts at `mat`. Write the formula to access element `mat[2][3]` (third row, fourth column).

## Key takeaways

- Null-terminated strings end with byte 0; string functions (`strlen`, `strcpy`, `strchr`) stop at NUL, while memory functions (`memcpy`, `memcmp`, `memset`) process an explicit byte count.
- When copying a string, store each byte **then** test it for NUL; testing first leaves the terminator uncopied and the destination invalid.
- `rep movsb` copies `rcx` bytes from `[rsi]` to `[rdi]` efficiently, but requires `cld` to clear the direction flag and only works for non-overlapping or backward-safe ranges.
- Array of structures (AoS) stores each record's fields adjacently (stride = record size); structure of arrays (SoA) stores each field as a separate array (stride = element size). Choose based on access pattern.
- Row-major matrices index as `row * cols + col`; always multiply row by column count first, then add column.
- `strlen` returns the length **not** counting the NUL; allocate `strlen(s) + 1` bytes to hold the string and its terminator.

## Lookup

- **String functions:** `man 3 strlen`, `man 3 strcpy`, `man 3 strcmp`, `man 3 strncpy`
- **Memory functions:** `man 3 memcpy`, `man 3 memcmp`, `man 3 memset`
- **String instructions:** Intel® 64 and IA-32 Architectures Software Developer's Manual, Volume 2, entries for `movsb`, `stosb`, `rep`, `cld`, `std`
- **Direction flag:** Volume 1, Chapter 3.4 (RFLAGS register, DF bit)
- **Array indexing:** Any systems programming textbook chapter on arrays and data layout

## Exercises

24 drills under `exercises/`. Solutions mirror names in `solutions/`. Build with:
```bash
nasm -f elf64 FILE -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
```

Strings: `01-strlen.asm`, `02-strcpy.asm`, `08-from-scratch-strchr.asm`, `09-strcmp.asm`, `10-strncmp.asm`, `11-strchr.asm`, `12-strcat-lite.asm`, `17-bounded-strcpy.asm`, `18-debug-off-by-one-copy.asm`, `20-count-char.asm`, `22-stretch-itoa.asm`, `23-stretch-utf8-ascii-validate.asm`, `24-from-scratch-reverse-string.asm`. Memory: `03-memcmp.asm`, `04-memset.asm`, `07-rep-movsb.asm`, `13-memcpy-overlap-safe.asm`, `14-memchr.asm`. Layout: `05-array-reverse.asm`, `06-aos-sum.asm`, `15-aos-scale.asm`, `16-soa-sum.asm`, `19-matrix-index.asm`, `21-sparse-fill.asm`.
