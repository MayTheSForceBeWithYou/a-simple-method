; Exercise 07: idiv setup
;
; Divide 84 by 2 using idiv. cqo; idiv. Exit with quotient in rdi.
;
; Build: nasm -f elf64 07-idiv-setup.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 84
    cqo
    mov rbx, 2
    idiv rbx
    mov rdi, rax
    mov rax, 60
    syscall
