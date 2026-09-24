; Exercise 26: two exits dead
;
; Write "alive\n", exit 0, then dead exit 99 after (unreachable).
;
; Build: nasm -f elf64 26-two-exits-dead.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    msg db "alive", 10
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
    mov rax, 60
    mov rdi, 99
    syscall
