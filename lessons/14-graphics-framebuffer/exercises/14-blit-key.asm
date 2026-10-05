; Exercise 14: blit key
;
; Blit with color key 0 skip; src 0,5,0,5 -> dst sum 10.
;
; Build: nasm -f elf64 14-blit-key.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
