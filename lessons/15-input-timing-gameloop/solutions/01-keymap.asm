; Exercise 01: keymap
;
; If key 'W' set flag; exit 1.
;
; Build: nasm -f elf64 01-keymap.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov al, 'W'
    cmp al, 'W'
    jne .n
    mov rdi, 1
    jmp .o
.n:
    xor rdi, rdi
.o:
    mov rax, 60
    syscall
