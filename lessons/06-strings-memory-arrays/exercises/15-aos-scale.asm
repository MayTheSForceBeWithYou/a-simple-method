; Exercise 15: aos scale
;
; AoS {x,y} *2 for one entity {3,4}->6,8; exit x+y=14.
;
; Build: nasm -f elf64 15-aos-scale.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
