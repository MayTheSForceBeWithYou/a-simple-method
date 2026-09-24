; Exercise 21: debug fold bug
;
; BUG: 2*3+4 computed as 2*(3+4). Fix to 10.
;
; Build: nasm -f elf64 21-debug-fold-bug.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax,3
    add rax,4
    imul rax,2
    mov rdi,rax
    mov rax,60
    syscall
