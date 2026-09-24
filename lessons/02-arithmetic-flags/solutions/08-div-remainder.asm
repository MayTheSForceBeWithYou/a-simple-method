; Exercise 08: div remainder
;
; Unsigned: 20 / 6. Exit with remainder (rdx) = 2.
;
; Build: nasm -f elf64 08-div-remainder.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 20
    xor rdx, rdx
    mov rbx, 6
    div rbx
    mov rdi, rdx
    mov rax, 60
    syscall
