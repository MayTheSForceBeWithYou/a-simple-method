; Exercise 06: eax zero extends
;
; Set rax to all 0xFF bytes, then mov eax, 1. Exit with rdi=rax (should be 1).
;
; Build: nasm -f elf64 06-eax-zero-extends.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 0xffffffffffffffff
    mov eax, 1
    mov rdi, rax
    mov rax, 60
    syscall
