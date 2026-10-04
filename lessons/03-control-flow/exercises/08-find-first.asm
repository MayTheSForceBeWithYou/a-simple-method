; Exercise 08: find first
;
; arr db 3,1,4,1,5. Find first index of 4 (2). Exit index.
;
; Build: nasm -f elf64 08-find-first.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
