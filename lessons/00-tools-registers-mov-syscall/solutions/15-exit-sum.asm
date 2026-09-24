; Exercise 15: exit sum
;
; Set r8=10, r9=20, r10=12. Sum into rdi; exit (42).
;
; Build: nasm -f elf64 15-exit-sum.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov r8, 10
    mov r9, 20
    mov r10, 12
    mov rdi, r8
    add rdi, r9
    add rdi, r10
    mov rax, 60
    syscall
