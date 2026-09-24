; Exercise 12: vline
;
; Vertical with stride 4; plot 3 pixels; sum=6 if value 2.
;
; Build: nasm -f elf64 12-vline.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    fb resb 16
section .text
    global _start
_start:
    mov byte [fb],2
    mov byte [fb+4],2
    mov byte [fb+8],2
    xor rdi,rdi
    movzx rax,byte [fb]
    add rdi,rax
    movzx rax,byte [fb+4]
    add rdi,rax
    movzx rax,byte [fb+8]
    add rdi,rax
    mov rax,60
    syscall
