; Exercise 01: unconditional jmp
;
; jmp over a mov rdi,99; fallthrough sets rdi=7; exit 7.
;
; Build: nasm -f elf64 01-unconditional-jmp.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    jmp .ok
    mov rdi, 99
.ok:
    mov rdi, 7
    mov rax, 60
    syscall
