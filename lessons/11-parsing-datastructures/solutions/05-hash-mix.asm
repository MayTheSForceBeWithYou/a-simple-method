; Exercise 05: hash mix
;
; x=5; x^=x<<3; exit low byte.
;
; Build: nasm -f elf64 05-hash-mix.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 5
    mov rbx, rax
    shl rbx, 3
    xor rax, rbx
    movzx rdi, al
    mov rax, 60
    syscall
