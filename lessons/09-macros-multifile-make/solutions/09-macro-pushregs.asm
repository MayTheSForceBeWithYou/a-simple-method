; Exercise 09: macro pushregs
;
; %macro PUSH_CALLEE 0 push rbx push r12 %endmacro and pops; exit 5.
;
; Build: nasm -f elf64 09-macro-pushregs.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
%macro PUSH_CALLEE 0
    push rbx
    push r12
%endmacro
%macro POP_CALLEE 0
    pop r12
    pop rbx
%endmacro
section .text
    global _start
_start:
    mov rbx,5
    PUSH_CALLEE
    mov rbx,0
    POP_CALLEE
    mov rdi,rbx
    mov rax,60
    syscall
