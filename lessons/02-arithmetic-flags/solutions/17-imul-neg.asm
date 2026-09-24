; Exercise 17: imul neg
;
; rax=-3; imul rax, -4; mov rdi,rax; exit 12.
;
; Build: nasm -f elf64 17-imul-neg.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, -3
    imul rax, -4
    mov rdi, rax
    mov rax, 60
    syscall
