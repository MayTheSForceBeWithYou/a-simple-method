; Exercise 18: guest happiness
;
; Clamp happiness add 20 from 90 -> 100; exit 100.
;
; Build: nasm -f elf64 18-guest-happiness.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax,90
    add rax,20
    cmp rax,100
    jle .ok
    mov rax,100
.ok:
    mov rdi,rax
    mov rax,60
    syscall
