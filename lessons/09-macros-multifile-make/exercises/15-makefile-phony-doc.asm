; Exercise 15: makefile phony doc
;
; Documents Make .PHONY; program exits 0. Read comment about naming targets.
;
; Build: nasm -f elf64 15-makefile-phony-doc.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
