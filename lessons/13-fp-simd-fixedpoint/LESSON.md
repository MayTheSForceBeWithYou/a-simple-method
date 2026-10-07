# 13 — Fixed-point Arithmetic

Lesson 12's compiler operated on integers. Real programs—especially games and graphics—need fractional numbers: positions, velocities, colors as 0.0–1.0, interpolation weights. This lesson shows you how to represent fractions as **fixed-point** integers: a convention where the low *n* bits are the fractional part, and the remaining bits are the integer part. No floating-point hardware, no SSE—just shifts, multiplies, and divides on integer registers. By the end you'll see that Q16.16 (16 integer bits, 16 fraction bits) can represent smooth motion, linear interpolation, dot products, and clamping with deterministic, fast integer operations.

## What this lesson asks of you

- Encode an integer *n* in Q16.16 by shifting left 16 bits (`n << 16`); encode 0.5 as `1 << 15`.
- Add two fixed-point values without shifting; multiply them and shift right by 16 to restore the scale.
- Divide two fixed-point values by shifting the dividend left by 16 (widening it to 64 bits with `cqo`), performing `idiv`, then shifting the quotient right by 16 to convert to integer if needed.
- Clamp a value to a range, wrap angles (modulo 360), and compute dot products—all in integer arithmetic.
- Recognize that the "SSE" drills in this lesson are scalar stubs (they do **not** execute `addss`, `movss`, or SIMD instructions).

## Why fixed-point for the game milestone

Lesson 16's sprite blitting and lesson 17's pathfinding need sub-pixel positions, smooth scrolling, and interpolation. Fixed-point gives you:

- **Determinism:** No floating-point rounding surprises across CPUs or runs.
- **Speed:** Integer ALU ops are fast; no mode switch to the FPU or SSE.
- **Simplicity:** No NaN, no infinity, no denormals—just integers with a convention.

Modern games often use floats (lesson 14 will mention them), but fixed-point remains valuable for retro-style projects, embedded systems, and understanding numeric representation.

## Q-format: integer and fractional bits

A **Q-format** number is an integer where the low *n* bits represent the fractional part. The notation **Qm.n** means *m* integer bits and *n* fraction bits.

**Q16.16:** 32 bits total, 16 integer, 16 fraction.

| Value | Q16.16 encoding (hex) | Binary interpretation |
|-------|----------------------:|----------------------|
| 0.0 | `0x00000000` | `0000000000000000.0000000000000000` |
| 1.0 | `0x00010000` | `0000000000000001.0000000000000000` |
| 0.5 | `0x00008000` | `0000000000000000.1000000000000000` |
| 1.5 | `0x00018000` | `0000000000000001.1000000000000000` |
| 2.5 | `0x00028000` | `0000000000000010.1000000000000000` |
| −1.0 | `0xFFFF0000` | `1111111111111111.0000000000000000` |

To encode integer *n*: `n << 16`.  
To encode 0.5: `1 << 15` (the high bit of the fraction).  
To extract the integer part: `val >> 16` (arithmetic shift for signed).

**Drill:** `09-q16-from-int.asm` shifts 5 left by 16, then right by 16, exits 5.

**Drill:** `10-q16-frac.asm` adds two halves (`1<<15` each), gets `1<<16` (1.0), shifts right by 16, exits 1.

## Addition: no shift needed

Adding two Q16.16 values is just integer addition. The scale factors are the same, so the result is still Q16.16.

```asm
; 1.5 + 2.5 = 4.0
mov eax, (1<<16) + (1<<15)  ; 1.5
mov ebx, (2<<16) + (1<<15)  ; 2.5
add eax, ebx                ; 4.0 in Q16.16
shr eax, 16                 ; convert to integer 4
mov edi, eax
mov rax, 60
syscall
```

**Drill:** `02-fixed-add.asm` computes `1.5 + 2.5` and exits 4.

## Multiplication: shift right by 16 afterward

Multiplying two Q16.16 values produces a Q32.32 result (the fraction bits add: 16 + 16 = 32). Shift right by 16 to return to Q16.16.

```asm
; 2.0 * 3.0 = 6.0
mov eax, 2
shl eax, 16                 ; 2.0 in Q16.16
mov ebx, 3
shl ebx, 16                 ; 3.0 in Q16.16
movsxd rax, eax             ; sign-extend to 64 bits
movsxd rbx, ebx
imul rax, rbx               ; Q32.32: 6.0 with 32 fraction bits
shr rax, 16                 ; Q16.16: 6.0 with 16 fraction bits
```

**Important:** The value is now correct Q16.16 (6.0 = `0x60000`), but the **exit status** is the low 8 bits (0). To exit with 6, do a **second** `shr rax, 16` to convert to integer.

**Drill:** `01-fixed-mul.asm` does one shift (to Q16.16) and exits 0 (the low byte of `6<<16`).

