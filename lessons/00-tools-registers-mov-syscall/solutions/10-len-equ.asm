; Exercise 10: len equ
;
; Define string "equ works\n" with db; length via equ $ - label. Write it; exit 0.
;
; Build: nasm -f elf64 10-len-equ.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .data
    msg db "equ works", 10
    msg_len equ $ - msg

section .text
    global _start
_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, msg_len
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall
