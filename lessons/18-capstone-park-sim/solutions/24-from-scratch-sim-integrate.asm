; Exercise 24: from scratch sim integrate
;
; FROM SCRATCH: one tick: place path, peep step, cash+=1; exit cash 1.
;
; Build: nasm -f elf64 24-from-scratch-sim-integrate.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    map resb 8
    peep_x resq 1
    cash resq 1
section .text
    global _start
_start:
    mov byte [map],1
    inc qword [peep_x]
    inc qword [cash]
    mov rdi,[cash]
    mov rax,60
    syscall
