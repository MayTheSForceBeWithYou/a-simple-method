; Exercise 09: fib iter proc
;
; Iterative fib(n) as procedure. fib(10)=55; exit 55.
;
; Build: nasm -f elf64 09-fib-iter-proc.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 10
    call fib
    mov rdi, rax
    mov rax, 60
    syscall
fib:
    ; TODO: implement fib
