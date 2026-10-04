; Exercise 24: from scratch fb size
;
; FROM SCRATCH: w=320 h=200 bpp=4 bytes; size &0xff of low... 320*200*4=256000; exit (size>>12)&255 or simply exit 0 after computing into rax and using 256000/10000=25.6 - exit 25 via /10240. Simpler: exit (w*h*bpp)>>16 = 3.
;
; Build: nasm -f elf64 24-from-scratch-fb-size.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
