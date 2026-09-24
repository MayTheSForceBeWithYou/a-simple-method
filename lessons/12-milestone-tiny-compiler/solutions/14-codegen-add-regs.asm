; Exercise 14: codegen add regs
;
; v1=10 v2=32; add into v1; exit 42.
;
; Build: nasm -f elf64 14-codegen-add-regs.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    v1 resq 1
    v2 resq 1
section .text
    global _start
_start:
    mov qword [v1],10
    mov qword [v2],32
    mov rax,[v1]
    add rax,[v2]
    mov [v1],rax
    mov rdi,rax
    mov rax,60
    syscall
