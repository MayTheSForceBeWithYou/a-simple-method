; Exercise 12: debug clobber rax
;
; BUG HUNT: Should write "X\n" then exit 0. rax set wrong before write. Fix.
;
; Build: nasm -f elf64 12-debug-clobber-rax.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .data
    msg db "X", 10
    msg_len equ $ - msg

section .text
    global _start
_start:
    mov rdi, 1
    mov rsi, msg
    mov rdx, msg_len
    mov rax, 60
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall
