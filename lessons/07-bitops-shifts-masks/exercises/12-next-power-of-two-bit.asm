; Exercise 12: next power check
;
; Test if 16 is power of two (x&&!(x&(x-1))); exit 1.
;
; Build: nasm -f elf64 12-next-power-of-two-bit.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
