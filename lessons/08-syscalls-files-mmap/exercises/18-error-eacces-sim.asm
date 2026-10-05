; Exercise 18: error eacces sim
;
; open "/" with O_WRONLY may fail; if fail exit 1 else close exit 0. Expect 1 often.
;
; Build: nasm -f elf64 18-error-eacces-sim.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
