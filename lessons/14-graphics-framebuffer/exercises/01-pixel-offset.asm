; Exercise 01: pixel offset
;
; offset=y*stride+x*4; y=2,x=3,stride=40; exit offset&255.
;
; Build: nasm -f elf64 01-pixel-offset.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
