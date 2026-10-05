; Exercise 25: equ offsets
;
; Use equ for OFF_B equ 8. vals dq 3,9. Load [vals+OFF_B] exit 9.
;
; Build: nasm -f elf64 25-equ-offsets.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
