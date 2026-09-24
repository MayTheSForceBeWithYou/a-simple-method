; Exercise 13: memcpy forward
;
; Copy 8 bytes forward non-overlap; checksum low byte sum of dst. src 1..8 sum=36.
;
; Build: nasm -f elf64 13-memcpy-overlap-safe.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
