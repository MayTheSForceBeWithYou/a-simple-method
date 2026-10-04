# Lesson 14 — Graphics Path

## Learning objectives

1. Compute a byte offset as `y * pitch + x * bytes_per_pixel`.
2. Pack R, G, B into a dword and state the little-endian byte order it lands in memory.
3. Define pitch and align a row's byte count up to a power-of-two boundary.
4. Write a P6 PPM file with `open`, `write`, and `close` using only taught syscalls.
5. Clip a blit rectangle to the framebuffer with the half-open convention. These drills do not open `/dev/fb0`.

The picture is a `resb` buffer, and the file is the screen. Pitch — also called stride — is the byte distance from the start of one row to the start of the next. Input, `clock_gettime`, and a frame delay are lesson 15. Nothing here maps a device or links X11.

## Offset

`bytes_per_pixel` for RGBA8888 is 4, not 3. `19-debug-offset-bpp.asm` multiplies x by 3 in the exercise file. The fix is `x * 4`. For x = 2 that exits 8. Pitch for width 16 and 4 bytes per pixel is 64 (`08-from-scratch-stride.asm`). `y * pitch + x * 4` with y = 2, pitch = 40, x = 3 is 92. The exit is that offset masked with 255, which is still 92.

```asm
section .text
global _start
_start:
    mov rax, 2
    imul rax, 40            ; y * pitch
    mov rbx, 3
    imul rbx, 4             ; x * 4
    add rax, rbx
    and rax, 255
    mov rdi, rax            ; 92
    mov rax, 60
    syscall
```

That is `01-pixel-offset.asm`. A 320 by 200 buffer at 4 bytes is 256000 bytes. `24-from-scratch-fb-size.asm` shifts that right by 16 and exits 3. The full size does not fit in an exit status.

## Pitch

Pitch is the number of bytes from the start of one row to the start of the next. It is at least `width * bytes_per_pixel`, and it is often more: hardware pads rows so each one starts at an aligned address. For a power-of-two alignment `a`, the padded pitch is `(n + a - 1) & ~(a - 1)`. Width 5 at 4 bytes per pixel is 20 bytes; aligned to 16 that is 32. You round up to the next multiple, never down: "aligning 20 up to 16" is 32, not 16.

```asm
section .text
global _start
_start:
    mov rax, 5
    imul rax, 4             ; 20 = width * bytes_per_pixel
    add rax, 15             ; 35
    and rax, ~15            ; 32: round up to a multiple of 16
    mov rdi, rax
    mov rax, 60
    syscall
```

That is `16-pitch-bytes.asm`. The offset formula takes pitch, not width: `y * pitch + x * bytes_per_pixel`. When nothing is padded, pitch is just the width times the pixel size.

## Pack and plot

The pack in `02-pack-rgb.asm` is `(R<<16) | (G<<8) | B` with R = 1, G = 2, B = 3. The dword is `0x010203`. `al` is B, so the exit is 3: `al` is the low 8 bits of `rax`, and B sits in the low 8 bits of the pack.

x86-64 is little-endian. Storing that dword writes the low byte first, so memory holds `03 02 01 00` — B, G, R, then zero. The register reads `0x00RRGGBB`; the bytes in memory read B, G, R. Know both orders or every color comes out swapped.

```asm
section .text
global _start
_start:
    mov rax, 1
    shl rax, 16             ; R
    mov rbx, 2
    shl rbx, 8              ; G
    or rax, rbx
    or rax, 3               ; B in al
    movzx rdi, al           ; 3
    mov rax, 60
    syscall
```

`04-plot-stub.asm` plots through the offset math: the dword color lands at `y * pitch + x * 4`, and the exit is the low byte read back, 7. The name kept `-stub` from the outline pass; the file now implements the plot. `put_pixel` with pitch 8 and 1 byte per pixel: offset `y * 8 + x`. y = 1, x = 2 stores 9 at offset 10 and exits 9 (`10-put-pixel.asm`). `rep stosb` clears: 8 zeros exit 0 (`03-clear-buffer.asm`); four bytes of 5 exit 5 (`09-clear-color.asm`). A row of three 9s exits the middle byte, 9 (`07-row-fill.asm`).

## A real file: P6

A P6 PPM file is an ASCII header followed by raw bytes: `P6`, newline, `<width> <height>`, newline, `255`, newline, then 3 bytes per pixel in R, G, B order. No library and no device: `open`, `write`, `write`, `close`, all from lessons 00 and 08. The flags are `O_WRONLY|O_CREAT|O_TRUNC` = 577 and the mode is `0644` = 420 (lesson 08).

Emit R, G, B as three separate bytes in that order. Never dump the packed dword to the file: little-endian would write B first and the whole image would come out blue-shifted. That is why the byte-order section is not trivia.

```asm
section .data
    path db "out.ppm", 0
    hdr  db "P6", 10, "4 2", 10, "255", 10
    HLEN equ $ - hdr              ; 11
section .bss
    px resb 24                    ; 4*2 pixels, 3 bytes each
section .text
global _start
_start:
    xor rcx, rcx
.paint:
    cmp rcx, 24
    jge .painted
    mov byte [px+rcx], 255        ; R; G and B stay 0 (.bss)
    add rcx, 3
    jmp .paint
.painted:
    mov rax, 2                    ; open
    lea rdi, [path]
    mov rsi, 577                  ; O_WRONLY|O_CREAT|O_TRUNC
    mov rdx, 420                  ; 0644
    syscall
    mov rbx, rax                  ; fd; syscall preserves rbx
    mov rax, 1                    ; write
    mov rdi, rbx
    lea rsi, [hdr]
    mov rdx, HLEN                 ; 11
    syscall
    mov rax, 1                    ; write
    mov rdi, rbx                  ; rdi survived the write
    lea rsi, [px]
    mov rdx, 24
    syscall
    mov rax, 3                    ; close
    syscall
    xor rdi, rdi
    mov rax, 60
    syscall
```

`syscall` clobbers only `rcx` and `r11` (and `rax`, the return), so `rbx` keeps the fd and `rdi` keeps it across the writes. `23-stretch-ppm-header-len.asm` builds the 11-byte header for a 4 by 2 image (`"P6\n4 2\n255\n"`) and `write`s it to the open file. The exit is the byte count `write` returned: 11. Open any `out.ppm` you produce in an image viewer: that is the visible output the later lessons assume.

## Lines, rect, blit

A horizontal run writes consecutive bytes. Three 1s sum to 3 (`11-hline.asm`). A vertical run adds the pitch between pixels. Pitch 4, value 2, three pixels, sum 6 (`12-vline.asm`). A 2 by 2 rectangle on that same pitch occupies offsets 0, 1, 4, and 5. Four 3s sum to 12 (`13-rect-fill.asm`).

```asm
section .bss
    fb resb 16
section .text
global _start
_start:
    mov byte [fb], 3
    mov byte [fb+1], 3
    mov byte [fb+4], 3      ; next row, pitch 4
    mov byte [fb+5], 3
    xor rdi, rdi
    movzx rax, byte [fb]
    add rdi, rax
    movzx rax, byte [fb+1]
    add rdi, rax
    movzx rax, byte [fb+4]
    add rdi, rax
    movzx rax, byte [fb+5]
    add rdi, rax            ; 12
    mov rax, 60
    syscall
```

A blit copies bytes unless the source byte is 0. `0,5,0,5` leaves the zeros uncopied. `.bss` destination starts at 0, so the sum exits 10 (`14-blit-key.asm`). `05-blit-copy.asm` copies `1,2,3,4` with `rep movsb` and exits 10. `cld` still matters, from lesson 06.

## Clipping

A clip rectangle is half-open: x is inside exactly when `0 <= x < w`. Clipping x = -1 into `[0,10)` yields 0 (`15-clip-rect.asm`). An x of 5 against a width of 4 is outside and exits 1 (`06-clip-test.asm`). The upper test in `15-clip-rect.asm` uses 10, then stores 9, which is `width - 1`: 10 is the first outside value, 9 the last inside one. Lesson 17's hit test uses this same convention.

## Not in this lesson

`17-vsync-stub.asm` clears a byte and exits 0. It does not wait: waiting needs hardware this course never touches. `20-alpha-stub.asm` exits 7. There is no blend. `21-damage-rect.asm` exits 16. There is no union of rectangles. `22-stretch-bresenham-count.asm` exits 4, the count of pixels from x = 0 through x = 3 on a flat line. It does not step an error term. `18-double-buffer-index.asm` xors an index with 1 twice and exits 0: the flip is real, the wait is not.

## Exercises

24 drills under `exercises/`. Solutions mirror the names in `solutions/`. Build with `nasm -f elf64 FILE -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?`. Several drills kept `-stub` in their names from the outline pass; each now implements the operation its section teaches.

Addressing: `01-pixel-offset.asm` (exit 92), `02-pack-rgb.asm` (exit 3), `08-from-scratch-stride.asm`, `10-put-pixel.asm`, `16-pitch-bytes.asm` (exit 32, aligned pitch), `19-debug-offset-bpp.asm` (exit 8), `24-from-scratch-fb-size.asm` (exit 3). Fill and copy: `03-clear-buffer.asm`, `04-plot-stub.asm` (exit 7), `05-blit-copy.asm`, `07-row-fill.asm`, `09-clear-color.asm`, `11-hline.asm`, `12-vline.asm`, `13-rect-fill.asm`, `14-blit-key.asm`. Bounds: `06-clip-test.asm`, `15-clip-rect.asm` (half-open). Output: `23-stretch-ppm-header-len.asm` (exit 11). Beyond: `17-vsync-stub.asm`, `18-double-buffer-index.asm`, `20-alpha-stub.asm` (exit 7), `21-damage-rect.asm` (exit 16), `22-stretch-bresenham-count.asm` (exit 4, no stepper).
