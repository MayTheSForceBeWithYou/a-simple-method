; Exercise 11: mouse delta
;
; dx=5 dy=-2; manhattan 7; exit 7.
;
; Build: nasm -f elf64 11-mouse-delta.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax,5
    mov rbx,-2
    neg rbx
    add rax,rbx
    mov rdi,rax
    mov rax,60
    syscall
