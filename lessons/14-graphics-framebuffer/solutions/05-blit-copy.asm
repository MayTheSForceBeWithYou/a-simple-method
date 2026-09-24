; Exercise 05: blit copy
;
; Copy 4 bytes src->dst; sum exit 10.
;
; Build: nasm -f elf64 05-blit-copy.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    src db 1,2,3,4
section .bss
    dst resb 4
section .text
    global _start
_start:
    lea rsi, [src]
    lea rdi, [dst]
    mov rcx, 4
    rep movsb
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
