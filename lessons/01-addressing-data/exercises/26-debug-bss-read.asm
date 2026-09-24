; Exercise 26: debug bss read
;
; BUG: reads .bss before store (0). Store 12 first; exit 12.
;
; Build: nasm -f elf64 26-debug-bss-read.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    v resq 1

section .text
    global _start
_start:
    mov rdi, [v]
    mov rax, 60
    syscall
