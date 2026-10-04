; Exercise 22: stretch ring drop
;
; STRETCH: input ring full drops; dropped count 1; exit 1.
;
; Build: nasm -f elf64 22-stretch-ring-drop.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
