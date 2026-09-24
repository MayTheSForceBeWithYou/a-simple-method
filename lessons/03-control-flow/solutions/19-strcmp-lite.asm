; Exercise 19: strcmp lite
;
; Compare 'ab' and 'ab' bytewise; exit 0 if equal else 1. Should exit 0.
;
; Build: nasm -f elf64 19-strcmp-lite.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    a db "ab", 0
    b db "ab", 0

section .text
    global _start
_start:
    lea rsi, [a]
    lea rdi, [b]
.loop:
    mov al, [rsi]
    mov dl, [rdi]
    cmp al, dl
    jne .ne
    test al, al
    jz .eq
    inc rsi
    inc rdi
    jmp .loop
.eq:
    xor rdi, rdi
    jmp .out
.ne:
    mov rdi, 1
.out:
    mov rax, 60
    syscall
