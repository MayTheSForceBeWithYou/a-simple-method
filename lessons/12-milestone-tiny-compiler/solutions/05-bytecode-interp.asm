; Exercise 05: bytecode interp
;
; Bytes: LOAD 4, LOAD 5, ADD, HALT. Exit 9.
;
; Build: nasm -f elf64 05-bytecode-interp.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    code db 1,4, 1,5, 2, 0
section .bss
    stack resq 8
    sp_ resq 1
section .text
    global _start
_start:
    mov qword [sp_], 0
    lea rsi, [code]
.loop:
    movzx rax, byte [rsi]
    inc rsi
    cmp rax, 0
    je .halt
    cmp rax, 1
    je .load
    cmp rax, 2
    je .add
    jmp .halt
.load:
    movzx rax, byte [rsi]
    inc rsi
    mov rcx, [sp_]
    mov [stack+rcx*8], rax
    inc qword [sp_]
    jmp .loop
.add:
    dec qword [sp_]
    mov rcx, [sp_]
    mov rax, [stack+rcx*8]
    dec qword [sp_]
    mov rcx, [sp_]
    add rax, [stack+rcx*8]
    mov [stack+rcx*8], rax
    inc qword [sp_]
    jmp .loop
.halt:
    dec qword [sp_]
    mov rcx, [sp_]
    mov rdi, [stack+rcx*8]
    mov rax, 60
    syscall
