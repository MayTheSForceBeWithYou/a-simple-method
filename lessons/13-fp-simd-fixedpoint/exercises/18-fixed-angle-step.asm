; Exercise 18: fixed angle step
;
; Angle += delta; wrap 360; 350+20 -> 10; exit 10.
;
; Build: nasm -f elf64 18-fixed-angle-step.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
