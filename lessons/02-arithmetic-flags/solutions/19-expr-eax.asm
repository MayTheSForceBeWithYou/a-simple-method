; Exercise 19: expr eax
;
; Compute (3+5)*7-8 into rdi (48).
;
; Build: nasm -f elf64 19-expr-eax.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 3
    add rax, 5
    imul rax, 7
    sub rax, 8
    mov rdi, rax
    mov rax, 60
    syscall
