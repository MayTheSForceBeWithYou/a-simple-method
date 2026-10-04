; Exercise 18: load version check
;
; version==1 ok exit 1.
;
; Build: nasm -f elf64 18-load-version-check.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
