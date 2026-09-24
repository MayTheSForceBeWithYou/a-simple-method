; Exercise 11: recursion fact
;
; Recursive fact(4)=24. Preserve regs properly. Exit 24.
;
; Build: nasm -f elf64 11-recursion-fact.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 4
    call fact
    mov rdi, rax
    mov rax, 60
    syscall

fact:
    cmp rdi, 1
    jle .base
    push rdi
    dec rdi
    call fact
    pop rdi
    imul rax, rdi
    ret
.base:
    mov rax, 1
    ret
