; Exercise 04: edge trigger
;
; prev=0 cur=1 -> rising exit 1.
;
; Build: nasm -f elf64 04-edge-trigger.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
