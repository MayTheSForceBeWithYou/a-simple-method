; Exercise 10: open dev null
;
; open /dev/null O_WRONLY=1; on success close and exit 0.
;
; Build: nasm -f elf64 10-open-dev-null.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
