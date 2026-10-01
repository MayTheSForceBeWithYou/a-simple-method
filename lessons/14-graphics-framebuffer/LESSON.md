# Lesson 14 — Graphics Path

## Learning objectives

1. Compute a byte offset as `y * stride + x * bytes_per_pixel`.
2. Pack R, G, and B with shifts, and know which channel lands in `al`.
3. Clear, plot, and fill rows, columns, and a rectangle in a byte buffer.
4. Skip a color key on blit, and reject an x outside the width.
5. Keep pitch, flip, and framebuffer size as integers. These drills do not open `/dev/fb0`.

The picture is a `resb` buffer. Stride is the byte width of one row. Input, `clock_gettime`, and a frame delay are lesson 15. Nothing here maps a device or links X11.

## Offset

`bytes_per_pixel` for RGBA8888 is 4, not 3. `19-debug-offset-bpp.asm` multiplies x by 3 in the exercise file. The fix is `x * 4`. For x = 2 that exits 8. Stride for width 16 and 4 bytes per pixel is 64 (`08-from-scratch-stride.asm`). Width 5 times 4 exits 20 (`16-pitch-bytes.asm`). The prompt mentions aligning that 20 up to 16. The solution does not align.

`y * stride + x * 4` with y = 2, stride = 40, x = 3 is 92. The exit is that offset masked with 255, which is still 92.

```asm
section .text
global _start
_start:
    mov rax, 2
    imul rax, 40            ; y * stride
    mov rbx, 3
    imul rbx, 4             ; x * 4
    add rax, rbx
    and rax, 255
    mov rdi, rax            ; 92
    mov rax, 60
    syscall
```

That is `01-pixel-offset.asm`. A 320 by 200 buffer at 4 bytes is 256000 bytes. `24-from-scratch-fb-size.asm` shifts that right by 16 and exits 3. The full size does not fit in an exit status.

## Pack and plot

The pack in `02-pack-rgb.asm` is `(R<<16) | (G<<8) | B` with R = 1, G = 2, B = 3. The dword is `0x010203`. `al` is B, so the exit is 3. That is not the little-endian memory order from lesson 13's stub, which never packed anything.

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

`04-plot-stub.asm` stores 7 at index 0 and exits 7. `put_pixel` with stride 8 and 1 byte per pixel: offset `y * 8 + x`. y = 1, x = 2 stores 9 at offset 10 and exits 9 (`10-put-pixel.asm`). `rep stosb` clears: 8 zeros exit 0 (`03-clear-buffer.asm`); four bytes of 5 exit 5 (`09-clear-color.asm`). A row of three 9s exits the middle byte, 9 (`07-row-fill.asm`).

## Lines, rect, blit

A horizontal run writes consecutive bytes. Three 1s sum to 3 (`11-hline.asm`). A vertical run adds the stride between pixels. Stride 4, value 2, three pixels, sum 6 (`12-vline.asm`). A 2 by 2 rectangle on that same stride occupies offsets 0, 1, 4, and 5. Four 3s sum to 12 (`13-rect-fill.asm`).

```asm
section .bss
    fb resb 16
section .text
global _start
_start:
    mov byte [fb], 3
    mov byte [fb+1], 3
    mov byte [fb+4], 3      ; next row, stride 4
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

A blit copies bytes unless the source byte is 0. `0,5,0,5` leaves the zeros uncopied. `.bss` destination starts at 0, so the sum exits 10 (`14-blit-key.asm`). `05-blit-copy.asm` copies `1,2,3,4` with `rep movsb` and exits 10. `cld` still matters, from lesson 06. An x of 5 against a width of 4 is outside and exits 1 (`06-clip-test.asm`). Clipping x = -1 into `[0,10)` yields 0 (`15-clip-rect.asm`). The upper test in that file uses 10, then stores 9, which is `width - 1`.

## What is not a device

`17-vsync-stub.asm` clears a byte and exits 0. It does not wait. `18-double-buffer-index.asm` xors an index with 1 twice and exits 0. `20-alpha-stub.asm` exits 7. There is no blend. `21-damage-rect.asm` exits 16. There is no union of rectangles. `22-stretch-bresenham-count.asm` exits 4, the count of pixels from x = 0 through x = 3 on a flat line. It does not step an error term. `23-stretch-ppm-header-len.asm` stores `"P6\n"` and exits the immediate 3. It does not write a file. Opening `/dev/fb0` would be `open` from lesson 08. It is not this set.

## Exercises

24 drills under `exercises/`. Solutions mirror the names in `solutions/`. Build with `nasm -f elf64 FILE -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?`.

Addressing: `01-pixel-offset.asm` (exit 92), `02-pack-rgb.asm` (exit 3), `08-from-scratch-stride.asm`, `10-put-pixel.asm`, `16-pitch-bytes.asm` (exit 20, no align), `19-debug-offset-bpp.asm` (exit 8), `24-from-scratch-fb-size.asm` (exit 3). Fill and copy: `03-clear-buffer.asm`, `04-plot-stub.asm`, `05-blit-copy.asm`, `07-row-fill.asm`, `09-clear-color.asm`, `11-hline.asm`, `12-vline.asm`, `13-rect-fill.asm`, `14-blit-key.asm`. Bounds and flags: `06-clip-test.asm`, `15-clip-rect.asm`, `17-vsync-stub.asm`, `18-double-buffer-index.asm`, `20-alpha-stub.asm` (exit 7), `21-damage-rect.asm` (exit 16), `22-stretch-bresenham-count.asm` (exit 4, no stepper), `23-stretch-ppm-header-len.asm`.