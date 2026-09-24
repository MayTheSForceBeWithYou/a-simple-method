; Exercise 17: macro stringize
;
; NASM %%str: %%define S 'Q'; db and write length 1+nl exit 0.
;
; Build: nasm -f elf64 17-macro-stringize.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .data
    m db "Q",10
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
