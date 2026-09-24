; Exercise 23: stretch bit reverse8
;
; STRETCH: reverse bits of 0b10000000 -> 1; exit 1.
;
; Build: nasm -f elf64 23-stretch-bit-reverse8.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    movzx eax, byte [v]
    xor ebx, ebx
    mov ecx, 8
.l:
    shl ebx, 1
    mov edx, eax
    and edx, 1
    or ebx, edx
    shr eax, 1
    loop .l
    mov edi, ebx
    mov rax,60
    syscall
section .data
    v db 0b10000000
