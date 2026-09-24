; Exercise 13: shl combine
;
; Build 0xAB by (0xA<<4)|0xB; exit 0xAB=171.
;
; Build: nasm -f elf64 13-shl-shl-combine.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 0xA
    shl rax, 4
    or rax, 0xB
    mov rdi, rax
    mov rax,60
    syscall