**Drill:** `19-debug-q-shift.asm` does **two** shifts (Q16.16 → integer) and exits 6.

**Bug listing in `19-debug-q-shift.asm`:** The broken version masks with 255 before shifting, which discards the high bits and also exits 0. The fix shifts twice, exiting 6.

### Signed multiplication

For negative products, use **`sar`** (arithmetic shift) instead of `shr` (logical shift) after `imul`. `shr` treats the value as unsigned, which fails for negative results. The drills only use positive values, so `shr` works, but a real implementation needs `sar`.

## Division: shift left by 16 before dividing

Dividing two Q16.16 values naively gives a plain integer quotient (the scales cancel: `(a·2¹⁶) / (b·2¹⁶)` = `a/b` with zero fraction bits). To keep 16 fraction bits, **widen the dividend** by shifting left 16, giving it 32 fraction bits, so the quotient retains 16.

```asm
; 6.0 / 2.0 = 3.0
mov eax, 6
shl eax, 16                 ; 6.0 in Q16.16
mov ebx, 2
shl ebx, 16                 ; 2.0 in Q16.16
movsxd rax, eax
shl rax, 16                 ; widen: dividend now Q16.32
movsxd rbx, ebx
cqo                         ; sign-extend rax into rdx:rax
idiv rbx                    ; rax = (6·2³²) / (2·2¹⁶) = 3·2¹⁶ (Q16.16)
shr rax, 16                 ; convert to integer 3
mov rdi, rax
mov rax, 60
syscall
```

**Drill:** `11-fixed-div.asm` computes `6.0 / 2.0` and exits 3.

**Why `cqo`?** `idiv rbx` divides the 128-bit `rdx:rax` by `rbx`. `cqo` sign-extends `rax` into `rdx`, so negative dividends work correctly.

**Why `movsxd` first?** The Q value was built in 32-bit `eax`. Sign-extend it to 64-bit `rax` before shifting, or you'll lose the sign bit.

## Worked example: why shift left before `idiv` in `11-fixed-div.asm`?

**Task:** Divide 6.0 by 2.0 in Q16.16 and exit with 3.

**Plausible wrong reading:**

*"Multiplying two Q16.16 values requires a shift **after** `imul`. Dividing should be symmetric, so I just do `idiv` with no shifts."*

**Why it's wrong:** The scales cancel. `(6·2¹⁶) / (2·2¹⁶)` = `6/2` = 3, a plain integer with **zero** fraction bits. For `1.0 / 2.0`, this would give 0 (integer division truncates), not 0.5. Pre-shifting the dividend by 16 restores the 16 fraction bits: `(6·2³²) / (2·2¹⁶)` = `3·2¹⁶` (3.0 in Q16.16).

**The correct reading:** After `idiv`, `rax` holds `3<<16` (196608), a proper Q16.16 result. The final `shr rax, 16` converts that to the integer 3 for the exit status. That last shift is a "print as integer" step, not part of the division.

**Arithmetic summary:**
- **Multiply:** Fraction bits **add** → shift right to reduce from Q32.32 to Q16.16.
- **Divide:** Fraction bits **subtract** → shift left (widen) before `idiv` to keep 16 fraction bits.

## Linear interpolation (lerp)

Lerp between *a* and *b* with parameter *t* ∈ [0, 1]:

```
result = a + (b - a) * t
```

When *a* = 0, this simplifies to `b * t`.

**Drill:** `15-lerp-fixed.asm` lerps from 0 toward 10.0 with `t = 0.5`:
- `b = 10<<16` (Q16.16)
- `t = 1<<15` (0.5 in Q16.16)
- Product: `10·2¹⁶ · 0.5·2¹⁶` = `5·2³²` (Q32.32)
- Shift right 16 → `5<<16` (Q16.16)
- Shift right 16 → 5 (integer), exit 5

**Common mistake:** "t = `1<<15` has 15 fraction bits, not 16." Wrong—`1<<15` is the Q16.16 encoding of 0.5 (the high bit of the fraction). The product has 32 fraction bits (16+16), and two shifts of 16 return to an integer.

## Clamping and wrapping

### Clamp to a range

Clamp *x* to [min, max]:

```asm
; clamp(10, 0, 8) = 8
mov eax, 10<<16
mov ebx, 8<<16
cmp eax, ebx
jle .ok
mov eax, ebx                ; clamp down to 8
.ok:
shr eax, 16                 ; integer 8
```

**Drill:** `04-clamp-fixed.asm` clamps 10.0 down to 8.0, exits 8.

**Drill:** `16-clamp-q.asm` clamps integer −3 into [0, 100], exits 0.

### Angle wrapping (modulo 360)

An angle of 350° + 20° = 370° wraps to 10° by subtracting 360°:

