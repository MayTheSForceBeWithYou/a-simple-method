# Lesson 13 — FP, SIMD, Fixed-point

## Learning objectives

1. Place an integer in Q16.16 with `shl` by 16, and a half with `1<<15`.
2. Add fixed values with one shift back, and multiply them knowing the fraction bits add.
3. Divide a Q16.16 pair by widening before `idiv`, then shifting back.
4. Clamp, wrap an angle, and take a dot product in integers.
5. Treat the SSE drills as scalar stubs. These files do not execute `addss`.

A Q-format keeps the fraction in the low bits of an integer. That is the whole numeric model in this lesson. Pixels and a framebuffer are lesson 14. Do not load `xmm` to satisfy a prompt the solution ignores.

## Q16.16

`n` as Q16.16 is `n<<16`. `0.5` is `1<<15`. Adding two fixed values does not change the scale, so one `shr` by 16 recovers the integer. `1.5+2.5` exits 4.

```asm
section .text
global _start
_start:
    mov eax, (1<<16)+(1<<15) ; 1.5
    mov ebx, (2<<16)+(1<<15) ; 2.5
    add eax, ebx
    shr eax, 16
    mov edi, eax            ; 4
    mov rax, 60
    syscall
```

That is `02-fixed-add.asm`. Two halves are `1.0`, and `10-q16-frac.asm` exits 1. `09-q16-from-int.asm` shifts 5 up and back down and exits 5. `06-shift-div.asm` is `sar` of 20 by 2, exit 5, not a Q divide.

Multiplying two Q16.16 values yields 32 fraction bits. One `shr rax, 16` returns to Q16.16. A second `shr` returns to an integer. `01-fixed-mul.asm` does only the first shift. The register holds `6<<16` (393216). The exit status is the low 8 bits, which are 0. The prompt says exit 6. The solution exits 0.

```asm
section .text
global _start
_start:
    mov eax, 2
    shl eax, 16
    mov ebx, 3
    shl ebx, 16
    movsxd rax, eax
    movsxd rbx, ebx
    imul rax, rbx
    shr rax, 16             ; Q16.16 6.0, not the integer 6
    mov rdi, rax            ; status 0
    mov rax, 60
    syscall
```

`19-debug-q-shift.asm` is that multiply with both shifts. The bug listing masks the unshifted product with 255 and would exit 0 for a different reason. The fix exits 6.

```asm
section .text
global _start
_start:
    mov eax, 2
    shl eax, 16
    mov ebx, 3
    shl ebx, 16
    movsxd rax, eax
    movsxd rbx, ebx
    imul rax, rbx
    shr rax, 16
    shr rax, 16             ; integer
    mov rdi, rax            ; 6
    mov rax, 60
    syscall
```

Q8.8 uses 8 fraction bits. `08-from-scratch-q8.asm` multiplies `1.5` by `2` and shifts once by 8. The register is `3<<8` (768). The prompt says exit 3. The status is 0. `24-from-scratch-q8-mul.asm` is `2.5*2` shifted once: register 1280, status 0. A second shift is how you would print the integer. It is not what those two files do.

## Divide, lerp, clamp

Q16 division widens the dividend by another 16 bits before `idiv`, then shifts back. `11-fixed-div.asm` divides `6<<16` by `2<<16` and exits 3. Sign-extend with `cqo` before `idiv`. `movsxd` first, because the Q value was built in `eax`.

Lerp from 0 toward `10<<16` with `t = 1<<15` is a multiply and two shifts. `15-lerp-fixed.asm` exits 5. Clamp `10<<16` down to `8<<16` and shift: exit 8 (`04-clamp-fixed.asm`). Clamp the integer `-3` into `[0,100]`: exit 0 (`16-clamp-q.asm`). An angle of 350 plus 20 wraps by subtracting 360: exit 10 (`18-fixed-angle-step.asm`). A reciprocal stub in `21-fast-inv-stub.asm` is `shr` of 10 by 1, exit 5. It is not a Newton iteration.

## Dots, and the SIMD that is not here

`(1,2)·(3,4)` is 11 (`05-dot2-fixed.asm`). `(1,2,3)·(4,5,6)` is 32 (`20-dot3.asm`). Length squared of `(3,4)` is 25, not 5 (`14-vec2-length2.asm`). A 2×2 identity times `(3,4)` is the constant 3 in `22-stretch-matrix2-mul.asm`. The file does not load a matrix. A sine table of qwords `0,1,0` exits the middle entry, 1 (`23-stretch-sin-lut.asm`).

`03-sse-add-scalar.asm` exits 5. `12-sse-movss-stub.asm` exits 1. Neither issues `addss`, `movss`, or `movaps`. `07-simd-lane-sum-stub.asm` adds the bytes `1,2,3,4` and exits 10. `17-simd-horizontal-stub.asm` adds the dwords `1,2,3,4` and exits 10. Horizontal SIMD is a scalar add until a later program actually uses `xmm`. `13-pack-rgba8888.asm` exits 255. It does not shift G, B, or A into the dword. The low byte is R only because 255 already sits there.

## Exercises

24 drills under `exercises/`. Solutions mirror the names in `solutions/`. Build with `nasm -f elf64 FILE -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?`.

Q format: `01-fixed-mul.asm` (status 0, register `6<<16`), `02-fixed-add.asm`, `08-from-scratch-q8.asm` (status 0), `09-q16-from-int.asm`, `10-q16-frac.asm`, `11-fixed-div.asm` (exit 3), `15-lerp-fixed.asm`, `19-debug-q-shift.asm` (exit 6), `24-from-scratch-q8-mul.asm` (status 0). Integer geometry: `04-clamp-fixed.asm`, `05-dot2-fixed.asm`, `06-shift-div.asm`, `14-vec2-length2.asm`, `16-clamp-q.asm`, `18-fixed-angle-step.asm`, `20-dot3.asm`, `21-fast-inv-stub.asm`, `22-stretch-matrix2-mul.asm` (exit 3, no matrix), `23-stretch-sin-lut.asm`. Not SSE: `03-sse-add-scalar.asm` (exit 5), `07-simd-lane-sum-stub.asm`, `12-sse-movss-stub.asm` (exit 1), `13-pack-rgba8888.asm` (exit 255), `17-simd-horizontal-stub.asm`.