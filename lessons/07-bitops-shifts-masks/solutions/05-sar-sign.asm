; Exercise 05: sar sign
;
; rax=-8; sar 1; exit with al of result (-4 -> 252 unsigned status).
;
; Build: nasm -f elf64 05-sar-sign.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, -8
    sar rax, 1
    movzx rdi, al
    mov rax, 60
    syscall
