; Exercise 15: camera cull
;
; Sprite x=100 cam=50 view_w=40 -> culled; exit 1.
;
; Build: nasm -f elf64 15-camera-cull.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
