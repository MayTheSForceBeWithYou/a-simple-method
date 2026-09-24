; Exercise 18: default rel macro
;
; default rel; lea rsi,[msg]; write hi; exit 0.
;
; Build: nasm -f elf64 18-default-rel-macro.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
default rel
section .data
    msg db "hi",10
    n equ $-msg
section .text
    global _start
_start:
    mov rax,1
    mov rdi,1
    lea rsi,[msg]
    mov rdx,n
    syscall
    xor rdi,rdi
    mov rax,60
    syscall
