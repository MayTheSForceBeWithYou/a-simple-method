; Exercise 21: index loop prep
;
; arr db 7,8,9. Without loops yet: sum using three scaled/byte loads into rdi (24).
;
; Build: nasm -f elf64 21-index-loop-prep.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    arr db 7, 8, 9

section .text
    global _start
_start:
    xor rdi, rdi
    movzx rax, byte [arr]
    add rdi, rax
    movzx rax, byte [arr+1]
    add rdi, rax
    movzx rax, byte [arr+2]
    add rdi, rax
    mov rax, 60
    syscall
