; Exercise 09: lex number
;
; Parse "42" into int; exit 42.
;
; Build: nasm -f elf64 09-lex-number.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    s db "42",0
section .text
    global _start
_start:
    lea rsi,[s]
    xor rdi,rdi
.l:
    movzx rax,byte [rsi]
    test rax,rax
    jz .d
    sub rax,'0'
    imul rdi,10
    add rdi,rax
    inc rsi
    jmp .l
.d:
    mov rax,60
    syscall
