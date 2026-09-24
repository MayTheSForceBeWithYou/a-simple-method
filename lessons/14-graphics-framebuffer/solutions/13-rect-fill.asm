; Exercise 13: rect fill
;
; Fill 2x2 rect with 3; sum=12.
;
; Build: nasm -f elf64 13-rect-fill.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    fb resb 16
section .text
    global _start
_start:
    mov byte [fb],3
    mov byte [fb+1],3
    mov byte [fb+4],3
    mov byte [fb+5],3
    xor rdi,rdi
    movzx rax,byte [fb]
    add rdi,rax
    movzx rax,byte [fb+1]
    add rdi,rax
    movzx rax,byte [fb+4]
    add rdi,rax
    movzx rax,byte [fb+5]
    add rdi,rax
    mov rax,60
    syscall
