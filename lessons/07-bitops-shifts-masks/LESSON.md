# Lesson 07 — Bit Operations, Shifts, and Masks

Registers hold integers, but sometimes you need to manipulate individual bits or packed fields within those integers. This lesson teaches you to use logical operations (`and`, `or`, `xor`, `not`) to set, clear, and toggle bits, shifts (`shl`, `shr`, `sar`) to multiply, divide, and extract fields, and rotates (`rol`, `ror`) to move bits without losing them. You will pack multiple narrow values into a single register using shifts and masks, count set bits with loops (popcount), and understand the critical difference between logical right shift (`shr`, which fills with zeros) and arithmetic right shift (`sar`, which preserves the sign bit).

## What this lesson asks of you

You must be able to use `and` to clear bits (masking), `or` to set bits, `xor` to toggle bits or compute checksums, and `not` to flip all bits. You will use `shl` (shift left) to multiply by powers of two and position values in bitfields, `shr` (shift right logical) to divide unsigned values and extract high bits, and `sar` (shift right arithmetic) to divide signed values while preserving the sign. You will pack multiple narrow fields into one register by masking each value to its width, shifting it to its position, and OR-ing the results together. Finally, you will implement bit-counting loops (popcount, count leading zeros, count trailing zeros) and recognize when `rol` and `ror` (rotate left/right) are needed to preserve bits that would otherwise be shifted out.

## Logical operations: `and`, `or`, `xor`, `not`

### `and`: masking (keeping specific bits)

`and reg, mask` keeps only the bits that are set in both operands. This is how you extract a field or clear unwanted bits:

```asm
mov rax, 0xFF            ; rax = 11111111 binary
and rax, 0x0F            ; rax = 00001111 binary (keep low nibble)
; result: rax = 15
```

To clear bit `n`, AND with a mask that has 0 at position `n` and 1 everywhere else: `and reg, ~(1 << n)`. In NASM, `~` is a compile-time operator, so `and rdi, ~8` assembles to `and rdi, 0xFFFFFFFFFFFFFFF7`.

### `or`: setting bits

`or reg, bits` sets (turns on) any bits that are 1 in the second operand:

```asm
mov rax, 0
or rax, 1                ; set bit 0
or rax, 4                ; set bit 2
; result: rax = 5 (binary 101)
```

To set bit `n`, OR with `1 << n`.

### `xor`: toggling and zeroing

`xor reg, bits` flips any bits that are 1 in the second operand. If a bit is 0, XOR leaves it alone; if it is 1, XOR flips it to 0.

```asm
mov rax, 5               ; binary 101
xor rax, 1               ; flip bit 0 → binary 100
; result: rax = 4
```

The idiomatic use of `xor` is `xor reg, reg`, which always produces zero (any bit XORed with itself is 0). This is shorter and faster than `mov reg, 0`.

XOR has another use: swapping two registers without a temporary. If you have distinct registers `a` and `b`:

```asm
xor a, b
xor b, a
xor a, b
; a and b are swapped
```

But this is fragile (both must be different registers, and if a signal arrives mid-swap, one value is torn). Prefer `xchg` for actual swaps.

XOR is also used for checksums: XOR-ing a sequence of bytes produces a simple error-detection value.

### `not`: flipping all bits

`not reg` inverts every bit (0→1, 1→0). Unlike other logical operations, `not` does **not** update any flags.

```asm
mov al, 0x0F             ; 00001111
not al                   ; 11110000
; result: al = 0xF0
```

## Shifts: `shl`, `shr`, `sar`

Shifts move bits left or right. The bits that "fall off" one end are lost (or go into CF), and new bits enter from the other end.

| Instruction | Direction | Bit entering | What it does | Typical use |
|-------------|-----------|--------------|--------------|-------------|
| `shl reg, n` | Left | 0 at bit 0 | Multiply by 2^n | Unsigned multiply, position fields |
| `shr reg, n` | Right | 0 at the top (msb) | Divide by 2^n (unsigned) | Unsigned divide, extract high bits |
| `sar reg, n` | Right | Copy of sign bit | Divide by 2^n (signed) | Signed divide |

