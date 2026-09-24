; Exercise 15: gap insert
;
; Gap buffer: gap_s=2 gap_e=6; insert shrinks gap; free space after insert one = 3; exit 3.
;
; Build: nasm -f elf64 15-gap-insert.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
