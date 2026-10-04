; Exercise 12: ll sum
;
; List 3->4->5; sum=12.
;
; Build: nasm -f elf64 12-ll-sum.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
