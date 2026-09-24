; Exercise 10: put pixel
;
; put_pixel(x,y) with stride 8 bpp1; x=2 y=1 -> offset 10; store 9; exit 9.
;
; Build: nasm -f elf64 10-put-pixel.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    fb resb 32
section .text
    global _start
_start:
    mov rax,1
    imul rax,8
    add rax,2
    mov byte [fb+rax],9
    movzx rdi,byte [fb+rax]
    mov rax,60
    syscall
