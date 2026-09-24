; Exercise 01: locals three
;
; Function with 3 qword locals summing rdi+1..+3 style; call with 10 return 10+11+12=33; exit 33.
;
; Build: nasm -f elf64 01-locals-three.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 10
    call sum_locals
    mov rdi, rax
    mov rax, 60
    syscall
sum_locals:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov [rbp-8], rdi
    mov rax, rdi
    inc rax
    mov [rbp-16], rax
    inc rax
    mov [rbp-24], rax
    mov rax, [rbp-8]
    add rax, [rbp-16]
    add rax, [rbp-24]
    leave
    ret
