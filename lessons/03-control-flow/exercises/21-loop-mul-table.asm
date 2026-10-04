; Exercise 21: loop mul table
;
; Compute 7*8 via repeated addition loop. Exit 56.
;
; Build: nasm -f elf64 21-loop-mul-table.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
