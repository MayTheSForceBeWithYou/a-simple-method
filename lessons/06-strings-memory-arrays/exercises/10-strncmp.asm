; Exercise 10: strncmp
;
; strncmp first 2 of "axy","abz" equal -> 0.
;
; Build: nasm -f elf64 10-strncmp.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    a db "axy",0
    b db "abz",0
section .text
    global _start
_start:
    lea rdi, [a]
    lea rsi, [b]
    mov rdx, 2
    call strncmp
    mov rdi, rax
    mov rax, 60
    syscall
strncmp:
    ; TODO: implement strncmp
