; Exercise 21: stretch banner
;
; STRETCH: Print a 3-line ASCII banner, exit 0.
;
; Build: nasm -f elf64 21-stretch-banner.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .data
    banner db "============", 10
           db "  ASM 00 OK ", 10
           db "============", 10
    banner_len equ $ - banner

section .text
    global _start
_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, banner
    mov rdx, banner_len
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall
