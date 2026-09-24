; Exercise 04: mmap anon
;
; mmap 4096 anon private RW; store 42; exit 42. SYS_mmap=9.
;
; Build: nasm -f elf64 04-mmap-anon.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
