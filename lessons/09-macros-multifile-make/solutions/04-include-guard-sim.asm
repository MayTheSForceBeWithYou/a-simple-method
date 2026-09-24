; Exercise 04: include guard sim
;
; Use %ifndef/%define for ANSWER equ 42; exit 42.
;
; Build: nasm -f elf64 04-include-guard-sim.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
%ifndef ANSWER
%define ANSWER 42
%endif
section .text
    global _start
_start:
    mov rdi, ANSWER
    mov rax, 60
    syscall
