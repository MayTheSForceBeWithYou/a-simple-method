; Exercise 28: from scratch swap
;
; FROM SCRATCH: a dq 1 / b dq 2. Swap via registers; exit with rdi=a (should be 2).
;
; Build: nasm -f elf64 28-from-scratch-swap.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    a dq 1
    b dq 2

section .text
    global _start
_start:
    mov rax, [a]
    mov rdx, [b]
    mov [a], rdx
    mov [b], rax
    mov rdi, [a]
    mov rax, 60
    syscall
