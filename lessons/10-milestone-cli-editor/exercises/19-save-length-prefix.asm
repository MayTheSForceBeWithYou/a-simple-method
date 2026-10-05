; Exercise 19: save length prefix
;
; Serialize u64 len=4 then payload; total bytes 12; exit 12.
;
; Build: nasm -f elf64 19-save-length-prefix.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
