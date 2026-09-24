; Exercise 01: and mask
;
; rax=0xFF; and 0x0F; exit 15.
;
; Build: nasm -f elf64 01-and-mask.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 0xFF
    and rax, 0x0F
    mov rdi, rax
    mov rax, 60
    syscall
