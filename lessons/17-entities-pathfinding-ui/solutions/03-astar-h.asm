; Exercise 03: astar h
;
; Manhattan |3-1|+|4-2|=4.
;
; Build: nasm -f elf64 03-astar-h.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 3
    sub rax, 1
    mov rbx, 4
    sub rbx, 2
    add rax, rbx
    mov rdi, rax
    mov rax, 60
    syscall
