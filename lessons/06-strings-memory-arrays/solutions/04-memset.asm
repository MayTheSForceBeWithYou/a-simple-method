; Exercise 04: memset
;
; memset 4 bytes to 7; sum=28; exit 28.
;
; Build: nasm -f elf64 04-memset.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    buf resb 4
section .text
    global _start
_start:
    lea rdi, [buf]
    mov rsi, 7
    mov rdx, 4
    call memset
    xor rdi, rdi
    movzx rax, byte [buf]
    add rdi, rax
    movzx rax, byte [buf+1]
    add rdi, rax
    movzx rax, byte [buf+2]
    add rdi, rax
    movzx rax, byte [buf+3]
    add rdi, rax
    mov rax, 60
    syscall
memset:
.l:
    cmp rdx, 0
    je .d
    mov [rdi], sil
    inc rdi
    dec rdx
    jmp .l
.d:
    ret
