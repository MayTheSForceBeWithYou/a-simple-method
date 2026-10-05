; Exercise 06: popcount naive
;
; Popcount of 0b101101 = 4; exit 4.
;
; Build: nasm -f elf64 06-popcount-naive.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
