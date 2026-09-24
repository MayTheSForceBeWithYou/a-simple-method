; Exercise 12: setl signed
;
; rax=-1 (or 0xffffffffffffffff), rbx=0. cmp rax,rbx; setl al; exit 1.
;
; Build: nasm -f elf64 12-setl-signed.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, -1
    mov rbx, 0
    cmp rax, rbx
    setl al
    movzx rdi, al
    mov rax, 60
    syscall
