; Exercise 12: recursion fib
;
; Naive fib(7)=13. Exit 13. (OK if slow.)
;
; Build: nasm -f elf64 12-recursion-fib.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 7
    call fib
    mov rdi, rax
    mov rax, 60
    syscall

fib:
    cmp rdi, 1
    jle .base
    push rdi
    dec rdi
    call fib
    pop rdi
    push rax
    sub rdi, 2
    call fib
    pop rdx
    add rax, rdx
    ret
.base:
    mov rax, rdi
    ret
