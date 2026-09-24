; Exercise 03: parse let
;
; Recognize keyword first letter 'l' of let; exit 1.
;
; Build: nasm -f elf64 03-parse-let.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    kw db "let",0
section .text
    global _start
_start:
    cmp byte [kw], 'l'
    jne .n
    mov rdi, 1
    jmp .o
.n:
    xor rdi, rdi
.o:
    mov rax, 60
    syscall
