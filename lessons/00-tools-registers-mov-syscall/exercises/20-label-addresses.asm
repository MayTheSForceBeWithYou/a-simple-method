; Exercise 20: label addresses
;
; Two messages; print only msg2 "use me\n". Exit 0.
;
; Build: nasm -f elf64 20-label-addresses.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
