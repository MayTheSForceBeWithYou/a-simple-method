; Exercise 04: shl mul
;
; rax=3; shl 3 (=*8); exit 24.
;
; Build: nasm -f elf64 04-shl-mul.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 3
    shl rax, 3
    mov rdi, rax
    mov rax, 60
    syscall
