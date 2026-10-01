# Lesson 07 — Bit Ops, Shifts, Masks

## Learning objectives

1. Clear, set, and toggle bits with `and`, `or`, `xor`, and `not`.
2. Scale and divide with `shl`, `shr`, and `sar`, and know which bits enter.
3. Pack and unpack a field with a shift and a width mask.
4. Rotate with `rol` and `ror` instead of dropping the bit that shifts out.
5. Count bits, leading zeros, and trailing zeros with a loop.

Lesson 06 indexed bytes. This lesson changes the bits inside a register. File I/O and `mmap` are lesson 08. Do not reach for `popcnt`, `lzcnt`, or `tzcnt`; the drills are the loops.

## Masks

`and` keeps the bits set in both operands. `or` sets bits. `xor` toggles bits that are set in the second operand. `not` flips every bit of one operand but affects no flags. `test` is still `and` that only writes flags, from lesson 02.

```asm
section .text
global _start
_start:
    mov rax, 0xFF
    and rax, 0x0F           ; low nibble only
    mov rdi, rax            ; 15
    mov rax, 60
    syscall
```

That is `01-and-mask.asm`. `02-or-flags.asm` is packing two booleans, not RFLAGS: bit 0 (`1`) and bit 2 (`4`) make 5. `10-bit-set-clear.asm` does `or rdi, (1<<3)` then `and rdi, ~(1<<3)` and exits 0. The `~` is NASM on the immediate. `not rdi` would flip every other bit too.

`xor` of a register with itself is still the zeroing idiom. `xor` of two different registers three times swaps them (`03-xor-swap.asm`: `rax` starts at 1, ends at 2). It is not a general swap: both names must be different registers, and a signal in the middle observes a torn value. Prefer `xchg` when you only need a swap. Folding bytes `1,2,4,8` with `xor` exits 15 (`09-xor-checksum.asm`).

`x & -x` keeps the lowest set bit (`11-isolate-lowbit.asm`: `0b101100` exits 4). A nonzero power of two is the value that has exactly that one bit: `x & (x-1)` is zero (`12-next-power-of-two-bit.asm` exits 1 for 16, and 0 for zero).

## Three shifts

| Instruction | Bit that enters | What it is |
|-------------|-----------------|------------|
| `shl r, n` | 0 at bit 0 | unsigned multiply by `2^n` |
| `shr r, n` | 0 at the top | unsigned divide by `2^n` |
| `sar r, n` | copy of the sign bit | signed divide, toward −∞ |
| `rol` / `ror` | the bit that left the other end | rotate, not a divide |

The count is an 8-bit immediate, or `cl` — a count in any other register or in memory is not encodable.

`shl rax, 3` on 3 exits 24 (`04-shl-mul.asm`). A mask of width 5 is `(1<<5)-1` = 31 (`18-mask-range.asm`). `n ^ (n>>1)` is binary-to-Gray (`21-gray-code.asm`: 7 exits 4). Flag effects: `shl`, `shr`, and `sar` put the last bit shifted out into CF; OF is defined only for 1-bit shifts and undefined otherwise; SF, ZF, and PF follow the result; AF is undefined.

## `sar` keeps the sign

`shr` on a negative value fills ones with zeros and the result is a large unsigned number. `sar` fills with the sign bit. Exit status is only the low 8 bits, so `al` of −4 and `al` of a logical shift can both be 252. Compare the whole register.

```asm
section .text
global _start
_start:
    mov rax, -8
    sar rax, 1
    cmp rax, -4
    jne .bad
    movzx rdi, al           ; 252
    mov rax, 60
    syscall
.bad:
    mov rdi, 1
    mov rax, 60
    syscall
```

`05-sar-sign.asm` is the `movzx` without the compare, and it exits 252. `14-sar-vs-shr.asm` checks `sar` of −4 equals −2 and exits 1. `19-debug-sign-shift.asm` is the bug of using `shr` for −16 >> 2. `sar rax, 2` is −4, and `movzx` of `al` exits 252. `shr` would not be −4.

