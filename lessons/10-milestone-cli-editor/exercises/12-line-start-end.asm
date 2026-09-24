; Exercise 12: line start end
;
; In "ab\ncd" find line start for cur=4 (index of c)->3; exit 3.
;
; Build: nasm -f elf64 12-line-start-end.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
