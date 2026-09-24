; Exercise 11: assign macro
;
; %assign i 0 / %rep / %assign i i+1; exit 4 after 4 incs.
;
; Build: nasm -f elf64 11-assign-macro.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
