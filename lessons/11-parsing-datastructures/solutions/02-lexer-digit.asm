; Exercise 02: lexer digit
;
; If byte '7' is digit exit 1.
;
; Build: nasm -f elf64 02-lexer-digit.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov al, '7'
    cmp al, '0'
    jb .n
    cmp al, '9'
    ja .n
    mov rdi, 1
    jmp .o
.n:
    xor rdi, rdi
.o:
    mov rax, 60
    syscall
