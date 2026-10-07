# Lesson 02 — Arithmetic & Flags

Arithmetic instructions do more than compute results — they also record facts about those results in the FLAGS register. This lesson teaches you to read those flags and use them for decisions. You will perform addition, subtraction, multiplication, and division correctly for both signed and unsigned integers, understand why `cmp` and `test` exist (they are arithmetic operations that discard the result but keep the flags), and use the `setcc` family to turn flag states into boolean values. The distinction between signed and unsigned arithmetic is not academic — using the wrong division instruction or reading the wrong flag produces silently incorrect results.

## What this lesson asks of you

You must be able to use `add`, `sub`, `inc`, `dec`, and `neg` to perform integer arithmetic, and read the Zero Flag (ZF), Sign Flag (SF), Carry Flag (CF), and Overflow Flag (OF) after these operations. You will set up the `rdx:rax` register pair correctly for division with `cqo` (signed) or `xor rdx, rdx` (unsigned) before invoking `idiv` or `div`, and distinguish between signed multiply (`imul`) and unsigned multiply (`mul`). You will use `cmp` to compare two values and `test` to check bits, then interpret the resulting flags. Finally, you will use `setcc` instructions (like `sete`, `setl`, `setg`) to materialize boolean values (0 or 1) from flag states, which is the foundation for conditional logic without branching.

## Integer arithmetic instructions

The basic arithmetic instructions operate on registers and memory. The destination operand (on the left in NASM syntax) is both read and written:

```asm
add rdi, rsi      ; rdi = rdi + rsi
sub rax, 1        ; rax = rax - 1
inc rcx           ; rcx = rcx + 1
dec rcx           ; rcx = rcx - 1
neg rax           ; rax = -rax (two's complement negation)
```

All of these update the FLAGS register to record properties of the result. For example, `add` sets ZF (Zero Flag) if the sum is zero, CF (Carry Flag) if there was unsigned overflow, and OF (Overflow Flag) if there was signed overflow. We will examine those flags shortly.

One historical quirk: `inc` and `dec` update ZF, SF, and OF, but they **do not** update CF. This is a design decision from the 8086 era (to save encoding space). Most code does not care, but if you need CF after an increment, use `add reg, 1` instead of `inc reg`.

## Multiplication: signed vs unsigned

x86-64 provides separate multiply instructions for signed and unsigned integers because the high-order bits of the product differ when negative values are involved.

### Signed multiply: `imul`

The `imul` instruction has three forms:

```asm
imul rax, rbx         ; rax = rax * rbx (signed, ignores high bits)
imul rcx, rdi, 5      ; rcx = rdi * 5 (signed, three-operand immediate form)
imul rbx              ; rdx:rax = rax * rbx (one-operand form, full product)
```

The two- and three-operand forms truncate the result to the destination size and are sufficient when you know the product fits. The one-operand form produces the full 128-bit result in `rdx:rax` and is useful when you need to detect overflow or handle large products.

### Unsigned multiply: `mul`

```asm
mul rbx               ; rdx:rax = rax * rbx (unsigned)
```

The `mul` instruction only has a one-operand form and always produces the full product in `rdx:rax`. If you multiply two 64-bit unsigned integers, the result may be up to 128 bits, and `rdx` holds the high 64 bits.

The distinction matters. For example, multiplying `-1` (all bits set) by `2` using signed `imul` produces `-2`. Using unsigned `mul` interprets `-1` as `0xFFFFFFFFFFFFFFFF` (the maximum unsigned value) and produces a huge positive result. Choose the instruction that matches your data type.

## Division: setting up the dividend in `rdx:rax`

Division is more complex because it takes a double-width dividend. For 64-bit division, the dividend is a 128-bit value in `rdx:rax`, where `rdx` holds the high 64 bits and `rax` holds the low 64 bits. The divisor is a single register or memory operand. After the instruction completes, the quotient is in `rax` and the remainder is in `rdx`.

### Signed division: `idiv`

For signed division, the high half of the dividend must be the **sign extension** of the low half. The `cqo` (Convert Quadword to Octword) instruction does this: it copies the sign bit of `rax` (bit 63) into every bit of `rdx`.

```asm
mov rax, -10          ; signed dividend in rax
cqo                   ; sign-extend rax into rdx:rax (rdx = all 1s if rax < 0)
mov rbx, 3            ; divisor
idiv rbx              ; rax = quotient, rdx = remainder
```

If you forget `cqo` and `rdx` contains garbage, the dividend is a random 128-bit value, and the quotient will be nonsense (or the instruction will fault with `#DE` if the quotient does not fit in 64 bits).

### Unsigned division: `div`

For unsigned division, the high half of the dividend is simply the high 64 bits of the 128-bit unsigned value. If your dividend fits in 64 bits (most common case), the high half is zero:

```asm
mov rax, 100          ; unsigned dividend in rax
xor rdx, rdx          ; clear high half (rdx = 0)
mov rbx, 7            ; divisor
div rbx               ; rax = quotient, rdx = remainder
```

If you forget `xor rdx, rdx` and `rdx` is nonzero, you are dividing a huge 128-bit number, and the quotient will overflow or be wrong.

### Division faults

If the divisor is zero, or if the quotient does not fit in the destination register (e.g., dividing a huge `rdx:rax` by 1), the CPU raises a divide exception (`#DE`, delivered as `SIGFPE` on Linux) and your program crashes. Check divisors before dividing, or handle the signal.

## The FLAGS register: what the CPU records

After most arithmetic and logical instructions, the CPU updates flags in the RFLAGS register. The flags we care about now are:

