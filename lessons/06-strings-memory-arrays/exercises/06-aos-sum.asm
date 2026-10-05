; Exercise 06: aos sum
;
; AoS records {dq x,y} two ents. Sum all coords exit.
;
; Build: nasm -f elf64 06-aos-sum.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
