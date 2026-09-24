; Exercise 06: prologue locals
;
; Function stores local = rdi+1 on stack frame; returns it. Call with 41; exit 42.
;
; Build: nasm -f elf64 06-prologue-locals.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 41
    call inc_local
    mov rdi, rax
    mov rax, 60
    syscall

inc_local:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    mov rax, rdi
    add rax, 1
    mov [rbp-8], rax
    mov rax, [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