| Flag | Name | Set when |
|------|------|----------|
| ZF | Zero Flag | The result is exactly zero |
| SF | Sign Flag | The result's most significant bit (msb) is set (negative in signed interpretation) |
| CF | Carry Flag | Unsigned arithmetic carried out of or borrowed into the msb |
| OF | Overflow Flag | Signed arithmetic overflowed (result does not fit in the destination's signed range) |

Here is how to think about them:

- **ZF** is straightforward: `ZF=1` means the result is zero. Use it to test equality after `cmp`.
- **SF** is the high bit of the result. For signed values, `SF=1` means negative; `SF=0` means non-negative. For unsigned values, SF has no standard interpretation.
- **CF** indicates unsigned overflow. For example, `add al, 1` with `al=255` wraps to 0 and sets CF because the true sum (256) does not fit in 8 bits as an unsigned integer.
- **OF** indicates signed overflow. For example, `add al, 1` with `al=127` (the maximum positive 8-bit signed value) wraps to -128 and sets OF because the true signed sum (128) exceeds the 8-bit signed range.

You cannot have both signed and unsigned overflow at once in practice; which flag you check depends on whether your data is signed or unsigned.

## Comparison and testing: `cmp` and `test`

Often you want to set flags without keeping the arithmetic result. That is what `cmp` and `test` do.

### `cmp a, b`

`cmp a, b` computes `a - b`, updates the flags, and **discards the result**. It leaves `a` and `b` unchanged. The flags tell you the relationship between `a` and `b`:

- `ZF=1` means `a == b` (the difference is zero).
- For unsigned comparison: check CF. `CF=0` after `cmp a, b` means `a >= b` (unsigned). `CF=1` means `a < b` (unsigned).
- For signed comparison: combine SF and OF. The details are subtle, so we typically use conditional jump instructions that do this for us (covered in Lesson 03).

### `test a, b`

`test a, b` computes `a & b` (bitwise AND), updates the flags, and discards the result. It leaves `a` and `b` unchanged. Commonly used to test if bits are set:

```asm
test rax, rax         ; check if rax is zero (ZF=1 if rax==0)
test al, 1            ; check if low bit of al is set (ZF=0 if set)
```

`test` also clears CF and OF to zero, which can be useful. The pattern `test rax, rax` is the idiomatic way to check if a register is zero (equivalent to `cmp rax, 0` but shorter).

## Materializing boolean values with `setcc`

After a comparison, you may want to store the boolean result (true or false, 1 or 0) in a register. The `setcc` family does this. Each instruction checks one or more flags and writes 1 or 0 to an 8-bit destination:

```asm
cmp rax, rbx
sete al               ; al = 1 if rax == rbx (ZF=1), else al = 0
```

Common `setcc` instructions:

| Instruction | Condition | Typical use |
|-------------|-----------|-------------|
| `sete` / `setz` | `ZF=1` | Equal / zero |
| `setne` / `setnz` | `ZF=0` | Not equal / not zero |
| `setl` / `setg` | Signed less / greater | `a < b` or `a > b` (signed) |
| `setle` / `setge` | Signed ≤ / ≥ | `a <= b` or `a >= b` (signed) |
| `setb` / `seta` | Unsigned below / above | `a < b` or `a > b` (unsigned) |
| `setbe` / `setae` | Unsigned ≤ / ≥ | `a <= b` or `a >= b` (unsigned) |

The destination is always an 8-bit register. To use the result as a 64-bit value, zero-extend it:

```asm
cmp rax, rbx
setl al               ; al = 1 if rax < rbx (signed), else 0
movzx rdi, al         ; rdi = al (zero-extended to 64 bits)
```

This is the building block for branchless conditional logic (though branching with `jcc` is usually clearer — we cover that in Lesson 03).

## Worked example: signed division with remainder

Let's compute `-42 / 5` and print both the quotient and remainder as the exit status. Here is the source:

```asm
section .text
    global _start
_start:
    mov rax, -42          ; dividend (signed)
    cqo                   ; sign-extend rax into rdx:rax
    mov rbx, 5            ; divisor
    idiv rbx              ; quotient in rax, remainder in rdx

    ; exit with quotient (should be -8, appears as 256-8=248 unsigned)
    mov rdi, rax
    mov rax, 60
    syscall
```

Build and run:
```bash
nasm -f elf64 sdiv.asm -o sdiv.o
ld sdiv.o -o sdiv
./sdiv
echo $?   # prints 248 (two's complement of -8 as unsigned 8-bit exit code)
```

Step through the reasoning. We load `-42` into `rax`. The `cqo` instruction examines bit 63 of `rax` (the sign bit). Since `-42` is negative, bit 63 is 1, so `cqo` sets every bit of `rdx` to 1 (all-ones, representing -1 in two's complement extended across 64 bits). This makes `rdx:rax` the 128-bit signed representation of `-42`.

Next, `idiv rbx` divides `rdx:rax` by 5. The quotient is `-42 / 5 = -8` (integer division truncates toward zero for negative numbers in x86-64), placed in `rax`. The remainder is `-42 - (5 * -8) = -42 + 40 = -2`, placed in `rdx`. We ignore the remainder here and exit with the quotient.

The shell's exit code is an unsigned 8-bit value, so `-8` wraps to `256 - 8 = 248` when printed by `echo $?`. This is expected behavior — exit codes are unsigned.

### A plausible wrong reading (and why it fails)

A common mistake is to forget `cqo` before `idiv`, leaving `rdx` uninitialized or containing leftover data. Suppose `rdx` happens to hold `0x0000000000000001` (a small positive value). Then `rdx:rax` represents the 128-bit number `0x0000000000000001:FFFFFFFFFFFFFFD6` (where `0xFFFFFFFFFFFFFFD6` is `-42` as a 64-bit two's complement value). When interpreted as a 128-bit signed number, this is a huge positive value (approximately `2^64 - 42`), not `-42`.

Dividing this huge number by 5 produces a quotient that overflows a 64-bit register, and the CPU raises a divide exception (`#DE`), terminating the program with `SIGFPE`. You never see the quotient — the program crashes. The lesson: **always** use `cqo` before `idiv` when the dividend is a signed 64-bit value, or `xor rdx, rdx` before `div` for unsigned. Failing to set up `rdx` is the most common division error.

## Distinctions worth keeping straight

| Confusion | What actually separates them |
|-----------|------------------------------|
| `imul` vs `mul` | `imul` is signed multiply; `mul` is unsigned. The low-order bits of the product are identical, but the high-order bits (in `rdx` for one-operand forms) differ when negative values are involved. Use the instruction that matches your data type. |
| `idiv` vs `div` | `idiv` is signed division and requires `cqo` (sign-extend) setup; `div` is unsigned and requires `xor rdx, rdx` (zero) setup. Using the wrong setup produces wrong results or crashes. |
| `cqo` vs `xor rdx, rdx` | `cqo` sign-extends `rax` into `rdx:rax` for signed division. `xor rdx, rdx` zeros `rdx` for unsigned division. They are opposites — use the one that matches your data. |
| CF vs OF | CF indicates unsigned overflow (carry/borrow); OF indicates signed overflow. After `add` or `sub`, check CF for unsigned arithmetic and OF for signed arithmetic. Checking the wrong flag gives you the wrong answer. |
| `cmp a, b` vs `test a, b` | `cmp` computes `a - b` and sets flags (for equality, signed/unsigned comparison). `test` computes `a & b` and sets flags (for zero checks, bit tests). They discard the result and leave operands unchanged. |
| `setl` vs `setb` | `setl` (set if less) is for signed comparison (`a < b` signed). `setb` (set if below) is for unsigned comparison (`a < b` unsigned). The same numeric values produce different results when interpreted as signed vs unsigned. |
| `inc` vs `add reg, 1` | Both increment, but `inc` does **not** update CF (historical quirk). If you need CF after an increment (rare), use `add reg, 1` instead. |
| `mov eax, -1` vs `movsx rax, eax` | Writing `-1` to `eax` zero-extends to `rax`, making `rax = 0x00000000FFFFFFFF` (a large positive value), not -1. To sign-extend a signed 32-bit value into 64 bits, use `movsxd rax, eax` or `cdqe` (which does the same thing). |

## Check yourself

1. After `add rax, rbx`, which flag tells you if unsigned overflow occurred? Which flag tells you if signed overflow occurred?
2. You want to divide `rax` by 10 using unsigned division. What instruction must you execute before `div` to set up `rdx`, and why?
3. Trace the worked example above with a positive dividend (`42` instead of `-42`). What is in `rdx` after `cqo`? What is the quotient and remainder? What exit code does the program produce?
4. Why does `test rax, rax` followed by checking ZF let you determine if `rax` is zero? What does `test` compute, and when is the result zero?
5. You compare `rax` and `rbx` with `cmp rax, rbx` and want to set `al` to 1 if `rax > rbx` (signed). Which `setcc` instruction do you use?

## Key takeaways

- Arithmetic instructions update FLAGS (ZF, SF, CF, OF) to record properties of the result; read these flags to make decisions without storing the result.
- Signed and unsigned arithmetic use different instructions for multiply and divide because negative values change the high-order bits; using the wrong instruction produces silent errors.
- Division requires setting up `rdx:rax` as the dividend: use `cqo` (sign-extend) before `idiv` for signed, or `xor rdx, rdx` (zero) before `div` for unsigned — forgetting this is the most common division bug.
- `cmp a, b` computes `a - b` and sets flags without storing the result; use it for comparisons. `test a, b` computes `a & b` and sets flags; use it for zero checks and bit tests.
- The `setcc` family materializes boolean values (0 or 1) from flag states; use `sete`/`setne` for equality, `setl`/`setg`/`setle`/`setge` for signed comparisons, and `setb`/`seta`/`setbe`/`setae` for unsigned comparisons.
- ZF means the result is zero; SF means the sign bit is set (negative if signed); CF means unsigned overflow; OF means signed overflow.

## Lookup

- **Arithmetic instructions:** Intel® 64 and IA-32 Architectures Software Developer's Manual, Volume 2 (Instruction Set Reference), entries for `add`, `sub`, `imul`, `mul`, `idiv`, `div`, `cqo`, `setcc`
- **FLAGS register:** Volume 1, Chapter 3.4 (RFLAGS register layout and flag descriptions)
- **Division exceptions:** Volume 1, Chapter 6 (divide error `#DE`)
- **NASM syntax:** NASM manual, Appendix B (instruction reference)

## Exercises

28 drills covering arithmetic, flags, setcc, mul/div, bug hunts, Project-Euler-lite sums.
