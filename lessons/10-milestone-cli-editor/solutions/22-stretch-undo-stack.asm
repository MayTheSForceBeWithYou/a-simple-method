; Exercise 22: stretch undo stack
;
; STRETCH: push op code 1 then 2; pop once; exit top 1.
;
; Build: nasm -f elf64 22-stretch-undo-stack.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    ustk resq 8
    usp resq 1
section .text
    global _start
_start:
    mov qword [usp],0
    mov rcx,[usp]
    mov qword [ustk+rcx*8],1
    inc qword [usp]
    mov rcx,[usp]
    mov qword [ustk+rcx*8],2
    inc qword [usp]
    dec qword [usp]
    mov rcx,[usp]
    dec rcx
    mov rdi,[ustk+rcx*8]
    mov rax,60
    syscall
