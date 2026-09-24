; Exercise 06: path step
;
; Follow next cell delta x+1; exit 1.
;
; Build: nasm -f elf64 06-path-step.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 1
    mov rax, 60
    syscall
