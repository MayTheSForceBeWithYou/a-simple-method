; Exercise 17: label arith
;
; msg db 'A','B','C',10. Write only 'B' using msg+1 length 1, then write newline from msg+3. Exit 0.
;
; Build: nasm -f elf64 17-label-arith.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .data
    msg db "ABC", 10

section .text
    global _start
_start:
    mov rax, 1
    mov rdi, 1
    lea rsi, [msg+1]
    mov rdx, 1
    syscall
    mov rax, 1
    mov rdi, 1
    lea rsi, [msg+3]
    mov rdx, 1
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall
