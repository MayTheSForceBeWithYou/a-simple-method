; Exercise 08: from scratch stride
;
; FROM SCRATCH: stride=width*bpp; w=16 bpp=4; exit 64.
;
; Build: nasm -f elf64 08-from-scratch-stride.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
