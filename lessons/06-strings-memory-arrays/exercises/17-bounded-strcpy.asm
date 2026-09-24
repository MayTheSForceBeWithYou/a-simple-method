; Exercise 17: bounded strcpy
;
; Copy at most 3 chars + NUL from "abcdef" into 4-byte dst; strlen dst=3.
;
; Build: nasm -f elf64 17-bounded-strcpy.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
