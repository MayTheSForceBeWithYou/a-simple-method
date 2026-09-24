; Exercise 23: stretch chunk coords
;
; STRETCH: chunk = tile>>4; tile=40 -> 2; exit 2.
;
; Build: nasm -f elf64 23-stretch-chunk-coords.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
