; Exercise 17: three lines
;
; Print "one\n" "two\n" "three\n". Exit 0.
;
; Build: nasm -f elf64 17-three-lines.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .data
    l1 db "one", 10
    n1 equ $ - l1
    l2 db "two", 10
    n2 equ $ - l2
    l3 db "three", 10
    n3 equ $ - l3

section .text
    global _start
_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, l1
    mov rdx, n1
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, l2
    mov rdx, n2
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, l3
    mov rdx, n3
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall
