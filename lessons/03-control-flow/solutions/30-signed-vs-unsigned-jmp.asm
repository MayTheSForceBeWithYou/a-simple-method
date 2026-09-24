; Exercise 30: signed vs unsigned jmp
;
; rax=0xFFFFFFFFFFFFFFFF (-1 signed), cmp to 1. Using jl should take less path exit 1; document why ja would not.
;
; Build: nasm -f elf64 30-signed-vs-unsigned-jmp.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, -1
    cmp rax, 1
    jl .less
    mov rdi, 0
    jmp .out
.less:
    mov rdi, 1
.out:
    mov rax, 60
    syscall
