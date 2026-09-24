; Exercise 21: min via cmovl
;
; Same with 17 and 23; min into rdi (17) using cmovl.
;
; Build: nasm -f elf64 21-min-via-cmovl.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 17
    mov rbx, 23
    mov rdi, rax
    cmp rbx, rdi
    cmovl rdi, rbx
    mov rax, 60
    syscall
