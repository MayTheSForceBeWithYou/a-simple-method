; Exercise 15: bitfield pack
;
; Pack a:3bits=5, b:3bits=2, c:2bits=1 into byte; exit value.
;
; Build: nasm -f elf64 15-bitfield-pack.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 5
    and rax, 7
    mov rbx, 2
    and rbx, 7
    shl rbx, 3
    or rax, rbx
    mov rbx, 1
    and rbx, 3
    shl rbx, 6
    or rax, rbx
    mov rdi, rax
    mov rax,60
    syscall
