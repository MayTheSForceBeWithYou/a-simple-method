; Exercise 04: delete backspace
;
; len=2; backspace; exit len 1.
;
; Build: nasm -f elf64 04-delete-backspace.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    len resq 1
section .text
    global _start
_start:
    mov qword [len], 2
    cmp qword [len], 0
    je .o
    dec qword [len]
.o:
    mov rdi, [len]
    mov rax, 60
    syscall
