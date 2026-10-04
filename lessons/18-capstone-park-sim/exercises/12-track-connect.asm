; Exercise 12: track connect
;
; Two pieces connect if dirs match; exit 1.
;
; Build: nasm -f elf64 12-track-connect.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
