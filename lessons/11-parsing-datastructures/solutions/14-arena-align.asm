; Exercise 14: arena align
;
; Bump 1 then align to 8; bump becomes 8; exit 8.
;
; Build: nasm -f elf64 14-arena-align.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    bump resq 1
section .text
    global _start
_start:
    mov qword [bump],1
    mov rax,[bump]
    add rax,7
    and rax,~7
    mov [bump],rax
    mov rdi,rax
    mov rax,60
    syscall
