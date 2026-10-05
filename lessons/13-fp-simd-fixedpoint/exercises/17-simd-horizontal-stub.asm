; Exercise 17: simd horizontal stub
;
; Sum 4 lanes {1,2,3,4}=10 without SSE.
;
; Build: nasm -f elf64 17-simd-horizontal-stub.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
