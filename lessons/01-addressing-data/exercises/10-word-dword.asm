; Exercise 10: word dword
;
; dw 0x1122, dd 0x33445566. Load low byte of the word into dil via byte [label], exit.
;
; Build: nasm -f elf64 10-word-dword.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
