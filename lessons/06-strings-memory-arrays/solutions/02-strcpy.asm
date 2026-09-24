; Exercise 02: strcpy
;
; Copy 'yo' to bss; return length written 2; exit 2.
;
; Build: nasm -f elf64 02-strcpy.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    src db "yo",0
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
    mov rax, rdi
.l:
    mov cl, [rsi]
    mov [rdi], cl
    inc rsi
    inc rdi
    test cl, cl
    jnz .l
    ret
strlen:
    mov rax, rdi
.l2:
    cmp byte [rax], 0
    je .d2
    inc rax
    jmp .l2
.d2:
    sub rax, rdi
    ret
