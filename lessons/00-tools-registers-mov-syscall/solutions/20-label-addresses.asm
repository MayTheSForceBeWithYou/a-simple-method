; Exercise 20: label addresses
;
; Two messages; print only msg2 "use me\n". Exit 0.
;
; Build: nasm -f elf64 20-label-addresses.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .data
    msg1 db "skip", 10
    msg2 db "use me", 10
    msg2_len equ $ - msg2

section .text
    global _start
_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg2
    mov rdx, msg2_len
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall
