; Exercise 01: strlen
;
; Implement strlen; 'hello' -> 5.
;
; Build: nasm -f elf64 01-strlen.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    s db "hello",0
section .text
    global _start
_start:
    lea rdi, [s]
    call strlen
    mov rdi, rax
    mov rax, 60
    syscall
strlen:
    mov rax, rdi
.l:
    cmp byte [rax], 0
    je .d
    inc rax
    jmp .l
.d:
    sub rax, rdi
    ret
