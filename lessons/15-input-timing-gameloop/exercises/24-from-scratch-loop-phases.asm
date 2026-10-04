; Exercise 24: from scratch loop phases
;
; FROM SCRATCH: phases input,update,render counted; 3 phases * 2 frames = 6; exit 6.
;
; Build: nasm -f elf64 24-from-scratch-loop-phases.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
