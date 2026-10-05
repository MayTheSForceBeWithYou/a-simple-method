; Exercise 18: status line len
;
; Status encodes len=12; exit 12.
;
; Build: nasm -f elf64 18-status-line-len.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