```asm
mov eax, 350
add eax, 20                 ; 370
cmp eax, 360
jl .done
sub eax, 360                ; 10
.done:
```

**Drill:** `18-fixed-angle-step.asm` exits 10.

## Vector dot product

The dot product of two vectors `(a, b)` and `(c, d)` is `a*c + b*d`.

**Drill:** `05-dot2-fixed.asm` computes `(1, 2) · (3, 4)` = `1*3 + 2*4` = 11, exits 11.

**Drill:** `20-dot3.asm` computes `(1, 2, 3) · (4, 5, 6)` = `4 + 10 + 18` = 32, exits 32.

### Length squared (avoiding square root)

Length of `(x, y)` is `√(x² + y²)`. For comparisons (e.g., "is this vector longer than radius *r*?"), compare **length squared** instead: `x² + y²` vs. `r²`. No square root needed.

**Drill:** `14-vec2-length2.asm` computes `3² + 4²` = 25, exits 25 (not 5). The lesson stresses "not 5" because the file never takes a square root.

## Q8.8: an alternative format

**Q8.8** uses 8 fraction bits. Multiplication produces 16 fraction bits, so shift right by 8.

**Drill:** `08-from-scratch-q8.asm` multiplies `1.5` by `2` in Q8.8, shifts once by 8, leaving `3<<8` (768) in the register. The exit status is 0 (low byte). A second shift would give integer 3.

**Drill:** `24-from-scratch-q8-mul.asm` multiplies `2.5 * 2` in Q8.8, shifts once, leaving `5<<8` (1280), status 0.

## Stubs: reciprocal, matrix, sine table

**Drill:** `21-fast-inv-stub.asm` is `shr 10, 1` → 5, exit 5. It's **not** a Newton-Raphson reciprocal iteration (that's a stretch for later).

**Drill:** `22-stretch-matrix2-mul.asm` represents a 2×2 identity matrix times `(3, 4)`. The file does not load a matrix—it just exits 3 (the *x* component, a constant).

**Drill:** `23-stretch-sin-lut.asm` has a sine lookup table (three qwords: 0, 1, 0) and exits 1 (the middle entry). No angle indexing is performed.

These are placeholders for future integration. The milestone binary will expand them into real matrix mul and trig lookups.

## The "SIMD" drills are scalar stubs

Several drill filenames mention SSE or SIMD, but **they do not execute SSE instructions**. They are scalar integer stubs that will be replaced with real `xmm` code in a later version of the course.

**Drill:** `03-sse-add-scalar.asm` exits 5 (no `addss` instruction).

**Drill:** `12-sse-movss-stub.asm` exits 1 (no `movss` or `movaps`).

**Drill:** `07-simd-lane-sum-stub.asm` adds bytes `1, 2, 3, 4` with scalar `add`, exits 10.

**Drill:** `17-simd-horizontal-stub.asm` adds dwords `1, 2, 3, 4` with scalar `add`, exits 10.

**Drill:** `13-pack-rgba8888.asm` exits 255 (only the red byte in the low position; G, B, A are not shifted in). Lesson 14 will teach a different pack order (`XRGB`).

**Do not** load `xmm` registers to satisfy a prompt that says "SSE" if the solution does not use them. These drills are integer-only.

## Arithmetic shift vs. logical shift

The drills use `shr` (logical shift) after `imul` because all test values are positive. For **negative** fixed-point values, use `sar` (arithmetic shift right) to preserve the sign bit. `shr` zero-fills, which treats negative Q16.16 as a large positive number.

**Example:** `−2.0` in Q16.16 is `0xFFFE0000`. Logical `shr rax, 16` gives `0x0000FFFE` (65534, wrong). Arithmetic `sar rax, 16` gives `0xFFFFFFFE` (−2, correct).

Similarly, after `idiv` in `11-fixed-div.asm`, use `sar` if the quotient can be negative.

## Distinctions worth keeping straight

| Confusion | Reality |
|-----------|---------|
| Adding Q16.16 values needs a shift | Addition keeps the scale; no shift needed |
| Multiplying Q16.16 values needs two shifts | One shift (by 16) returns to Q16.16; a second shift converts to integer (for printing) |
| Dividing Q16.16 values is just `idiv` | Must shift dividend left by 16 first (widen to Q16.32) to keep fraction bits in the quotient |
| `shr` works for all fixed-point operations | `shr` is logical (zero-fill); use `sar` (sign-fill) for signed values |
| `1<<15` has 15 fraction bits | `1<<15` is the Q16.16 encoding of 0.5 (16 fraction bits, high bit set) |
| Length is `x² + y²` | Length **squared** is `x² + y²`; length is the square root (not computed in these drills) |
| The SSE drills execute `addss` or `movss` | The SSE-named drills are scalar integer stubs; no `xmm` registers are used |

## Check yourself

