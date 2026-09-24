; Exercise 19: bytecode jump
;
; Bytecode: JMP +2 over LOAD 99, LOAD 5, HALT; exit 5.
;
; Build: nasm -f elf64 19-bytecode-jump.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    ; 3=jmp rel, 1=load, 0=halt
    code db 3,2, 1,99, 1,5, 0
section .bss
    st resq 4
    sp_ resq 1
section .text
    global _start
_start:
    mov qword [sp_],0
    lea rsi,[code]
.loop:
    movzx rax,byte [rsi]
    inc rsi
    cmp rax,0
    je .halt
    cmp rax,1
    je .load
    cmp rax,3
    je .jmp
    jmp .halt
.load:
    movzx rax,byte [rsi]
    inc rsi
    mov rcx,[sp_]
    mov [st+rcx*8],rax
    inc qword [sp_]
    jmp .loop
.jmp:
    movzx rax,byte [rsi]
    inc rsi
    add rsi,rax
    jmp .loop
.halt:
    dec qword [sp_]
    mov rcx,[sp_]
    mov rdi,[st+rcx*8]
    mov rax,60
    syscall
