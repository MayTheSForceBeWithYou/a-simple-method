; Exercise 22: stretch memcpy4
;
; STRETCH: src db 1,2,3,4. dst resb 4. Copy 4 bytes via register loads/stores. Sum dst into rdi (10).
;
; Build: nasm -f elf64 22-stretch-memcpy4.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    src db 1, 2, 3, 4
section .bss
    dst resb 4

section .text
    global _start
_start:
    mov al, [src]
    mov [dst], al
    mov al, [src+1]
    mov [dst+1], al
    mov al, [src+2]
    mov [dst+2], al
    mov al, [src+3]
    mov [dst+3], al
    xor rdi, rdi
    movzx rax, byte [dst]
    add rdi, rax
    movzx rax, byte [dst+1]
    add rdi, rax
    movzx rax, byte [dst+2]
    add rdi, rax
    movzx rax, byte [dst+3]
    add rdi, rax
    mov rax, 60
    syscall
