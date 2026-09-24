; Exercise 14: memchr
;
; Find 7 in bytes 3,5,7,9; index 2.
;
; Build: nasm -f elf64 14-memchr.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    buf db 3,5,7,9
section .text
    global _start
_start:
    lea rdi, [buf]
    mov rsi, 7
    mov rdx, 4
    call memchr_idx
    mov rdi, rax
    mov rax, 60
    syscall
memchr_idx:
    xor rax, rax
.l:
    cmp rax, rdx
    jge .m
    movzx rcx, byte [rdi+rax]
    cmp rcx, rsi
    je .h
    inc rax
    jmp .l
.m:
    mov rax, 255
.h:
    ret
