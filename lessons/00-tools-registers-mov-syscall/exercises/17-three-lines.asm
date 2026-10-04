; Exercise 17: three lines
;
; Print "one\n" "two\n" "three\n". Exit 0.
;
; Build: nasm -f elf64 17-three-lines.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
