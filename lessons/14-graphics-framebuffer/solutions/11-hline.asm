; Exercise 11: hline
;
; Horizontal line y=0 x=0..2 set 1; sum first 3=3.
;
; Build: nasm -f elf64 11-hline.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    fb resb 8
section .text
    global _start
_start:
    mov byte [fb],1
    mov byte [fb+1],1
    mov byte [fb+2],1
    xor rdi,rdi
    movzx rax,byte [fb]
    add rdi,rax
    movzx rax,byte [fb+1]
    add rdi,rax
    movzx rax,byte [fb+2]
    add rdi,rax
    mov rax,60
    syscall
