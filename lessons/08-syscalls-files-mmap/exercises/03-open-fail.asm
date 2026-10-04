; Exercise 03: open fail
;
; open nonexistent path; if rax<0 exit 1 else 0. Expect 1.
;
; Build: nasm -f elf64 03-open-fail.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
