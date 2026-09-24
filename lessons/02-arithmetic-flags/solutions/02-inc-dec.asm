; Exercise 02: inc dec
;
; rax=5; inc; inc; dec; mov rdi,rax; exit (6).
;
; Build: nasm -f elf64 02-inc-dec.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 5
    inc rax
    inc rax
    dec rax
    mov rdi, rax
    mov rax, 60
    syscall
