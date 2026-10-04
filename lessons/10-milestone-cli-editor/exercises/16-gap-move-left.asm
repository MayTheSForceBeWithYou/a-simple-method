; Exercise 16: gap move left
;
; Move gap left: gap_s=3 gap_e=5 -> move left once gap_s=2 gap_e=4; exit gap_s.
;
; Build: nasm -f elf64 16-gap-move-left.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
