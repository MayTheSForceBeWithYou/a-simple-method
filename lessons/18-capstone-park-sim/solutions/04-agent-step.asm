; Exercise 04: agent step
;
; agent x++; exit x.
;
; Build: nasm -f elf64 04-agent-step.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    ax_ resq 1
section .text
    global _start
_start:
    inc qword [ax_]
    mov rdi, [ax_]
    mov rax, 60
    syscall
