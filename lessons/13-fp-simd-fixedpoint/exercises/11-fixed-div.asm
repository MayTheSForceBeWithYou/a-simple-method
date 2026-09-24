; Exercise 11: fixed div
;
; Q16: (6<<16)/(2<<16) via (a<<16)/b style: ((6<<16)<<16)/(2<<16) careful. Simpler int: 6/2=3 exit 3.
;
; Build: nasm -f elf64 11-fixed-div.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
