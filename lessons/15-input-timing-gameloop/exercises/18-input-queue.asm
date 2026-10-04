; Exercise 18: input queue
;
; Enqueue event 9; dequeue; exit 9.
;
; Build: nasm -f elf64 18-input-queue.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