The shift count `n` can be an immediate (constant) or the value in `cl` (the low 8 bits of `rcx`). You cannot use other registers or memory for the count.

### `shl`: shift left (multiply)

```asm
mov rax, 3
shl rax, 2               ; rax = 3 * 4 = 12
```

Shifting left by `n` multiplies by 2^n (for unsigned values, or signed values that do not overflow). The bits shifted out go into CF (Carry Flag).

### `shr`: shift right logical (unsigned divide)

```asm
mov rax, 12
shr rax, 2               ; rax = 12 / 4 = 3
```

Shifting right by `n` divides by 2^n, discarding the remainder (integer division). `shr` fills the vacated high bits with zeros. This is correct for unsigned values.

### `sar`: shift right arithmetic (signed divide)

For signed values, `shr` is wrong. Consider `-8 >> 1` (divide by 2). If you use `shr`, the result is a large positive number (bit 63 becomes 0, so the value is no longer negative). Use `sar` (shift arithmetic right) instead, which fills the vacated high bits with copies of the sign bit (bit 63 for 64-bit registers):

```asm
mov rax, -8
sar rax, 1               ; rax = -8 / 2 = -4 (correct)
```

`sar` preserves the sign and produces the correct signed quotient (rounding toward negative infinity).

### Flag effects

After `shl`, `shr`, or `sar`, the last bit shifted out goes into CF. SF, ZF, and PF reflect the result. OF is defined only for 1-bit shifts; for multi-bit shifts, OF is undefined. AF is undefined.

## Packing and unpacking bitfields

A **bitfield** is a narrow value (fewer than 64 bits) stored inside a register at a specific position. To pack multiple fields into one register:

1. Mask each value to its width (to ensure it does not overflow into adjacent fields).
2. Shift it left to its position.
3. OR the results together.

For example, pack three 3-bit values (`a=5`, `b=2`, `c=1`) into bits 0-2, 3-5, and 6-8:

```asm
    mov rax, 5
    and rax, 0x7             ; mask to 3 bits (width mask = 2^3 - 1 = 7)
    ; rax now holds a in bits 0-2

    mov rbx, 2
    and rbx, 0x7             ; mask to 3 bits
    shl rbx, 3               ; shift to position (bits 3-5)
    or rax, rbx              ; combine

    mov rbx, 1
    and rbx, 0x7
    shl rbx, 6               ; shift to position (bits 6-8)
    or rax, rbx              ; combine

    ; rax = 0b001_010_101 = 0x55 = 85
```

To unpack a field at position `pos` with width `w`:

```asm
shr reg, pos             ; shift field to bit 0
and reg, (1 << w) - 1    ; mask to width
```

For example, extract `b` (bits 3-5, width 3) from `0x55`:

```asm
mov rax, 0x55
shr rax, 3               ; shift bits 3-5 down to bits 0-2
and rax, 0x7             ; mask to 3 bits
; result: rax = 2
```

## Rotate: `rol` and `ror`

Shifts discard the bit that falls off one end. **Rotates** instead wrap that bit around to the other end. `rol reg, n` (rotate left) shifts bits left, and the bits that exit at the msb re-enter at the lsb. `ror reg, n` (rotate right) does the opposite.

```asm
mov al, 0x80             ; binary 10000000
rol al, 1                ; rotate left by 1
; result: al = 0x01 (binary 00000001)
```

The bit that was at position 7 moved to position 0. No bit is lost.

Rotates update CF (the bit that "came around") and OF (for 1-bit rotates only), but leave other flags unchanged. Use rotates when you need to process all bits of a value without discarding any.

## Bit-counting loops

x86-64 has specialized instructions (`popcnt`, `lzcnt`, `tzcnt`) for counting bits, but implementing these as loops teaches the bit-manipulation patterns.

### Popcount (count set bits)

Shift right until the register is zero, adding 1 to a counter each time bit 0 is set:

