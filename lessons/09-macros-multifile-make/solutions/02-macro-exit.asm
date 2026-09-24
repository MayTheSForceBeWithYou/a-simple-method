; Exercise 02: macro exit
;
; %macro exit_with 1 ... %endmacro; exit 7.
;
; Build: nasm -f elf64 02-macro-exit.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
%macro exit_with 1
    mov rax, 60
    mov rdi, %1
    syscall
%endmacro
section .text
    global _start
_start:
    exit_with 7
