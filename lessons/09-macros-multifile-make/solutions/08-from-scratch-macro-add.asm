; Exercise 08: from scratch macro add
;
; FROM SCRATCH: %macro ADD_IMM reg,imm; use to build 40+2 exit 42.
;
; Build: nasm -f elf64 08-from-scratch-macro-add.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
%macro ADD_IMM 2
    add %1, %2
%endmacro
section .text
    global _start
_start:
    mov rdi, 40
    ADD_IMM rdi, 2
    mov rax, 60
    syscall
