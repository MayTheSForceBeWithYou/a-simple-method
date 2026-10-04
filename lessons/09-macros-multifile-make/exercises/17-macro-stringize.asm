; Exercise 17: macro stringize
;
; NASM %%str: %%define S 'Q'; db and write length 1+nl exit 0.
;
; Build: nasm -f elf64 17-macro-stringize.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
