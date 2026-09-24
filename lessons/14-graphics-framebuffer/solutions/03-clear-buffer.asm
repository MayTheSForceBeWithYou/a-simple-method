; Exercise 03: clear buffer
;
; Clear 8 bytes to 0; exit first byte 0.
;
; Build: nasm -f elf64 03-clear-buffer.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    fb resb 8
section .text
    global _start
_start:
    lea rdi, [fb]
    mov rcx, 8
    xor rax, rax
    rep stosb
    movzx rdi, byte [fb]
    mov rax, 60
    syscall
