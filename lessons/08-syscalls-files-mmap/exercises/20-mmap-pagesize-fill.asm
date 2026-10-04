; Exercise 20: mmap pagesize fill
;
; Fill first 16 bytes of mmap with 1; sum=16; exit 16.
;
; Build: nasm -f elf64 20-mmap-pagesize-fill.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
