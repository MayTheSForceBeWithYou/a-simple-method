; Exercise 15: local slot alloc
;
; Allocate 3 locals; next_slot=3; exit 3.
;
; Build: nasm -f elf64 15-local-slot-alloc.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
