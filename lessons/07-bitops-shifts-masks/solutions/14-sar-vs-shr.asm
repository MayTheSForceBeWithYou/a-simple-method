; Exercise 14: sar vs shr
;
; For -4 (64-bit): shr 1 vs sar 1; exit (sar_result == -2) as 1.
;
; Build: nasm -f elf64 14-sar-vs-shr.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, -4
    sar rax, 1
    cmp rax, -2
    jne .n
    mov rdi, 1
    jmp .o
.n:
    xor rdi,rdi
.o:
    mov rax,60
    syscall
