; Exercise 24: overwrite data
;
; msg db 'x',10. Change first byte to 'Y' in place, write 2 bytes, exit 0.
;
; Build: nasm -f elf64 24-overwrite-data.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .data
    msg db "x", 10

section .text
    global _start
_start:
    mov byte [msg], 'Y'
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, 2
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall
