; Exercise 12: mmap write read
;
; mmap 4096; write 99 at +100; read back; exit 99. SYS_mmap=9 PROT_RW=3 MAP_PRIVATE|ANON=0x22
;
; Build: nasm -f elf64 12-mmap-write-read.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
