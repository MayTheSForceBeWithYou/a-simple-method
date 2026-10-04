; Exercise 23: stretch haptic stub
;
; STRETCH: rumble frames remaining 2; exit 2.
;
; Build: nasm -f elf64 23-stretch-haptic-stub.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
