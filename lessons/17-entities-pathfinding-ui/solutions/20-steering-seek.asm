; Exercise 20: steering seek
;
; Seek desired vel = target-pos; (10-3)=7; exit 7.
;
; Build: nasm -f elf64 20-steering-seek.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi,10
    sub rdi,3
    mov rax,60
    syscall
