; Exercise 02: read stdin one
;
; STUB design: read 1 byte from fd0 into buf; exit that byte (run with printf 'A' | ). Solution exits 0 if read fails.
;
; Build: nasm -f elf64 02-read-stdin-one.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    b resb 1
section .text
    global _start
_start:
    mov rax, 0
    mov rdi, 0
    mov rsi, b
    mov rdx, 1
    syscall
    cmp rax, 1
    jne .fail
    movzx rdi, byte [b]
    mov rax, 60
    syscall
.fail:
    mov rax, 60
    xor rdi, rdi
    syscall
