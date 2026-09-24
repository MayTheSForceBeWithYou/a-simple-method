; Exercise 24: from scratch write err
;
; FROM SCRATCH: write to fd=-1; expect error (rax<0); exit 1.
;
; Build: nasm -f elf64 24-from-scratch-write-err.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    m db "x"
section .text
    global _start
_start:
    mov rax,1
    mov rdi,-1
    lea rsi,[m]
    mov rdx,1
    syscall
    cmp rax,0
    jl .ok
    xor rdi,rdi
    jmp .o
.ok:
    mov rdi,1
.o:
    mov rax,60
    syscall
