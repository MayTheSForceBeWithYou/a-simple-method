; Exercise 14: tile collision mask
;
; Flags bit0 solid bit1 platform; value 3; exit solid&1 =1.
;
; Build: nasm -f elf64 14-tile-collision-mask.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
