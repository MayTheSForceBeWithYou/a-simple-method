; Exercise 09: pointer walk
;
; bytes db 1,2,3,4. rsi=&bytes. Sum four byte loads with inc rsi into rdi, exit (10).
;
; Build: nasm -f elf64 09-pointer-walk.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    bytes db 1, 2, 3, 4

section .text
    global _start
_start:
    lea rsi, [bytes]
    xor rdi, rdi
    movzx rax, byte [rsi]
    add rdi, rax
    inc rsi
    movzx rax, byte [rsi]
    add rdi, rax
    inc rsi
    movzx rax, byte [rsi]
    add rdi, rax
    inc rsi
    movzx rax, byte [rsi]
    add rdi, rax
    mov rax, 60
    syscall
