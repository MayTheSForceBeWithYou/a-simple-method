; Exercise 13: debug bad length
;
; BUG HUNT: Writes "Hi\n" but rdx length too short. Fix via equ.
;
; Build: nasm -f elf64 13-debug-bad-length.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .data
    msg db "Hi", 10

section .text
    global _start
_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, 2
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall
