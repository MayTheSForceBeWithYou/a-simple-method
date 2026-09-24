; Exercise 25: stretch call depth
;
; STRETCH: bump(rdi) calls itself depth times adding 1 each return. bump(0) path: start call chain depth 5 returning 5.
;
; Build: nasm -f elf64 25-stretch-call-depth.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
