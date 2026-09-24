; Exercise 03: cursor move
;
; cursor dq; move right then left; exit cursor 0.
;
; Build: nasm -f elf64 03-cursor-move.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    cursor resq 1
section .text
    global _start
_start:
    mov qword [cursor], 0
    inc qword [cursor]
    dec qword [cursor]
    mov rdi, [cursor]
    mov rax, 60
    syscall
