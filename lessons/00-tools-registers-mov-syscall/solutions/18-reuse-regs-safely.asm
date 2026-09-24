; Exercise 18: reuse regs safely
;
; Write "ok\n", then exit 0. Re-load syscall numbers after write (rax is return value).
;
; Build: nasm -f elf64 18-reuse-regs-safely.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    msg db "ok", 10
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
