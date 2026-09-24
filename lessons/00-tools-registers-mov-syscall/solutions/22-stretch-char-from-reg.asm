; Exercise 22: stretch char from reg
;
; Set bl=0x5A ('Z'). Store into a 2-byte buffer (char + newline), write it, exit 0.
;
; Build: nasm -f elf64 22-stretch-char-from-reg.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .data
    buf db 0, 10

section .text
    global _start
_start:
    mov bl, 0x5A
    mov [buf], bl
    mov rax, 1
    mov rdi, 1
    mov rsi, buf
    mov rdx, 2
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall
