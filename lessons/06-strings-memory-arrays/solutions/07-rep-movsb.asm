; Exercise 07: rep movsb
;
; Copy 5 bytes with rep movsb; checksum exit 15 for bytes 1..5.
;
; Build: nasm -f elf64 07-rep-movsb.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    src db 1,2,3,4,5
section .bss
    dst resb 5
section .text
    global _start
_start:
    lea rsi, [src]
    lea rdi, [dst]
    mov rcx, 5
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
    movzx rax, byte [dst+4]
    add rdi, rax
    mov rax, 60
    syscall