```asm
popcount:
    ; rdi = value
    xor rax, rax             ; counter = 0
.loop:
    test rdi, rdi
    jz .done
    test rdi, 1              ; is bit 0 set?
    jz .next
    inc rax                  ; yes, count it
.next:
    shr rdi, 1               ; shift right
    jmp .loop
.done:
    ret                      ; rax = count of 1 bits
```

### Count trailing zeros (ctz)

Shift right until bit 0 is set, counting how many shifts:

```asm
ctz:
    ; rdi = value (assume nonzero)
    xor rax, rax
.loop:
    test rdi, 1
    jnz .done
    inc rax
    shr rdi, 1
    jmp .loop
.done:
    ret                      ; rax = number of trailing zeros
```

For `0b1011000`, this returns 3 (three zeros at the right).

### Count leading zeros (clz)

Shift left until bit 63 (or bit 15 for a 16-bit value) is set, counting how many shifts:

```asm
clz16:
    ; ax = 16-bit value
    xor rcx, rcx
.loop:
    cmp rcx, 16
    jge .done
    test ax, 0x8000          ; is bit 15 set?
    jnz .done
    inc rcx
    shl ax, 1
    jmp .loop
.done:
    mov rax, rcx
    ret                      ; rax = count of leading zeros
```

For `0x00F0`, this returns 8 (eight zeros before the first 1).

## Worked example: extracting RGB components from a 24-bit color

A 24-bit RGB color packs three 8-bit components: red at bits 16-23, green at bits 8-15, blue at bits 0-7. Let's extract each component from the value `0xABCDEF`:

```asm
section .text
    global _start

_start:
    mov rax, 0xABCDEF        ; color = 0xABCDEF

    ; extract red (bits 16-23)
    mov rbx, rax
    shr rbx, 16              ; shift bits 16-23 down to bits 0-7
    and rbx, 0xFF            ; mask to 8 bits
    ; rbx = 0xAB = 171

    ; extract green (bits 8-15)
    mov rcx, rax
    shr rcx, 8
    and rcx, 0xFF
    ; rcx = 0xCD = 205

    ; extract blue (bits 0-7)
    mov rdx, rax
    and rdx, 0xFF            ; no shift needed (already at bit 0)
    ; rdx = 0xEF = 239

    ; exit with blue component
    mov rdi, rdx
    mov rax, 60
    syscall
```

Build and run:
```bash
nasm -f elf64 rgb.asm -o rgb.o
ld rgb.o -o rgb
./rgb
echo $?   # prints 239
```

Trace the extraction: For red, we shift right by 16 (moving bits 16-23 to bits 0-7) and mask with `0xFF` to keep only the low 8 bits. For green, shift by 8 and mask. For blue, no shift is needed (it is already at bits 0-7), so we just mask.

### A plausible wrong reading (and why it fails)

A common mistake is to forget the mask after shifting. Suppose you write:

```asm
mov rbx, rax
shr rbx, 16              ; shift red bits down
; MISSING: and rbx, 0xFF
```

After shifting `0xABCDEF` right by 16, `rbx` holds `0xAB`, which looks correct. But if the original value had bits set above bit 23 (e.g., `0xFFABCDEF`), shifting right by 16 gives `0xFFAB`, not `0xAB`. The mask `and rbx, 0xFF` ensures only the low 8 bits remain, regardless of what was in the high bits. Always mask after shifting to extract a field cleanly.

## Distinctions worth keeping straight

