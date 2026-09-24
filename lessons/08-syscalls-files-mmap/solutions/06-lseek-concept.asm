; Exercise 06: lseek concept
;
; Without real file: simulate offset add; exit 10.
;
; Build: nasm -f elf64 06-lseek-concept.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 0
    add rdi, 10
    mov rax, 60
    syscall
