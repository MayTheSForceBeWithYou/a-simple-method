; Exercise 03: xor swap
;
; xor-swap rax=1 rbx=2; exit rax (2).
;
; Build: nasm -f elf64 03-xor-swap.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 1
    mov rbx, 2
    xor rax, rbx
    xor rbx, rax
    xor rax, rbx
    mov rdi, rax
    mov rax, 60
    syscall
