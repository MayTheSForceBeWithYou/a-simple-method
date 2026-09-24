; Exercise 09: lexer skip ws
;
; Skip spaces before digit in "  7"; exit value 7.
;
; Build: nasm -f elf64 09-lexer-skip-ws.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    s db "  7",0
section .text
    global _start
_start:
    lea rsi,[s]
.l:
    cmp byte [rsi],' '
    jne .d
    inc rsi
    jmp .l
.d:
    movzx rdi,byte [rsi]
    sub rdi,'0'
    mov rax,60
    syscall
