; Exercise 02: pack rgb
;
; Pack R=1,G=2,B=3 into 0x010203 then &255 exit 3.
;
; Build: nasm -f elf64 02-pack-rgb.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
