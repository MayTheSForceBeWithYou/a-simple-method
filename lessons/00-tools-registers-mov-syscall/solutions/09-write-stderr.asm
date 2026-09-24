; Exercise 09: write stderr
;
; Write "error\n" to stderr (fd 2), exit 1.
;
; Build: nasm -f elf64 09-write-stderr.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    msg db "error", 10
    msg_len equ $ - msg

section .text
    global _start
_start:
    mov rax, 1
    mov rdi, 2
    mov rsi, msg
    mov rdx, msg_len
    syscall
    mov rax, 60
    mov rdi, 1
    syscall
