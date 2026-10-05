; Exercise 24: from scratch q8 mul
;
; FROM SCRATCH: Q8.8 2.5 * 2 = 5; exit 5.
;
; Build: nasm -f elf64 24-from-scratch-q8-mul.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
