; Exercise 01: tile index
;
; idx=y*map_w+x; y=2 x=3 w=10; exit 23.
;
; Build: nasm -f elf64 01-tile-index.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
