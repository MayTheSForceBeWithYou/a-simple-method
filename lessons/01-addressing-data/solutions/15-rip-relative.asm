; Exercise 15: rip relative
;
; Use lea rsi,[rel msg] to write msg 'rip\n'. Exit 0. (Works with default nasm rel if default ABS — use [rel] explicitly.)
;
; Build: nasm -f elf64 15-rip-relative.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
default rel

section .data
    msg db "rip", 10
    msg_len equ $ - msg

section .text
    global _start
_start:
    mov rax, 1
    mov rdi, 1
    lea rsi, [msg]
    mov rdx, msg_len
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall
