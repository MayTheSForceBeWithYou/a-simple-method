; Exercise 22: stretch memcpy4
;
; STRETCH: src db 1,2,3,4. dst resb 4. Copy 4 bytes via register loads/stores. Sum dst into rdi (10).
;
; Build: nasm -f elf64 22-stretch-memcpy4.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
