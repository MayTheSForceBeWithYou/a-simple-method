; Exercise 22: stretch units header
;
; STRETCH: %define SYS_WRITE 1 / SYS_EXIT 60; print "U\n" exit 0.
;
; Build: nasm -f elf64 22-stretch-units-header.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
%define SYS_WRITE 1
%define SYS_EXIT 60
section .data
    m db "U",10
section .text
    global _start
_start:
    mov rax, SYS_WRITE
    mov rdi,1
    mov rsi,m
    mov rdx,2
    syscall
    mov rax, SYS_EXIT
    xor rdi,rdi
    syscall
