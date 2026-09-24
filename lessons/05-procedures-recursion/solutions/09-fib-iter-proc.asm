; Exercise 09: fib iter proc
;
; Iterative fib(n) as procedure. fib(10)=55; exit 55.
;
; Build: nasm -f elf64 09-fib-iter-proc.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 10
    call fib
    mov rdi, rax
    mov rax, 60
    syscall
fib:
    cmp rdi, 0
    je .z
    cmp rdi, 1
    je .one
    mov rax, 0
    mov rbx, 1
    mov rcx, 2
.loop:
    cmp rcx, rdi
    jg .done
    mov rdx, rax
    add rdx, rbx
    mov rax, rbx
    mov rbx, rdx
    inc rcx
    jmp .loop
.done:
    mov rax, rbx
    ret
.z:
    xor rax, rax
    ret
.one:
    mov rax, 1
    ret
