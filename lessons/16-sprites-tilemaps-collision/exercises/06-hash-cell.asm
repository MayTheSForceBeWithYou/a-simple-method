; Exercise 06: hash cell
;
; cell=(x>>3)+((y>>3)<<4); x=10 y=10; compute exit &255.
;
; Build: nasm -f elf64 06-hash-cell.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
