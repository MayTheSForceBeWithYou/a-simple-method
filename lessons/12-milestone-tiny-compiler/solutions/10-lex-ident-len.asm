; Exercise 10: lex ident len
;
; Ident "foo" length 3; exit 3.
;
; Build: nasm -f elf64 10-lex-ident-len.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    s db "foo",0
section .text
    global _start
_start:
    lea rsi,[s]
    xor rdi,rdi
.l:
    movzx rax,byte [rsi]
    cmp al,'a'
    jb .d
    cmp al,'z'
    ja .d
    inc rdi
    inc rsi
    jmp .l
.d:
    mov rax,60
    syscall
