; Exercise 17: void side effect
;
; Procedure writes byte '!' and newline to a global buf via args (rsi=buf). Then write syscall from _start. Exit 0.
;
; Build: nasm -f elf64 17-void-side-effect.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .data
    buf db 0, 10

section .text
    global _start
_start:
    mov dil, '!'
    lea rsi, [buf]
    call store_byte
    mov rax, 1
    mov rdi, 1
    mov rsi, buf
    mov rdx, 2
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall

store_byte:
    mov [rsi], dil
    ret
