; Exercise 20: fixed hz
;
; 60 Hz -> step ns approx store 16666667&0xff; exit low byte or exit 60 as hz.
;
; Build: nasm -f elf64 20-fixed-hz.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
