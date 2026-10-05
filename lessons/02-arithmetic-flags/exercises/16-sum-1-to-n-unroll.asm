; Exercise 16: sum 1 to n unroll
;
; Without jumps: sum 1+2+...+8 into rdi (36) using add chain; exit.
;
; Build: nasm -f elf64 16-sum-1-to-n-unroll.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
