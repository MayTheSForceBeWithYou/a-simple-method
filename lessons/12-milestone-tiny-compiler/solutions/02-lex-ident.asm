; Exercise 02: lex ident
;
; Accept first char alpha; 'a' -> 1.
;
; Build: nasm -f elf64 02-lex-ident.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov al, 'a'
    cmp al, 'a'
    jb .n
    cmp al, 'z'
    ja .n
    mov rdi, 1
    jmp .o
.n:
    xor rdi, rdi
.o:
    mov rax, 60
    syscall
