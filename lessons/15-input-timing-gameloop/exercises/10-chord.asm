; Exercise 10: chord
;
; W and Shift both down -> run=1; exit 1.
;
; Build: nasm -f elf64 10-chord.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
