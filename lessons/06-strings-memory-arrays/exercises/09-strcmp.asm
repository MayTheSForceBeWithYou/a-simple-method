; Exercise 09: strcmp
;
; strcmp "abc","abd" -> nonzero (1). Exit 1.
;
; Build: nasm -f elf64 09-strcmp.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    a db "abc",0
    b db "abd",0
section .text
    global _start
_start:
    lea rdi, [a]
    lea rsi, [b]
    call strcmp
    mov rdi, rax
    mov rax, 60
    syscall
strcmp:
    ; TODO: implement strcmp
