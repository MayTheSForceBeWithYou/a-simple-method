; Exercise 18: error eacces sim
;
; open "/" with O_WRONLY may fail; if fail exit 1 else close exit 0. Expect 1 often.
;
; Build: nasm -f elf64 18-error-eacces-sim.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    path db "/",0
section .text
    global _start
_start:
    mov rax,2
    lea rdi,[path]
    mov rsi,1
    syscall
    cmp rax,0
    jl .bad
    mov rdi,rax
    mov rax,3
    syscall
    xor rdi,rdi
    jmp .o
.bad:
    mov rdi,1
.o:
    mov rax,60
    syscall
