; Exercise 07: scaled index
;
; arr dq 5,10,15,20. Set rcx=2, load arr[rcx] with [arr+rcx*8] into rdi, exit (15).
;
; Build: nasm -f elf64 07-scaled-index.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    arr dq 5, 10, 15, 20

section .text
    global _start
_start:
    mov rcx, 2
    mov rdi, [arr+rcx*8]
    mov rax, 60
    syscall
