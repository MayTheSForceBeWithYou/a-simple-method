; Exercise 21: scenario goal
;
; Guests>=100 goal; guests=100; exit 1 success.
;
; Build: nasm -f elf64 21-scenario-goal.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    guests resq 1
section .text
    global _start
_start:
    mov qword [guests],100
    cmp qword [guests],100
    jl .n
    mov rdi,1
    jmp .o
.n:
    xor rdi,rdi
.o:
    mov rax,60
    syscall
