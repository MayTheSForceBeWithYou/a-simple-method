; Exercise 16: bitfield unpack
;
; From 0b01_010_101 extract mid field bits3-5 (=2); exit 2.
;
; Build: nasm -f elf64 16-bitfield-unpack.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
