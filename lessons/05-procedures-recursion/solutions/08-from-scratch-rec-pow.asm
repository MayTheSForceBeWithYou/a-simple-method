; Exercise 08: from scratch rec pow
;
; FROM SCRATCH: pow(base,exp) recursive multiply. pow(2,5)=32; exit 32.
;
; Build: nasm -f elf64 08-from-scratch-rec-pow.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 2
    mov rsi, 5
    call pow
    mov rdi, rax
    mov rax, 60
    syscall
pow:
    cmp rsi, 0
    je .one
    push rdi
    dec rsi
    call pow
    pop rdi
    imul rax, rdi
    ret
.one:
    mov rax, 1
    ret
