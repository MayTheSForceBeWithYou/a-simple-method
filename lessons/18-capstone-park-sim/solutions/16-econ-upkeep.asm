; Exercise 16: econ upkeep
;
; cash -= 3; from 10 exit 7.
;
; Build: nasm -f elf64 16-econ-upkeep.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    cash resq 1
section .text
    global _start
_start:
    mov qword [cash],10
    sub qword [cash],3
    mov rdi,[cash]
    mov rax,60
    syscall
