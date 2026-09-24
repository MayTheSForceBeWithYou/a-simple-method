; Exercise 02: rodata string
;
; Put "rodata\n" in .rodata, write it, exit 0.
;
; Build: nasm -f elf64 02-rodata-string.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .rodata
    msg db "rodata", 10
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
