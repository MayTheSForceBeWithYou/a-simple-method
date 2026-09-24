; Exercise 17: precedence
;
; Encode * binds tighter: 2+3*4 = 14; exit 14.
;
; Build: nasm -f elf64 17-precedence.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax,3
    imul rax,4
    add rax,2
    mov rdi,rax
    mov rax,60
    syscall
