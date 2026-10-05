; Exercise 23: stretch ppm header len
;
; STRETCH: "P6\n" length 3; exit 3.
;
; Build: nasm -f elf64 23-stretch-ppm-header-len.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
