; Exercise 06: displacement
;
; struct-like: base label vals with dq 1,2,3. Load third qword via [vals+16] into rdi, exit.
;
; Build: nasm -f elf64 06-displacement.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
