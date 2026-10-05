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
    ; TODO: implement fib
