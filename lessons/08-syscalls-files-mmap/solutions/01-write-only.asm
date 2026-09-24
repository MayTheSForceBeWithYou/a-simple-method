; Exercise 01: write only
;
; Review write; print 'io\n'; exit 0.
;
; Build: nasm -f elf64 01-write-only.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .data
    m db "io",10
    n equ $-m
section .text
    global _start
_start:
    mov rax,1
    mov rdi,1
    mov rsi,m
    mov rdx,n
    syscall
    mov rax,60
    xor rdi,rdi
    syscall
