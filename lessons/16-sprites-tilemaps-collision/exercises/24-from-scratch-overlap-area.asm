; Exercise 24: from scratch overlap area
;
; FROM SCRATCH: overlap width 2 height 3 area 6; exit 6.
;
; Build: nasm -f elf64 24-from-scratch-overlap-area.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
