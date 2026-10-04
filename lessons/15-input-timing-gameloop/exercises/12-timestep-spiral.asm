; Exercise 12: timestep spiral
;
; Spiral of death guard: max 3 catchup steps; given 100ms dt step 16 -> would be 6, clamp 3; exit 3.
;
; Build: nasm -f elf64 12-timestep-spiral.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
