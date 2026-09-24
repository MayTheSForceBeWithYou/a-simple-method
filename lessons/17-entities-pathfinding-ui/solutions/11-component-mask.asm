; Exercise 11: component mask
;
; Has POS|VEL = 3; exit 3.
;
; Build: nasm -f elf64 11-component-mask.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
POS equ 1
VEL equ 2
section .text
    global _start
_start:
    mov rdi,POS
    or rdi,VEL
    mov rax,60
    syscall
