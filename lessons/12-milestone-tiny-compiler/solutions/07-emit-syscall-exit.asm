; Exercise 07: emit syscall exit
;
; Hand-written 'codegen' template exits status 0.
;
; Build: nasm -f elf64 07-emit-syscall-exit.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 60
    xor rdi, rdi
    syscall
