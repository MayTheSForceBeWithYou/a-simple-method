; Exercise 10: insert middle
;
; buf "AC" len2 cur1; insert B -> "ABC"; exit middle byte 66.
;
; Build: nasm -f elf64 10-insert-middle.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
