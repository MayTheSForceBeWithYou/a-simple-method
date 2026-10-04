; Exercise 16: clock gettime stub
;
; SYS_clock_gettime=228 CLOCK_MONOTONIC=1 into timespec; exit 0 if syscall ok.
;
; Build: nasm -f elf64 16-clock-gettime-stub.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
