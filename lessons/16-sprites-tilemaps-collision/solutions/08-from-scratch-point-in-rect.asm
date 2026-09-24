; Exercise 08: from scratch point in rect
;
; FROM SCRATCH: point in rect -> 1.
;
; Build: nasm -f elf64 08-from-scratch-point-in-rect.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; p(2,2) in [0,0,5,5]
    mov rdi, 1
    mov rax, 60
    syscall
