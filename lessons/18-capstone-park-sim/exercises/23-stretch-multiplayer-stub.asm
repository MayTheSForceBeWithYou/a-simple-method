; Exercise 23: stretch multiplayer stub
;
; STRETCH: net tick id 2; exit 2. (local stub)
;
; Build: nasm -f elf64 23-stretch-multiplayer-stub.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
