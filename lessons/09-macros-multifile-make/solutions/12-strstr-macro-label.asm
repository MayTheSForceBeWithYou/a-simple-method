; Exercise 12: macro local labels
;
; %macro TWICE 0 inc rdi / inc rdi %endmacro; exit 2.
;
; Build: nasm -f elf64 12-strstr-macro-label.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
%macro TWICE 0
    inc rdi
    inc rdi
%endmacro
section .text
    global _start
_start:
    xor rdi,rdi
    TWICE
    mov rax,60
    syscall
