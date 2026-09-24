; Exercise 23: stretch factorial5
;
; STRETCH: 5! = 120 using successive imul. Exit 120.
;
; Build: nasm -f elf64 23-stretch-factorial5.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 1
    imul rax, 2
    imul rax, 3
    imul rax, 4
    imul rax, 5
    mov rdi, rax
    mov rax, 60
    syscall
