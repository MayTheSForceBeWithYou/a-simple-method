; Exercise 28: from scratch expr
;
; FROM SCRATCH: exit status = (12*12 - 100) / 4 + 1 = 12. Show work with idiv.
;
; Build: nasm -f elf64 28-from-scratch-expr.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 12
    imul rax, 12
    sub rax, 100
    cqo
    mov rbx, 4
    idiv rbx
    add rax, 1
    mov rdi, rax
    mov rax, 60
    syscall
