; Exercise 09: clear color
;
; Clear 4 pixels to color 5; exit first.
;
; Build: nasm -f elf64 09-clear-color.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    fb resb 4
section .text
    global _start
_start:
    mov al,5
    lea rdi,[fb]
    mov rcx,4
    rep stosb
    movzx rdi,byte [fb]
    mov rax,60
    syscall
