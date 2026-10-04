; Exercise 22: stretch char from reg
;
; Set bl=0x5A ('Z'). Store into a 2-byte buffer (char + newline), write it, exit 0.
;
; Build: nasm -f elf64 22-stretch-char-from-reg.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
