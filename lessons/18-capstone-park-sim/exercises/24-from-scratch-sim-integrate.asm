; Exercise 24: from scratch sim integrate
;
; FROM SCRATCH: one tick: place path, peep step, cash+=1; exit cash 1.
;
; Build: nasm -f elf64 24-from-scratch-sim-integrate.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
