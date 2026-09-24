; Exercise 11: test zf
;
; rax=0; test rax,rax; sete al; exit 1.
;
; Build: nasm -f elf64 11-test-zf.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    xor rax, rax
    test rax, rax
    sete al
    movzx rdi, al
    mov rax, 60
    syscall
