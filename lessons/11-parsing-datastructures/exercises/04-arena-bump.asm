; Exercise 04: arena bump
;
; Bump allocate 16 then 16; offset 32; exit 32&255.
;
; Build: nasm -f elf64 04-arena-bump.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
