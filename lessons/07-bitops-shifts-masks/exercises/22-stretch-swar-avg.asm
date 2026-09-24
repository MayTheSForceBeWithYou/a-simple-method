; Exercise 22: stretch swar avg
;
; STRETCH: average bytes without overflow (a&b)+((a^b)>>1) for a=200,b=100 -> 150; exit 150.
;
; Build: nasm -f elf64 22-stretch-swar-avg.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
