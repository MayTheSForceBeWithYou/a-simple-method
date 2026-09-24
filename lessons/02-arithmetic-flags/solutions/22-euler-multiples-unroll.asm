; Exercise 22: euler multiples unroll
;
; Project-Euler-lite: sum of multiples of 3 or 5 below 20 (unrolled/constant). Answer 78. Exit 78.
;
; Build: nasm -f elf64 22-euler-multiples-unroll.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; 3+5+6+9+10+12+15+18 = 78
    mov rdi, 78
    mov rax, 60
    syscall
