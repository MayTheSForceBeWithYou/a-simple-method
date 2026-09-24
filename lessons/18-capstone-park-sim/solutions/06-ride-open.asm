; Exercise 06: ride open
;
; flag open=1; exit 1.
;
; Build: nasm -f elf64 06-ride-open.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    open resb 1
section .text
    global _start
_start:
    mov byte [open], 1
    movzx rdi, byte [open]
    mov rax, 60
    syscall
