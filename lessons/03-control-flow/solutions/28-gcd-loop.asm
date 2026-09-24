; Exercise 28: gcd loop
;
; Euclid GCD(48,18)=6. Exit 6.
;
; Build: nasm -f elf64 28-gcd-loop.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 48
    mov rbx, 18
.loop:
    cmp rbx, 0
    je .done
    xor rdx, rdx
    div rbx
    mov rax, rbx
    mov rbx, rdx
    jmp .loop
.done:
    mov rdi, rax
    mov rax, 60
    syscall
