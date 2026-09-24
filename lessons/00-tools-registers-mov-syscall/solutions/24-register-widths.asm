; Exercise 24: register widths
;
; rax=0x1111222233334444; mov ax,0xABCD; exit with movzx rdi,al (205).
;
; Build: nasm -f elf64 24-register-widths.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 0x1111222233334444
    mov ax, 0xABCD
    movzx rdi, al
    mov rax, 60
    syscall
