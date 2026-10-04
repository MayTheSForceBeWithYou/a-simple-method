; Exercise 17: flip flags
;
; HFLIP|VFLIP = 3; exit 3.
;
; Build: nasm -f elf64 17-flip-flags.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
