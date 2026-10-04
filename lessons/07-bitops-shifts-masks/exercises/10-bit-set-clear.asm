; Exercise 10: bit set clear
;
; Start 0; set bit 3; clear bit 3; exit 0.
;
; Build: nasm -f elf64 10-bit-set-clear.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
