; Exercise 20: queue ring
;
; Ring buffer cap 4; enqueue 7,8; dequeue; exit 7.
;
; Build: nasm -f elf64 20-queue-ring.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
