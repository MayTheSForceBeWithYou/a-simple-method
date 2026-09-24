; Exercise 16: repeat delay
;
; Key repeat after 3 ticks; tick count 3 -> fire; exit 1.
;
; Build: nasm -f elf64 16-repeat-delay.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    held resq 1
section .text
    global _start
_start:
    mov qword [held],3
    cmp qword [held],3
    jl .n
    mov rdi,1
    jmp .o
.n:
    xor rdi,rdi
.o:
    mov rax,60
    syscall
