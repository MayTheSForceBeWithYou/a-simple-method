; Exercise 08: from scratch rol
;
; FROM SCRATCH: rol al,1 on 0x80 -> 0x01; exit 1.
;
; Build: nasm -f elf64 08-from-scratch-rol.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov al, 0x80
    rol al, 1
    movzx rdi, al
    mov rax, 60
    syscall
