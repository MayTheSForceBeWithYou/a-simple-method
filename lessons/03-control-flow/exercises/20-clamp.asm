; Exercise 20: clamp
;
; x=150. Clamp to [0,100]. Exit 100.
;
; Build: nasm -f elf64 20-clamp.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
