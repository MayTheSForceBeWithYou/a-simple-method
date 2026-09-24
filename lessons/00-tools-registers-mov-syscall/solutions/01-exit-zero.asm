; Exercise 01: exit zero
;
; Exit with status 0 using sys_exit (rax=60).
;
; Build: nasm -f elf64 01-exit-zero.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 60
    xor rdi, rdi
    syscall
