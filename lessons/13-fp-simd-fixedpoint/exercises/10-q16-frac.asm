; Exercise 10: q16 frac
;
; 0.5 in Q16.16 is 1<<15; add two -> 1.0; exit 1.
;
; Build: nasm -f elf64 10-q16-frac.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
