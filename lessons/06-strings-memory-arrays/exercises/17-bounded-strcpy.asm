; Exercise 17: bounded strcpy
;
; Copy at most 3 chars + NUL from "abcdef" into 4-byte dst; strlen dst=3.
;
; Build: nasm -f elf64 17-bounded-strcpy.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    src db "abcdef",0
section .bss
    dst resb 4
section .text
    global _start
_start:
    lea rdi, [dst]
    lea rsi, [src]
    mov rdx, 3
    call strncpy_term
    lea rdi, [dst]
    call strlen
    mov rdi, rax
    mov rax, 60
    syscall
strncpy_term:
    ; TODO: implement strncpy_term
strlen:
    ; TODO: implement strlen
