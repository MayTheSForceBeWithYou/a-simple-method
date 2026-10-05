; Exercise 04: include guard sim
;
; Use %ifndef/%define for ANSWER equ 42; exit 42.
;
; Build: nasm -f elf64 04-include-guard-sim.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
