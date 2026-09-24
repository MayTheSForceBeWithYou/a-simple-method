; Exercise 09: map place path
;
; Place PATH=1 at (2,3) on w=8; index=3*8+2=26; store; exit cell.
;
; Build: nasm -f elf64 09-map-place-path.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
PATH equ 1
section .bss
    map resb 64
section .text
    global _start
_start:
    mov rax,3
    imul rax,8
    add rax,2
    mov byte [map+rax],PATH
    movzx rdi,byte [map+rax]
    mov rax,60
    syscall
