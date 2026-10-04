; Exercise 15: clip rect
;
; Clip x to [0,w); x=-1 -> 0; exit 0.
;
; Build: nasm -f elf64 15-clip-rect.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
