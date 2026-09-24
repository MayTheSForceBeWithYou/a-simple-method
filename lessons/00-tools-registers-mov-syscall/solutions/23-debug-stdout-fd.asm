; Exercise 23: debug stdout fd
;
; BUG HUNT: fd is 0. Fix to stdout.
;
; Build: nasm -f elf64 23-debug-stdout-fd.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .data
    msg db "visible", 10
    msg_len equ $ - msg

section .text
    global _start
_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, msg_len
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall
