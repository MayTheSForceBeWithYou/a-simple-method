; Exercise 18: debug off by one copy
;
; BUG: copies n bytes but forgets NUL. Fix strcpy of "ok"; strlen=2.
;
; Build: nasm -f elf64 18-debug-off-by-one-copy.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    src db "ok",0
section .bss
    dst resb 8
section .text
    global _start
_start:
    lea rdi, [dst]
    lea rsi, [src]
    call strcpy
    lea rdi, [dst]
    call strlen
    mov rdi, rax
    mov rax, 60
    syscall
strcpy:
.l:
    mov al, [rsi]
    mov [rdi], al
    inc rsi
    inc rdi
    test al, al
    jnz .l
    ret
strlen:
    mov rax, rdi
.s:
    cmp byte [rax], 0
    je .d
    inc rax
    jmp .s
.d:
    sub rax, rdi
    ret
