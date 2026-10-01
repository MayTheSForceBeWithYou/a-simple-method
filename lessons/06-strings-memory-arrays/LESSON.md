# Lesson 06 — Strings, Memory, Arrays

## Learning objectives

1. Walk a NUL-terminated byte string and return its length or an index.
2. Copy and append the terminating NUL, and stop at an explicit byte bound.
3. Compare a counted buffer, and do not trust a prompt that disagrees with the bytes.
4. Copy a non-overlapping range with `rep movsb` only after `cld`.
5. Index an array of structures, a structure of arrays, and a row-major matrix.

Lesson 05 walked a string by recursion. This lesson is the loop, the terminator, and the stride. Bit tests, shifts, and masks are lesson 07.

## Length stops on NUL

A string here is bytes in `.data` or `.bss` ending in `0`. `strlen` returns the count of bytes before that `0`.

```asm
section .data
    s db "hello", 0
section .text
global _start
strlen:
    mov rax, rdi
.scan:
    cmp byte [rax], 0        ; do not count the NUL
    je .done
    inc rax
    jmp .scan
.done:
    sub rax, rdi
    ret
_start:
    lea rdi, [s]
    call strlen
    mov rdi, rax             ; 5
    mov rax, 60
    syscall
```

That is `01-strlen.asm`. The same scan returns an index in `11-strchr.asm` (`'l'` in `"hello"` is 2) and `08-from-scratch-strchr.asm` (`'c'` in `"abcd"` is 2). Both solutions return 255 on a miss, not −1. `20-count-char.asm` counts `'s'` in `"mississippi"` and exits 4. `23-stretch-utf8-ascii-validate.asm` is not a UTF-8 decoder: any byte with the high bit set is rejected, and `"OK\n"` exits 1.

## Copy the terminator

Store the byte, then test the value you stored. Stop after the NUL is written; otherwise the destination is not a string. `strcpy` of `"yo"` followed by `strlen` exits 2.

```asm
section .data
    src db "yo", 0
section .bss
    dst resb 8
section .text
global _start
strcpy:
.l:
    mov cl, [rsi]
    mov [rdi], cl            ; includes the NUL
    inc rsi
    inc rdi
    test cl, cl
    jnz .l
    ret
strlen:
    mov rax, rdi
.s:
    cmp byte [rax], 0
    je .d
    inc rax
    jmp .s
.d:
    sub rax, rdi
    ret
_start:
    lea rdi, [dst]
    lea rsi, [src]
    call strcpy
    lea rdi, [dst]
    call strlen
    mov rdi, rax             ; 2
    mov rax, 60
    syscall
```

`12-strcat-lite.asm` finds the NUL already in `"Hi"`, then copies `"!"`. The length exits 3. `17-bounded-strcpy.asm` copies at most 3 bytes of `"abcdef"` and plants a NUL at index 3, so `strlen` exits 3. The buffer has to be `n+1` bytes or that NUL is a store past the end.

`18-debug-off-by-one-copy.asm` stores one byte and returns. `"ok"` needs `o`, `k`, and `0` in the loop. After that fix, `strlen` exits 2. Reversing bytes in place is the two-pointer swap from the qword drill, and it must not swap the NUL (`24-from-scratch-reverse-string.asm`: `"asm"` leaves `'m'` = 109 in the first byte). `05-array-reverse.asm` swaps `dq 1,2,3,4` and exits the new first element, 4.

`22-stretch-itoa.asm` turns 123 into digits. The prompt also mentions `write` and exit 0. The solution does not call `write`. It returns the length. Exit status is 3.

## Counted compare

`memcmp` walks `rdx` bytes and returns 0 when they match (`03-memcmp.asm`). `strcmp` also stops at the first NUL. These solutions do not return a signed difference: a mismatch is 1 (`09-strcmp.asm`, `"abc"` against `"abd"`).

`10-strncmp.asm` says the first two bytes of `"axy"` and `"abz"` are equal and the exit is 0. Index 1 is `'x'` versus `'b'`. The solution exits 1. `14-memchr.asm` is the counted search: 7 in `{3,5,7,9}` is index 2, and a miss is 255.

