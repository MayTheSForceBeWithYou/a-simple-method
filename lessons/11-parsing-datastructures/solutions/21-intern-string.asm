; Exercise 21: intern string
;
; Intern table pointer equality: same slot; exit 1.
;
; Build: nasm -f elf64 21-intern-string.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    a db "hi",0
section .bss
    table resq 1
section .text
    global _start
_start:
    lea rax,[a]
    mov [table],rax
    mov rbx,[table]
    cmp rax,rbx
    jne .n
    mov rdi,1
    jmp .o
.n:
    xor rdi,rdi
.o:
    mov rax,60
    syscall
