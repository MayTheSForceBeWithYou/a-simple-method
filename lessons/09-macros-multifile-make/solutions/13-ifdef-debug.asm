; Exercise 13: ifdef debug
;
; %define DEBUG; %ifdef DEBUG mov rdi,1 %else 0; exit 1.
;
; Build: nasm -f elf64 13-ifdef-debug.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
%define DEBUG
section .text
    global _start
_start:
%ifdef DEBUG
    mov rdi,1
%else
    xor rdi,rdi
%endif
    mov rax,60
    syscall
