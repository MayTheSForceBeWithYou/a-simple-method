; Exercise 04: six args sum
;
; sum6(a..f) all in regs. Pass 1..6; exit 21.
;
; Build: nasm -f elf64 04-six-args-sum.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 1
    mov rsi, 2
    mov rdx, 3
    mov rcx, 4
    mov r8, 5
    mov r9, 6
    call sum6
    mov rdi, rax
    mov rax, 60
    syscall

sum6:
    mov rax, rdi
    add rax, rsi
    add rax, rdx
    add rax, rcx
    add rax, r8
    add rax, r9
    ret
