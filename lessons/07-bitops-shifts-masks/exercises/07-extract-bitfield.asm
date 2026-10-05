; Exercise 07: extract bitfield
;
; From 0xABCD, extract bits 4..7 (low nibble of high byte of low word): (val>>4)&0xF = 0xC = 12.
;
; Build: nasm -f elf64 07-extract-bitfield.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