1. `01-fixed-mul.asm` exits 0 although it computes 2.0 × 3.0 correctly. What is in `rdi` at the `syscall`, and why is the status 0?

2. `15-lerp-fixed.asm` multiplies `10<<16` by `1<<15` and then does `shr rax, 16` twice. How many fraction bits does the product have before the shifts, and is the total shift correct?

3. `14-vec2-length2.asm` exits 25. Why does the lesson stress "not 5"?

4. You divide `1.0 / 2.0` in Q16.16 without shifting the dividend left. What integer result does `idiv` give, and why is that wrong?

5. You have a negative Q16.16 value `−4.0` = `0xFFFC0000`. You `shr` it right by 16. What unsigned integer do you get? What do you get with `sar`?

## Key takeaways

- Q16.16 encodes a fractional number as an integer with 16 fraction bits: integer *n* is `n<<16`, 0.5 is `1<<15`.
- Addition keeps the scale (no shift); subtraction is the same.
- Multiplication produces double the fraction bits (Q32.32), so shift right by 16 to return to Q16.16.
- Division cancels the scales, so shift the dividend left by 16 first (widen to Q16.32), then `idiv` keeps 16 fraction bits in the quotient.
- Use `sar` (arithmetic shift) for signed values, not `shr` (logical shift).
- Linear interpolation (lerp) is `a + (b - a) * t`; for `a = 0`, simplifies to `b * t`.
- Length squared (`x² + y²`) avoids the square root, useful for comparisons.
- The "SSE" drills in this lesson are scalar integer stubs; real SIMD is deferred to a later course update.

## Lookup

- Fixed-point arithmetic: [Wikipedia: Q (number format)](https://en.wikipedia.org/wiki/Q_(number_format))
- Signed vs. unsigned shifts: [Intel SDM Vol. 1, Section 4.1.6](https://www.intel.com/content/www/us/en/architecture-and-technology/64-ia-32-architectures-software-developer-vol-1-manual.html)
- Dot product and vector length: [Wikipedia: Dot product](https://en.wikipedia.org/wiki/Dot_product), [Vector magnitude](https://en.wikipedia.org/wiki/Euclidean_vector#Length)
- Linear interpolation: [Wikipedia: Linear interpolation](https://en.wikipedia.org/wiki/Linear_interpolation)

## Exercises

Twenty-four drills under `exercises/`. Solutions mirror the names under `solutions/`. Build with:

```bash
nasm -f elf64 FILE.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
```

**Q-format basics:**
- `01-fixed-mul.asm` — 2.0 × 3.0, one shift, exit 0 (register `6<<16`)
- `02-fixed-add.asm` — 1.5 + 2.5, exit 4
- `08-from-scratch-q8.asm` — Q8.8: 1.5 × 2, one shift, exit 0 (register `3<<8`)
- `09-q16-from-int.asm` — shift 5 left 16, then right 16, exit 5
- `10-q16-frac.asm` — two halves = 1.0, exit 1
- `11-fixed-div.asm` — 6.0 / 2.0, widen dividend, exit 3
- `15-lerp-fixed.asm` — lerp to 10.0 with t=0.5, exit 5
- `19-debug-q-shift.asm` — 2.0 × 3.0, two shifts, exit 6
- `24-from-scratch-q8-mul.asm` — Q8.8: 2.5 × 2, one shift, exit 0 (register `5<<8`)

**Integer geometry:**
- `04-clamp-fixed.asm` — clamp 10.0 to 8.0, exit 8
- `05-dot2-fixed.asm` — `(1,2)·(3,4)` = 11, exit 11
- `06-shift-div.asm` — `sar` 20 by 2, exit 5 (not Q divide)
- `14-vec2-length2.asm` — `3² + 4²` = 25, exit 25 (not 5)
- `16-clamp-q.asm` — clamp −3 to [0, 100], exit 0
- `18-fixed-angle-step.asm` — 350 + 20 wrap to 10, exit 10
- `20-dot3.asm` — `(1,2,3)·(4,5,6)` = 32, exit 32
- `21-fast-inv-stub.asm` — `shr 10, 1`, exit 5 (stub, not Newton)
- `22-stretch-matrix2-mul.asm` — identity × (3,4), exit 3 (no matrix)
- `23-stretch-sin-lut.asm` — sine table, exit 1 (middle entry)

**Scalar stubs (not SSE):**
- `03-sse-add-scalar.asm` — scalar add, exit 5 (no `addss`)
- `07-simd-lane-sum-stub.asm` — add bytes 1,2,3,4, exit 10
- `12-sse-movss-stub.asm` — exit 1 (no `movss`)
- `13-pack-rgba8888.asm` — exit 255 (R only, no G/B/A)
- `17-simd-horizontal-stub.asm` — add dwords 1,2,3,4, exit 10
