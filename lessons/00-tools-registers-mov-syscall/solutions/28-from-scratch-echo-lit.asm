; Exercise 28: from scratch echo lit
;
; FROM SCRATCH: Print "nasm+ld\n" and exit 0. Empty body on purpose.
;
; Build: nasm -f elf64 28-from-scratch-echo-lit.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .data
    msg db "nasm+ld", 10
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
