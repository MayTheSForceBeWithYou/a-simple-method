; Exercise 26: two exits dead
;
; Write "alive\n", exit 0, then dead exit 99 after (unreachable).
;
; Build: nasm -f elf64 26-two-exits-dead.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
