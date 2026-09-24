; Exercise 14: vec2 length2
;
; length^2 of (3,4)=25; exit 25.
;
; Build: nasm -f elf64 14-vec2-length2.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax,3
    imul rax,rax
    mov rbx,4
    imul rbx,rbx
    add rax,rbx
    mov rdi,rax
    mov rax,60
    syscall
