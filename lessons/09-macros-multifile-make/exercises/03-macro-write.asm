; Exercise 03: macro write
;
; Macro sys_write1 msg,len; print 'M\n'.
;
; Build: nasm -f elf64 03-macro-write.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
