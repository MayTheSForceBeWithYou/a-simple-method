; Exercise 06: shift div
;
; Divide by 4 via sar; 20>>2=5.
;
; Build: nasm -f elf64 06-shift-div.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 20
    sar rdi, 2
    mov rax, 60
    syscall
