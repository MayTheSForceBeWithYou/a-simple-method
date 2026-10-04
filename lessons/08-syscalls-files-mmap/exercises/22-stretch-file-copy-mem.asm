; Exercise 22: stretch file copy mem
;
; STRETCH: copy 4 bytes between two mmap regions; checksum 10 for 1,2,3,4.
;
; Build: nasm -f elf64 22-stretch-file-copy-mem.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
