; Exercise 10: macro syscall
;
; %macro SYSCALL3 0 ... uses rax rdi rsi rdx already set; exit after write. Print "K\n" exit 0.
;
; Build: nasm -f elf64 10-macro-syscall.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
%macro SYSCALL0 0
    syscall
%endmacro
section .data
    m db "K",10
section .text
    global _start
_start:
    mov rax,1
    mov rdi,1
    mov rsi,m
    mov rdx,2
    SYSCALL0
    mov rax,60
    xor rdi,rdi
    SYSCALL0
