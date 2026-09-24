; Exercise 08: two writes
;
; Write "alpha\n" then "beta\n" with two write syscalls. Exit 0.
;
; Build: nasm -f elf64 08-two-writes.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .data
    a db "alpha", 10
    a_len equ $ - a
    b db "beta", 10
    b_len equ $ - b

section .text
    global _start
_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, a
    mov rdx, a_len
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, b
    mov rdx, b_len
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall
