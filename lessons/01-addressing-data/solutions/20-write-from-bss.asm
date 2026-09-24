; Exercise 20: write from bss
;
; Fill 4-byte bss with 'Z',0x0A,'Z',0x0A. Write 4 bytes. Exit 0.
;
; Build: nasm -f elf64 20-write-from-bss.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .bss
    buf resb 4

section .text
    global _start
_start:
    mov byte [buf], 'Z'
    mov byte [buf+1], 10
    mov byte [buf+2], 'Z'
    mov byte [buf+3], 10
    mov rax, 1
    mov rdi, 1
    mov rsi, buf
    mov rdx, 4
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall
