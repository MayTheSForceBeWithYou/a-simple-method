; Exercise 10: token buffer
;
; Lexeme copy "let" into tok; len=3 exit 3.
;
; Build: nasm -f elf64 10-token-buffer.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    src db "let",0
section .bss
    tok resb 8
    n resq 1
section .text
    global _start
_start:
    lea rsi,[src]
    lea rdi,[tok]
    xor rcx,rcx
.l:
    mov al,[rsi+rcx]
    mov [rdi+rcx],al
    test al,al
    jz .d
    inc rcx
    jmp .l
.d:
    mov [n],rcx
    mov rdi,rcx
    mov rax,60
    syscall
