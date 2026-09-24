; Exercise 12: aabb minkowski
;
; Minkowski expand by 1; width 4->6; exit 6.
;
; Build: nasm -f elf64 12-aabb-minkowski.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi,4
    add rdi,2
    mov rax,60
    syscall
