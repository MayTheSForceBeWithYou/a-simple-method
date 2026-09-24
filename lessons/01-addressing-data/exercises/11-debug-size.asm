; Exercise 11: debug size
;
; BUG: mov [buf], 1 ambiguous/wrong. Store byte 1, load movzx rdi, exit.
;
; Build: nasm -f elf64 11-debug-size.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    buf resb 1

section .text
    global _start
_start:
    mov [buf], 1
    movzx rdi, byte [buf]
    mov rax, 60
    syscall
