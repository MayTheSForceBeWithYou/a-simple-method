# 14 — Graphics: Framebuffer & PPM Output

Lesson 13 gave you fixed-point arithmetic for smooth motion. This lesson gives you **pixels**: a flat byte buffer (framebuffer), offset math to address any pixel, color packing, pitch (row stride with alignment), and P6 PPM file output so you can see your work. No device mapping, no X11, no libc—just syscalls 2 (`open`), 1 (`write`), and 3 (`close`) writing RGB bytes to a file your image viewer can open. By the end you'll see that graphics is not magic—it's pointer arithmetic, row-major layout, and knowing when to write three bytes instead of four.

## What this lesson asks of you

- Compute a pixel's byte offset as `y * pitch + x * bytes_per_pixel`.
- Pack red, green, blue into a 32-bit value (`(R<<16) | (G<<8) | B`), and state the little-endian byte order when stored to memory.
- Define **pitch** (also called stride): the byte distance from one row to the next, including padding for alignment.
- Write a P6 PPM file using only `open`, `write`, and `close` (no libc, no `mmap`).
- Clip a blit rectangle to the framebuffer using **half-open intervals** `[0, width)`.

## Why a framebuffer for the game milestone

Lesson 16's sprite blitting, lesson 17's tilemaps, and lesson 18's park simulation all draw into a framebuffer and write it to a file (or, in a stretch goal, push it to `/dev/fb0` or an X window). The drills in this lesson isolate each primitive—offset math, pitch alignment, color packing, P6 output—so you can verify them before integrating into a full rendering pipeline.

## Pixel offset and bytes per pixel

A framebuffer is a flat `resb` buffer. To address pixel `(x, y)`, compute:

```
offset = y * pitch + x * bytes_per_pixel
```

**Bytes per pixel:**
- **RGBA8888** (32-bit color with alpha): 4 bytes per pixel
- **RGB888** (24-bit color): 3 bytes per pixel
- **Indexed/palette** (8-bit): 1 byte per pixel

For these drills, assume **4 bytes per pixel** unless otherwise stated.

**Drill:** `01-pixel-offset.asm` computes `y=2, pitch=40, x=3` → `2*40 + 3*4` = 92, exits 92.

**Drill:** `19-debug-offset-bpp.asm` has a bug: it multiplies `x` by 3 instead of 4. The fix is `imul rbx, 4`. For `x=2`, the correct offset contribution is 8, and the drill exits 8.

### Buffer size

A 320×200 buffer at 4 bytes per pixel is `320 * 200 * 4` = 256000 bytes. That doesn't fit in an 8-bit exit status.

**Drill:** `24-from-scratch-fb-size.asm` computes 256000, shifts right by 16 (divide by 65536), exits 3 (the high bits).

## Color packing: register vs. memory byte order

To pack R, G, B into a 32-bit value:

```asm
mov rax, R
shl rax, 16             ; R in bits 16..23
mov rbx, G
shl rbx, 8              ; G in bits 8..15
or rax, rbx
or rax, B               ; B in bits 0..7
; rax = 0x00RRGGBB
```

**Example:** `R=1, G=2, B=3` → `0x00010203`.

**Drill:** `02-pack-rgb.asm` packs `(1, 2, 3)` into `0x010203`. The low byte (`al`) is B = 3, so the exit is 3.

### Little-endian byte order in memory

x86-64 is **little-endian**: the least significant byte is stored first. When you store the packed dword `0x00010203`, memory holds:

```
Address:  [0]  [1]  [2]  [3]
Value:    0x03 0x02 0x01 0x00
          B    G    R    (pad)
```

**Critical for file output:** P6 PPM expects RGB byte order (R first, then G, then B). If you dump the packed dword directly, you'd write B, G, R, 0—backwards and with an extra byte. Instead, extract and write R, G, B individually, or write them directly as three bytes.

## Pitch (stride) and alignment

**Pitch** is the byte distance from the start of one row to the start of the next. It's **at least** `width * bytes_per_pixel`, but hardware often pads rows to align each row start to a power-of-two boundary (e.g., 16, 32, or 64 bytes).

**Alignment formula:**

```
aligned = (unaligned + (align - 1)) & ~(align - 1)
```

This rounds `unaligned` **up** to the next multiple of `align`.

**Example:** Width 5, 4 bytes per pixel → 20 bytes. Align to 16:

```
(20 + 15) & ~15 = 35 & 0xFFFFFFF0 = 32
```

**Drill:** `16-pitch-bytes.asm` — the lesson text describes aligning 20 up to 16 → 32. However, the **solution as shipped** only computes `5 * 4 = 20` and exits **20** (no alignment). The header comment says "aligned up to 16: width=5 -> 20 align 32? 20; exit 20". This is a known mismatch: the lesson describes the alignment math, but the drill exits 20.

**Drill:** `08-from-scratch-stride.asm` computes `width=16, bpp=4` → pitch = 64, exits 64 (no padding needed because 64 is already aligned).

**In the offset formula, use pitch, not width:**

```
offset = y * pitch + x * bytes_per_pixel
```

## Plotting and filling

### Plot a single pixel

Store a color value at the computed offset:

```asm
; plot(x, y, color)
mov rax, y
imul rax, pitch
mov rbx, x
imul rbx, 4
add rax, rbx            ; offset
mov dword [fb + rax], color
```

**Drill:** `04-plot-stub.asm` plots through the offset math (the name "-stub" is historical; the drill now implements the plot). It stores a byte value and reads it back, exiting 7.

**Drill:** `10-put-pixel.asm` — `put_pixel(x=2, y=1)` with `pitch=8, bpp=1` → offset `1*8 + 2*1 = 10`, stores 9, exits 9.

### Clear the buffer

Fill with zeros using `rep stosb`:

```asm
lea rdi, [fb]
mov rcx, size_in_bytes
xor rax, rax
cld
rep stosb
```

**Drill:** `03-clear-buffer.asm` clears 8 bytes, sums them (0), exits 0.

**Drill:** `09-clear-color.asm` fills 4 bytes with 5, exits 5 (the value summed).

### Horizontal and vertical lines

**Horizontal line:** consecutive bytes.

**Drill:** `07-row-fill.asm` writes three 9s in a row, sums them, exits 9 (the value, not the sum 27—the drill exits the middle byte).

**Drill:** `11-hline.asm` writes three 1s, sums them, exits 3.

**Vertical line:** add pitch between pixels.

**Drill:** `12-vline.asm` — pitch 4, value 2, three pixels at offsets 0, 4, 8, sum 6, exits 6.

### Rectangle fill

Nested loops: for each row, fill a horizontal span.

**Drill:** `13-rect-fill.asm` fills a 2×2 rectangle on pitch 4: offsets 0, 1, 4, 5 with value 3, sum 12, exits 12.

## Blitting: copy with transparency

A **blit** (block transfer) copies a rectangular region from source to destination. A **color-key blit** skips pixels that match a transparent key color (commonly 0).

**Drill:** `05-blit-copy.asm` copies `1, 2, 3, 4` with `rep movsb`, sum 10, exits 10. (Remember `cld` from lesson 06.)

**Drill:** `14-blit-key.asm` copies `0, 5, 0, 5`, skipping zeros (transparent). The destination is `.bss` (starts zeroed), so after the blit it holds `0, 5, 0, 5` (the zeros were **not overwritten**—they were skipped). Sum 10, exits 10.

### Worked example: what `14-blit-key.asm` leaves in the destination

**Task:** Source bytes `0, 5, 0, 5` are copied into a `.bss` destination (initially all zeros), skipping source bytes that equal 0. What is in the destination after the blit, and why is the sum 10?

**Code (simplified):**

```asm
.copy_loop:
    cmp rcx, 4
    jge .done
    mov al, [src + rcx]
    test al, al
    jz .skip                ; if al == 0, skip the store
    mov [dst + rcx], al
.skip:
    inc rcx
    jmp .copy_loop
```

**Plausible wrong reading:**

*"Color key 0 means transparent, so the blit writes 0 into the destination for those pixels, and that is why the sum is 10."*

Under this reading, the destination after the blit is `0, 5, 0, 5` because the zeros were explicitly copied.

**Why it's wrong:** When `al == 0`, `test al, al` sets ZF, and `jz .skip` jumps **past the store**. **Nothing is written** to `dst[0]` or `dst[2]`. Those bytes remain 0 only because `.bss` starts zeroed. The sum of 10 cannot distinguish between "written 0" and "left untouched." That's why the lesson says "`.bss` destination starts at 0."

**The correct reading:** A keyed blit **leaves the destination's existing pixel untouched** wherever the source matches the key. If `dst` had held `9, 9, 9, 9` beforehand, the result would be `9, 5, 9, 5` (sum 28). That "background shows through" behavior is the purpose of the color key—it's how lesson 16's sprite blitting will overlay a character on a background without a black rectangle around it.

## Clipping: half-open intervals

A pixel `(x, y)` is inside the framebuffer when `0 <= x < width` and `0 <= y < height`. This is a **half-open interval**: the upper bound is exclusive.

**Drill:** `15-clip-rect.asm` starts with `x = -1`, clamps to `[0, 10)`:
1. `cmp rax, 0` / `jge .check_upper` fails for −1.
2. `xor rax, rax` → `x = 0`.
3. `cmp rax, 10` / `jl .done` passes (0 < 10).
4. Exit 0.

For an `x` of 10 or more, the upper clamp would store `width - 1` = 9 (the last inside column). 10 is the **first outside** value.

**Drill:** `06-clip-test.asm` tests `x = 5` against `width = 4`. Since 5 ≥ 4, the pixel is outside, exits 1 (out-of-bounds).

Lesson 17's UI hit testing uses this same half-open convention.

## P6 PPM file output

A **P6 PPM** file is a simple image format:

1. ASCII header: `"P6\n<width> <height>\n255\n"`
2. Binary pixel data: 3 bytes per pixel (R, G, B), row-major, no padding.

**No library needed:** Use syscalls `open` (2), `write` (1), `close` (3) from lesson 08.

**Header example (4×2 image):**

```
P6
4 2
255
```

This is 11 bytes: `"P6\n4 2\n255\n"`.

**Full P6 write sequence:**

```asm
section .data
    path: db "out.ppm", 0
    hdr: db "P6", 10, "4 2", 10, "255", 10
    HLEN equ $ - hdr        ; 11 bytes

section .bss
    px: resb 24             ; 4*2 pixels, 3 bytes each

section .text
global _start
_start:
    ; fill pixels with red (R=255, G=0, B=0)
    xor rcx, rcx
.paint:
    cmp rcx, 24
    jge .write_file
    mov byte [px + rcx], 255    ; R
    ; G and B are 0 (.bss)
    add rcx, 3
    jmp .paint

.write_file:
    ; open
    mov rax, 2
    lea rdi, [path]
    mov rsi, 577            ; O_WRONLY | O_CREAT | O_TRUNC
    mov rdx, 420            ; 0644
    syscall
    mov rbx, rax            ; save fd

    ; write header
    mov rax, 1
    mov rdi, rbx
    lea rsi, [hdr]
    mov rdx, HLEN
    syscall

    ; write pixels
    mov rax, 1
    mov rdi, rbx            ; fd survived (syscall only clobbers rcx, r11, rax)
    lea rsi, [px]
    mov rdx, 24
    syscall

    ; close
    mov rax, 3
    mov rdi, rbx            ; fd still in rbx, or rdi if it survived
    syscall

    xor rdi, rdi
    mov rax, 60
    syscall
```

**Drill:** `23-stretch-ppm-header-len.asm` — the lesson text describes building the 11-byte header and writing it, exiting 11 (the return from `write`). However, the **solution as shipped** defines only `h db "P6",10` (3 bytes), makes no syscalls, and exits **3**. This is a known mismatch: the drill is a placeholder constant, not a full P6 write.

**Critical:** Write R, G, B as three **separate bytes** per pixel, in that order. Do **not** dump the packed dword `0x00RRGGBB`—little-endian would write B, G, R, 0 (backwards, plus an extra byte per pixel).

## Stubs and placeholders

Several drills are stubs or simplified placeholders:

**Drill:** `17-vsync-stub.asm` clears a byte and exits 0. It does **not** wait for vertical sync (no hardware access).

**Drill:** `18-double-buffer-index.asm` XORs a buffer index with 1 twice, exits 0 (flipping between 0 and 1). The swap is real, but there's no vsync wait.

**Drill:** `20-alpha-stub.asm` exits 7 (a constant). There is no alpha blending.

**Drill:** `21-damage-rect.asm` exits 16 (a constant). There is no union of dirty rectangles.

