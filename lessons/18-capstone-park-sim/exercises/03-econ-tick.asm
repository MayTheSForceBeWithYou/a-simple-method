; Exercise 03: econ tick
;
; cash+=5; exit cash 5.
;
; Build: nasm -f elf64 03-econ-tick.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
