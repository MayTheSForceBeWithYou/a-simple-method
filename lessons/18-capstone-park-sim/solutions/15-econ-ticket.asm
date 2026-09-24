; Exercise 15: econ ticket
;
; cash += ticket 15; from 0 exit 15.
;
; Build: nasm -f elf64 15-econ-ticket.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    cash resq 1
section .text
    global _start
_start:
    add qword [cash],15
    mov rdi,[cash]
    mov rax,60
    syscall
