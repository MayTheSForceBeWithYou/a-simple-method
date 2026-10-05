; Exercise 03: fixed step
;
; step=16ms units; 50ms -> 3 steps; exit 3.
;
; Build: nasm -f elf64 03-fixed-step.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