## `rep movsb` is a forward counted copy

`movsb` copies one byte from `[rsi]` to `[rdi]`, then steps both pointers by 1. The step is backward if DF is set. `cld` clears DF. `rep` repeats that `rcx` times and leaves `rcx` at 0. `rsi` and `rdi` end past the range. The register roles match the System V `memcpy(dst, src)` order taught in lesson 04: `rdi` is the destination, `rsi` the source.

```asm
section .data
    src db 1, 2, 3, 4, 5
section .bss
    dst resb 5
section .text
global _start
_start:
    lea rsi, [src]
    lea rdi, [dst]
    mov rcx, 5
    cld
    rep movsb                ; rcx, rsi, rdi are dead
    xor rdi, rdi
    xor rcx, rcx
.sum:
    cmp rcx, 5
    jge .out
    movzx rax, byte [dst+rcx]
    add rdi, rax
    inc rcx
    jmp .sum
.out:                        ; rdi == 15
    mov rax, 60
    syscall
```

That checksum is `07-rep-movsb.asm`. `13-memcpy-overlap-safe.asm` is the same `cld` / `rep movsb` on bytes `1..8`, and the sum exits 36. The name says overlap. The code does not handle it. A forward `rep movsb` is wrong when the destination starts inside the source: later source bytes have already been overwritten. Use an explicit backward copy for that case, or keep the ranges disjoint. `rep stosb` fills `[rdi]` with `al` for `rcx` bytes. `04-memset.asm` does not use it; it stores `sil` in a loop, and four 7s sum to 28. `21-sparse-fill.asm` writes 1 only at even indices of an 8-byte buffer and exits 4.

## AoS and SoA

An array of structures keeps one record's fields adjacent. A structure of arrays keeps one field of every record adjacent. Summing both coordinates of `(1,2)` and `(3,4)` is 10 (`06-aos-sum.asm`). Summing `xs={1,2,3}` and `ys={4,5,6}` is 21 (`16-soa-sum.asm`).

| Layout | Address | Use it when |
|--------|---------|-------------|
| AoS, `dq x,y` per record | record `i` at `base+i*16`, `y` at `+8` | you touch one entity |
| SoA, separate `xs` and `ys` | `xs[i]` at `xs+i*8` | you touch one field across records |

`15-aos-scale.asm` doubles `{3,4}` and exits `x+y` = 14. The solution scales with `shl`. That shift is a forward-use; lesson 07 teaches shifts properly. The point here is the 16-byte stride, not the shift.

## Row-major index

Nine qwords, three columns: `index = row * cols + col`. Element `(1, 2)` of `1..9` is 6.

```asm
section .data
    m dq 1, 2, 3, 4, 5, 6, 7, 8, 9
section .text
global _start
_start:
    mov rax, 1               ; row
    imul rax, 3              ; cols
    add rax, 2               ; col
    mov rdi, [m+rax*8]       ; 6
    mov rax, 60
    syscall
```

`19-matrix-index.asm` is that formula with no bounds check. A `row` or `col` outside the allocation is not a matrix element.

## Exercises

24 drills under `exercises/`. Solutions mirror the names in `solutions/`. Build with `nasm -f elf64 FILE -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?`.

Strings: `01-strlen.asm`, `02-strcpy.asm`, `08-from-scratch-strchr.asm`, `09-strcmp.asm`, `10-strncmp.asm` (prompt says exit 0; solution exits 1), `11-strchr.asm`, `12-strcat-lite.asm`, `17-bounded-strcpy.asm`, `18-debug-off-by-one-copy.asm`, `20-count-char.asm`, `22-stretch-itoa.asm` (exit 3, no `write`), `23-stretch-utf8-ascii-validate.asm`, `24-from-scratch-reverse-string.asm`. Memory: `03-memcmp.asm`, `04-memset.asm`, `07-rep-movsb.asm`, `13-memcpy-overlap-safe.asm` (disjoint copy, checksum 36), `14-memchr.asm`. Layout: `05-array-reverse.asm`, `06-aos-sum.asm`, `15-aos-scale.asm`, `16-soa-sum.asm`, `19-matrix-index.asm`, `21-sparse-fill.asm`.