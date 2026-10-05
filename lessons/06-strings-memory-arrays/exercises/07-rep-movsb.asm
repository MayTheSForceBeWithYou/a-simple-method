; Exercise 07: rep movsb
;
; Copy 5 bytes with rep movsb; checksum exit 15 for bytes 1..5.
;
; Build: nasm -f elf64 07-rep-movsb.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
