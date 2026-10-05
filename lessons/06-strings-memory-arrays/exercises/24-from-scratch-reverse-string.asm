; Exercise 24: from scratch reverse string
;
; FROM SCRATCH: reverse "asm" in place; first byte should be "m"=109.
;
; Build: nasm -f elf64 24-from-scratch-reverse-string.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    s db "asm",0
section .text
    global _start
_start:
    lea rdi, [s]
    call strlen
    mov rsi, rax
    lea rdi, [s]
    call rev
    movzx rdi, byte [s]
    mov rax, 60
    syscall
strlen:
    ; TODO: implement strlen
rev:
    ; TODO: implement rev
