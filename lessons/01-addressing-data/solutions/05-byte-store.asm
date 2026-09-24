; Exercise 05: byte store
;
; buf: 2 bytes. Store "O" and "K", write both + you may add newline as third byte or write 2 then "\n". Exit 0.
;
; Build: nasm -f elf64 05-byte-store.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .data
    buf db 0, 0, 10

section .text
    global _start
_start:
    mov byte [buf], 'O'
    mov byte [buf+1], 'K'
    mov rax, 1
    mov rdi, 1
    mov rsi, buf
    mov rdx, 3
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall
