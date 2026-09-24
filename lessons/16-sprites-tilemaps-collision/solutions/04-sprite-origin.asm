; Exercise 04: sprite origin
;
; screen = world - camera; 50-20=30.
;
; Build: nasm -f elf64 04-sprite-origin.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 50
    sub rdi, 20
    mov rax, 60
    syscall
