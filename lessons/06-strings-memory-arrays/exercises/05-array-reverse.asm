; Exercise 05: array reverse
;
; Reverse dq 1,2,3,4 in place; exit first element 4.
;
; Build: nasm -f elf64 05-array-reverse.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    arr dq 1,2,3,4
section .text
    global _start
_start:
    lea rdi, [arr]
    mov rsi, 4
    call rev
    mov rdi, [arr]
    mov rax, 60
    syscall
rev:
    ; TODO: implement rev
