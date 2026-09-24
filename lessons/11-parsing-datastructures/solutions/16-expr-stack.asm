; Exercise 16: expr stack
;
; Shunting: push 2,3, add -> 5; exit 5.
;
; Build: nasm -f elf64 16-expr-stack.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    st resq 8
    sp_ resq 1
section .text
    global _start
_start:
    mov qword [sp_],0
    mov rcx,[sp_]
    mov qword [st+rcx*8],2
    inc qword [sp_]
    mov rcx,[sp_]
    mov qword [st+rcx*8],3
    inc qword [sp_]
    dec qword [sp_]
    mov rcx,[sp_]
    mov rax,[st+rcx*8]
    dec qword [sp_]
    mov rcx,[sp_]
    add rax,[st+rcx*8]
    mov [st+rcx*8],rax
    inc qword [sp_]
    mov rdi,rax
    mov rax,60
    syscall