| Confusion | What actually separates them |
|-----------|------------------------------|
| `shr` vs `sar` | `shr` fills with zeros (correct for unsigned); `sar` fills with the sign bit (correct for signed). Using `shr` on a negative value produces a large positive number. |
| `shl` overflow (unsigned vs signed) | For unsigned, `shl` multiplies by 2^n and sets CF if bits are lost. For signed, OF indicates signed overflow (the result does not fit in the signed range). Check the appropriate flag. |
| Shift count in `cl` vs other registers | Only `cl` (low 8 bits of `rcx`) can hold a variable shift count. `shl rax, rbx` does not assemble; use `mov cl, bl; shl rax, cl` instead. |
| `and` vs `test` | `and` computes `a & b` and stores the result. `test` computes `a & b` and only updates flags (result is discarded). Use `test` to check bits without changing the register. |
| `xor reg, reg` vs `mov reg, 0` | Both zero the register, but `xor` is shorter (2 bytes vs 5-10) and faster. Use `xor reg, reg` idiomatically. |
| Rotate vs shift | `rol`/`ror` wrap bits around; `shl`/`shr`/`sar` discard bits. Use rotate when you need all bits (e.g., bit-reversing, circular buffers). |
| Masking before vs after shift (packing) | When packing, mask **before** shifting to prevent overflow into adjacent fields. When unpacking, shift **then** mask to extract the field. |
| OF defined only for 1-bit shifts | `shl rax, 2` updates CF and other flags, but OF is undefined. Only `shl rax, 1` has a defined OF. Do not rely on OF for multi-bit shifts. |

## Check yourself

1. You want to set bit 5 of `rax` without changing other bits. Which instruction and operand do you use?
2. You want to divide signed value `-16` by 4 using a shift. Which shift instruction do you use, and why?
3. Extract bits 4-7 (a 4-bit field at position 4) from `rax = 0xABCD`. Write the two instructions (shift and mask).
4. After `shl rax, 3`, which flag tells you if any bits were lost? What is the value of that flag if `rax` was initially `0x2000000000000000`?
5. Trace `popcount(0b1011)`: how many times does the loop iterate, and what is the final count?

## Key takeaways

- Logical operations (`and`, `or`, `xor`, `not`) manipulate individual bits: `and` masks, `or` sets, `xor` toggles, `not` flips all.
- `shl` shifts left (multiplies by 2^n); `shr` shifts right logical (divides unsigned by 2^n, fills with zeros); `sar` shifts right arithmetic (divides signed by 2^n, preserves sign).
- To pack bitfields, mask each value to its width, shift it to its position, and OR the results; to unpack, shift the field to bit 0 and mask to its width.
- Rotates (`rol`, `ror`) wrap bits around instead of discarding them; use rotates when all bits must be preserved.
- `xor reg, reg` is the idiomatic zero; `test reg, bits` checks bits without modifying the register.
- Shift counts must be immediate constants or `cl`; other registers cannot hold shift counts directly.

## Lookup

- **Logical instructions:** Intel® 64 and IA-32 Architectures Software Developer's Manual, Volume 2, entries for `and`, `or`, `xor`, `not`, `test`
- **Shift instructions:** Volume 2, entries for `shl`, `shr`, `sar`, `rol`, `ror`
- **Flag effects:** Volume 1, Chapter 3.4 (RFLAGS register), description of CF, OF, SF, ZF after shifts
- **Bit manipulation:** Any systems programming textbook chapter on bitwise operations and bitfields

## Exercises

24 drills under `exercises/`. Solutions mirror names in `solutions/`. Build with:
```bash
nasm -f elf64 FILE -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
```

Logic: `01-and-mask.asm`, `02-or-flags.asm`, `03-xor-swap.asm`, `09-xor-checksum.asm`, `10-bit-set-clear.asm`, `11-isolate-lowbit.asm`, `12-next-power-of-two-bit.asm`. Shifts: `04-shl-mul.asm`, `05-sar-sign.asm`, `14-sar-vs-shr.asm`, `18-mask-range.asm`, `19-debug-sign-shift.asm`, `21-gray-code.asm`, `22-stretch-swar-avg.asm`. Fields: `07-extract-bitfield.asm`, `13-shl-shl-combine.asm`, `15-bitfield-pack.asm`, `16-bitfield-unpack.asm`. Rotate and counts: `08-from-scratch-rol.asm`, `17-rotate-parity.asm`, `06-popcount-naive.asm`, `20-count-leading-zeros-loop.asm`, `23-stretch-bit-reverse8.asm`, `24-from-scratch-ntz.asm`.
