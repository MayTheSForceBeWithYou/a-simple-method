; Exercise 11: sprite layer
;
; Sort key layer*1000+y; layer2 y=5 -> 2005&255; exit (2005 & 255)=205? Use exit layer=2.
;
; Build: nasm -f elf64 11-sprite-layer.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi,2
    mov rax,60
    syscall