The byte average `(a&b) + ((a^b)>>1)` stays inside a byte (`22-stretch-swar-avg.asm`: 200 and 100 exit 150). The shift is `shr`, so the high bit of the xor is discarded, not sign-filled. That is the point of the formula.

## Fields are a shift and a mask

Put the narrow value in the low bits, mask the width, shift it to its place, then `or` it in. Layout for this lesson: `a` is 3 bits at 0, `b` is 3 bits at 3, `c` is 2 bits at 6. Values 5, 2, and 1 pack to 85 (`0b01010101`).

```asm
section .text
global _start
_start:
    mov rax, 5
    and rax, 7              ; a, bits 0..2
    mov rbx, 2
    and rbx, 7
    shl rbx, 3
    or rax, rbx             ; b, bits 3..5
    mov rbx, 1
    and rbx, 3
    shl rbx, 6
    or rax, rbx             ; c, bits 6..7
    mov rdi, rax            ; 85
    mov rax, 60
    syscall
```

That is `15-bitfield-pack.asm`. The mask before the shift keeps a value that is too wide from occupying the next field's bits. `16-bitfield-unpack.asm` takes `0b01010101`, shifts right by 3, masks with 7, and exits 2. The prompt writes the same bits as `0b01_010_101`, and NASM accepts the underscores — they have been allowed in numeric literals since NASM 2.00 (§3.4.1). The solution immediate is `0b01010101`. `07-extract-bitfield.asm` is `(0xABCD >> 4) & 0xF` = 12. `(0xA << 4) | 0xB` exits 171 (`13-shl-shl-combine.asm`).

## Rotate, do not drop the bit

`rol al, 1` on `0x80` exits 1 (`08-from-scratch-rol.asm`). The file name says from scratch. The solution is the `rol` instruction. `ror al, 1` on `0x01` exits 128 (`17-rotate-parity.asm`). The prompt's longer parity count is not what the solution does. Flag effects: `rol` and `ror` update CF and OF — OF is defined only for 1-bit rotates — and leave the other flags unchanged.

A loop that pulls bit 0 into a new register reverses an 8-bit value (`23-stretch-bit-reverse8.asm`: `0b10000000` exits 1). `rol` eight times is not that reversal unless you insert the outgoing bit at the other end of a second register.

## Counting loops

Popcount shifts until the register is zero and adds the bit in bit 0 (`06-popcount-naive.asm`: `0b101101` exits 4). Trailing zeros are how many shifts happen before bit 0 is set (`24-from-scratch-ntz.asm`: `0b1011000` exits 3). Leading zeros in a 16-bit lane shift the other way: `0x00F0` exits 8 (`20-count-leading-zeros-loop.asm`). A zero input is 16 leading zeros, not an infinite loop. The word lives in `.data` as `dw 0x00F0`, and the count is on `ax` after `movzx`, not on a 64-bit register.

## Exercises

24 drills under `exercises/`. Solutions mirror the names in `solutions/`. Build with `nasm -f elf64 FILE -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?`.

Logic: `01-and-mask.asm`, `02-or-flags.asm`, `03-xor-swap.asm`, `09-xor-checksum.asm`, `10-bit-set-clear.asm`, `11-isolate-lowbit.asm`, `12-next-power-of-two-bit.asm`. Shifts: `04-shl-mul.asm`, `05-sar-sign.asm`, `14-sar-vs-shr.asm`, `18-mask-range.asm`, `19-debug-sign-shift.asm`, `21-gray-code.asm`, `22-stretch-swar-avg.asm`. Fields: `07-extract-bitfield.asm`, `13-shl-shl-combine.asm`, `15-bitfield-pack.asm`, `16-bitfield-unpack.asm`. Rotate and counts: `08-from-scratch-rol.asm` (uses `rol`), `17-rotate-parity.asm` (uses `ror`, exit 128), `06-popcount-naive.asm`, `20-count-leading-zeros-loop.asm`, `23-stretch-bit-reverse8.asm`, `24-from-scratch-ntz.asm`.