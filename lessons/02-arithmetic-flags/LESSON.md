# Lesson 02 — Arithmetic & Flags

## Learning objectives

1. Use `add`, `sub`, `inc`, `dec`, `neg`, `imul`, `mul`, `idiv`, `div`.
2. Read ZF, SF, CF, OF after arithmetic/`cmp`/`test`.
3. Use `setcc` to materialize boolean bytes from flags.
4. Handle `rdx:rax` dividend setup for division.
5. Avoid signed/unsigned mix-ups.

## Integer arithmetic

```asm
add rdi, rsi
sub rax, 1
inc rcx
dec rcx
neg rax              ; two's complement negate
```

`inc`/`dec` update ZF/SF/OF but **not** CF (historical quirk).

### Multiply

```asm
imul rax, rbx        ; rax *= rbx (signed, 2-operand)
imul rcx, rdi, 5     ; rcx = rdi * 5
mul  rbx             ; unsigned: rdx:rax = rax * rbx
```

### Divide

`cqo` sign-extends `rax` into `rdx:rax`. That is the required dividend setup for signed `idiv`: the high half must carry the sign of the dividend, or the quotient is wrong. For unsigned `div` the setup is the opposite — `xor rdx, rdx` zeroes the high half instead.

```asm
; signed idiv divides rdx:rax by operand
mov rax, dividend
cqo                  ; high half of dividend = sign(rax)
idiv rbx             ; rax=quot, rdx=rem

; unsigned
mov rax, dividend
xor rdx, rdx
div rbx
```

Signed values that live in 32-bit registers need care when widened: any 32-bit write zeroes the upper 32 bits, so a plain `mov` into a 64-bit register destroys the sign of a negative dword. `movsxd rax, eax` sign-extends a 32-bit source into the full 64-bit destination, preserving the sign — unlike `movsx`, which requires an explicit source-size form. Use it whenever a signed dword must grow to a qword.

Divide by zero or overflow → `#DE` (SIGFPE).

## RFLAGS you need

| Flag | Set when |
|------|----------|
| ZF | result == 0 |
| SF | result sign bit set (msb) |
| CF | unsigned carry/borrow |
| OF | signed overflow |

`cmp a,b` is `a-b` discarding result but setting flags.  
`test a,b` is `a&b` discarding result (ZF/SF; clears CF/OF).

## setcc

```asm
cmp rax, rbx
sete al              ; al=1 if equal else 0
movzx rdi, al
```

Useful: `sete`, `setne`, `setl`, `setg`, `setb`, `seta`, …

## Exercises

28 drills covering arithmetic, flags, setcc, mul/div, bug hunts, Project-Euler-lite sums.
