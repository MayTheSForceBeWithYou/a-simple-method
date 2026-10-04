; Exercise 07: write iov lite
;
; Two writes simulating writev; print 'A\nB\n'; exit 0.
;
; Build: nasm -f elf64 07-write-iov-lite.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
