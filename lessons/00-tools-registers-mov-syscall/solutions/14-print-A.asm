; Exercise 14: print A
;
; Write "A\n". Exit 0.
;
; Build: nasm -f elf64 14-print-A.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .data
    msg db "A", 10
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
