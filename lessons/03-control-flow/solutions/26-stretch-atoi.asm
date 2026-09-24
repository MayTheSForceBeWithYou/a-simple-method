; Exercise 26: stretch atoi
;
; STRETCH: parse "42" decimal ascii into rdi (42) with a loop.
;
; Build: nasm -f elf64 26-stretch-atoi.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    s db "42", 0

section .text
    global _start
_start:
    lea rsi, [s]
    xor rdi, rdi
.loop:
    movzx rax, byte [rsi]
    test rax, rax
    jz .done
    sub rax, '0'
    imul rdi, 10
    add rdi, rax
    inc rsi
    jmp .loop
.done:
    mov rax, 60
    syscall
