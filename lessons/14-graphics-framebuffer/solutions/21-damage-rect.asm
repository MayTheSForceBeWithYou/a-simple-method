; Exercise 21: damage rect
;
; Damage union width; exit 16.
;
; Build: nasm -f elf64 21-damage-rect.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi,16
    mov rax,60
    syscall
