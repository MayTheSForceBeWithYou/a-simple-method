; Exercise 15: lerp fixed
;
; lerp(0,10,0.5) ~5 with Q16 t=1<<15; exit 5.
;
; Build: nasm -f elf64 15-lerp-fixed.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
