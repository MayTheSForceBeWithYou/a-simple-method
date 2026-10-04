; Exercise 20: count char
;
; Count 's' in 'mississippi' -> 4.
;
; Build: nasm -f elf64 20-count-char.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
