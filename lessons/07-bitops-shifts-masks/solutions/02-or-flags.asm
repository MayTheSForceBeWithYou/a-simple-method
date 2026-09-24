; Exercise 02: or flags
;
; Pack bits: set bits 0 and 2 in dil; exit 5.
;
; Build: nasm -f elf64 02-or-flags.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    xor rdi, rdi
    or rdi, 1
    or rdi, 4
    mov rax, 60
    syscall
