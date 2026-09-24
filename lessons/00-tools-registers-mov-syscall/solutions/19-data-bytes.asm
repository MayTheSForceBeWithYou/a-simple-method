; Exercise 19: data bytes
;
; Emit bytes 0x48 0x69 0x0A (Hi newline) using db. Write them; exit 0.
;
; Build: nasm -f elf64 19-data-bytes.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .data
    msg db 0x48, 0x69, 0x0A
    msg_len equ $ - msg

section .text
    global _start
_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, msg_len
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall
