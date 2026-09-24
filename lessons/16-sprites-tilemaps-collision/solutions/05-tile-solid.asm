; Exercise 05: tile solid
;
; tile id 2 solid table; exit 1.
;
; Build: nasm -f elf64 05-tile-solid.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    solid db 0,0,1,0
section .text
    global _start
_start:
    movzx rdi, byte [solid+2]
    mov rax, 60
    syscall
