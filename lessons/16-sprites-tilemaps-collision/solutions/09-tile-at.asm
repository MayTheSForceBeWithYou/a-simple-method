; Exercise 09: tile at
;
; map 4-wide; get(1,1)= tile index 5 stored; exit 5.
;
; Build: nasm -f elf64 09-tile-at.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    map db 0,1,2,3, 4,5,6,7
section .text
    global _start
_start:
    mov rax,1
    imul rax,4
    add rax,1
    movzx rdi,byte [map+rax]
    mov rax,60
    syscall