**Drill:** `22-stretch-bresenham-count.asm` counts pixels from `x=0` to `x=3` on a flat line (4 pixels), exits 4. It does **not** step a Bresenham error term (that's a stretch goal for later).

## Distinctions worth keeping straight

| Confusion | Reality |
|-----------|---------|
| Pitch is the same as width | Pitch is `width * bytes_per_pixel`, possibly **plus padding** for alignment |
| The packed color `0x00RRGGBB` is stored in memory as R, G, B | Little-endian stores the **low byte first**: memory holds B, G, R, 0 |
| P6 PPM accepts 4 bytes per pixel | P6 expects exactly **3 bytes per pixel** (R, G, B), no alpha, no padding |
| Aligning 20 to 16 gives 16 | Alignment rounds **up**: `(20 + 15) & ~15` = 32 |
| Color-key blit writes 0 for transparent pixels | Keyed blit **skips** the store, leaving the destination pixel untouched |
| Clipping uses inclusive bounds `[0, width]` | Use **half-open** `[0, width)`: width is the first outside value |

## Check yourself

1. `15-clip-rect.asm` starts with `mov rax, -1`. Trace both compares (`cmp rax, 0` and `cmp rax, 10`) and say why the upper clamp stores 9, not 10.

2. The P6 listing writes the header with `mov rdx, HLEN`, where `HLEN equ $ - hdr`. What is HLEN, and why would `$ - path` be wrong?

3. A packed pixel `0x00010203` (R=1, G=2, B=3) is stored with one `mov dword`. List the four bytes in memory order, and say why that order is wrong for a P6 file.

4. You blit source `0, 7, 0, 7` (color key 0) into destination `3, 3, 3, 3`. What is in the destination after the blit?

5. A framebuffer is 100 pixels wide, 4 bytes per pixel, aligned to 128 bytes per row. What is the pitch?

## Key takeaways

- Pixel offset is `y * pitch + x * bytes_per_pixel`; pitch includes alignment padding.
- Packing `(R<<16) | (G<<8) | B` produces register value `0x00RRGGBB`; storing it writes memory as B, G, R, 0 (little-endian).
- P6 PPM files need exactly 3 bytes per pixel (R, G, B) with an ASCII header; write them separately, never dump the packed dword.
- Pitch alignment rounds up: `(unpadded + align - 1) & ~(align - 1)`.
- Color-key blitting skips stores where source equals the key, leaving the destination pixel unchanged.
- Clip with half-open intervals `[0, width)`: width is the first outside value.

## Lookup

- PPM format: [Netpbm PPM specification](http://netpbm.sourceforge.net/doc/ppm.html)
- Little-endian byte order: [Wikipedia: Endianness](https://en.wikipedia.org/wiki/Endianness)
- Pitch and stride: [Wikipedia: Stride of an array](https://en.wikipedia.org/wiki/Stride_of_an_array)
- Alignment: [Intel SDM Vol. 1, Section 4.1.1](https://www.intel.com/content/www/us/en/architecture-and-technology/64-ia-32-architectures-software-developer-vol-1-manual.html)

## Exercises

Twenty-four drills under `exercises/`. Solutions mirror the names under `solutions/`. Build with:

```bash
nasm -f elf64 FILE.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
```

**Addressing:**
- `01-pixel-offset.asm` — `y=2, pitch=40, x=3`, exit 92
- `02-pack-rgb.asm` — pack `(1, 2, 3)`, exit 3 (low byte B)
- `08-from-scratch-stride.asm` — `width=16, bpp=4`, pitch 64, exit 64
- `10-put-pixel.asm` — `put_pixel(2, 1)` on pitch 8, exit 9
- `16-pitch-bytes.asm` — **exits 20** (placeholder; lesson describes 32)
- `19-debug-offset-bpp.asm` — fix: `x * 4`, exit 8
- `24-from-scratch-fb-size.asm` — 320×200×4 >> 16, exit 3

**Fill and copy:**
- `03-clear-buffer.asm` — clear 8 bytes, exit 0
- `04-plot-stub.asm` — plot and read back, exit 7
- `05-blit-copy.asm` — copy `1,2,3,4`, sum 10, exit 10
- `07-row-fill.asm` — three 9s, exit 9 (middle byte)
- `09-clear-color.asm` — fill 4 bytes with 5, exit 5
- `11-hline.asm` — three 1s, sum 3, exit 3
- `12-vline.asm` — pitch 4, three 2s, sum 6, exit 6
- `13-rect-fill.asm` — 2×2 rect, four 3s, sum 12, exit 12
- `14-blit-key.asm` — keyed blit `0,5,0,5`, sum 10, exit 10

**Clipping:**
- `06-clip-test.asm` — `x=5, width=4`, out-of-bounds, exit 1
- `15-clip-rect.asm` — clamp −1 to [0, 10), exit 0

**P6 output:**
- `23-stretch-ppm-header-len.asm` — **exits 3** (placeholder; lesson describes 11)

**Stubs:**
- `17-vsync-stub.asm` — clear byte, exit 0 (no vsync)
- `18-double-buffer-index.asm` — XOR flip, exit 0
- `20-alpha-stub.asm` — exit 7 (no blend)
- `21-damage-rect.asm` — exit 16 (no rect union)
- `22-stretch-bresenham-count.asm` — flat line 4 pixels, exit 4 (no Bresenham)
