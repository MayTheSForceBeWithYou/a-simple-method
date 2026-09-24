; Exercise 14: ride queue len
;
; Queue length 7; exit 7.
;
; Build: nasm -f elf64 14-ride-queue-len.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    qlen resq 1
section .text
    global _start
_start:
    mov qword [qlen],7
    mov rdi,[qlen]
    mov rax,60
    syscall
