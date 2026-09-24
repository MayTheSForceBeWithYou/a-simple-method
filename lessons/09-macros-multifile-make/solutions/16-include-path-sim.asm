; Exercise 16: include path sim
;
; %define VERSION 3; exit VERSION.
;
; Build: nasm -f elf64 16-include-path-sim.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
%define VERSION 3
section .text
    global _start
_start:
    mov rdi, VERSION
    mov rax,60
    syscall
