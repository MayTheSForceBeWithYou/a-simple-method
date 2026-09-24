; Exercise 01: define const
;
; %define EXIT 60; exit 0.
;
; Build: nasm -f elf64 01-define-const.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
%define SYS_EXIT 60
section .text
    global _start
_start:
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall
