; Exercise 12: debug off by scale
;
; BUG: array of qwords indexed with *1 instead of *8. Fix; load index 1 value 20, exit.
;
; Build: nasm -f elf64 12-debug-off-by-scale.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    arr dq 10, 20, 30

section .text
    global _start
_start:
    mov rcx, 1
    mov rdi, [arr+rcx*1]
    mov rax, 60
    syscall
