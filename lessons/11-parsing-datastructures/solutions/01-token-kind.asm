; Exercise 01: token kind
;
; Token kinds as equ; exit TK_NUM=1.
;
; Build: nasm -f elf64 01-token-kind.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
TK_EOF equ 0
TK_NUM equ 1
section .text
    global _start
_start:
    mov rdi, TK_NUM
    mov rax, 60
    syscall
