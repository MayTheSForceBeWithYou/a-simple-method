; Exercise 18: strlen loop
;
; Cstring 'hello',0. Count length 5 into rdi.
;
; Build: nasm -f elf64 18-strlen-loop.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    s db "hello", 0

section .text
    global _start
_start:
    lea rsi, [s]
    xor rdi, rdi
.loop:
    cmp byte [rsi], 0
    je .done
    inc rdi
    inc rsi
    jmp .loop
.done:
    mov rax, 60
    syscall
