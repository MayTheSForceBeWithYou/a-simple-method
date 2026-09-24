; Exercise 07: stack ds
;
; Push 1,2 pop to rdi; exit 2.
;
; Build: nasm -f elf64 07-stack-ds.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    stk resq 8
    sp_ resq 1
section .text
    global _start
_start:
    mov qword [sp_], 0
    mov rcx, [sp_]
    mov qword [stk+rcx*8], 1
    inc qword [sp_]
    mov rcx, [sp_]
    mov qword [stk+rcx*8], 2
    inc qword [sp_]
    dec qword [sp_]
    mov rcx, [sp_]
    mov rdi, [stk+rcx*8]
    mov rax, 60
    syscall
