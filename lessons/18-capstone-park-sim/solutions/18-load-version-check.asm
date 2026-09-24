; Exercise 18: load version check
;
; version==1 ok exit 1.
;
; Build: nasm -f elf64 18-load-version-check.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    ver dq 1
section .text
    global _start
_start:
    cmp qword [ver],1
    jne .n
    mov rdi,1
    jmp .o
.n:
    xor rdi,rdi
.o:
    mov rax,60
    syscall
