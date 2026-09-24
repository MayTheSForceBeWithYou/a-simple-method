; Exercise 17: dup concept
;
; Without dup: write to fd1; exit 0. Documents fd reuse.
;
; Build: nasm -f elf64 17-dup-concept.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .data
    m db "d",10
section .text
    global _start
_start:
    mov rax,1
    mov rdi,1
    mov rsi,m
    mov rdx,2
    syscall
    xor rdi,rdi
    mov rax,60
    syscall
