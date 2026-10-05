; Exercise 25: stretch binsearch
;
; STRETCH: sorted dq 1,3,5,7,9. Binary search for 7; exit index 3.
;
; Build: nasm -f elf64 25-stretch-binsearch.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
