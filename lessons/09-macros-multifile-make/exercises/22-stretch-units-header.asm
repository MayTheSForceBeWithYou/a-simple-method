; Exercise 22: stretch units header
;
; STRETCH: %define SYS_WRITE 1 / SYS_EXIT 60; print "U\n" exit 0.
;
; Build: nasm -f elf64 22-stretch-units-header.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
