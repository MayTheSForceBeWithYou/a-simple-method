; Exercise 21: debug macro arity
;
; BUG: macro invoked with wrong arg count conceptually; fix EXIT_STATUS 4.
;
; Build: nasm -f elf64 21-debug-macro-arity.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
%macro EXIT_STATUS 1
    mov rax,60
    mov rdi,%1
    syscall
%endmacro
section .text
    global _start
_start:
    EXIT_STATUS 4
