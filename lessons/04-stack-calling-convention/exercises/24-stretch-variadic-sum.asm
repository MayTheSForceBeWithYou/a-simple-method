; Exercise 24: stretch variadic sum
;
; STRETCH: sum_n(n, ...) where n in rdi, then n qwords on stack. sum_n(4, 3,4,5,6)=18.
;
; Build: nasm -f elf64 24-stretch-variadic-sum.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    push 6
    push 5
    push 4
    push 3
    mov rdi, 4
    call sum_n
    add rsp, 32
    mov rdi, rax
    mov rax, 60
    syscall

sum_n:
    ; TODO: implement sum_n
