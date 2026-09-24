; Exercise 20: dot3
;
; dot (1,2,3)*(4,5,6)=32; exit 32.
;
; Build: nasm -f elf64 20-dot3.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi,1*4+2*5+3*6
    mov rax,60
    syscall
