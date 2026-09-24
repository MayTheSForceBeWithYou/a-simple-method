; Exercise 19: swap via ptrs
;
; swap(rdi=&a,rsi=&b). a dq 1,b dq 2; after swap exit a (2).
;
; Build: nasm -f elf64 19-swap-via-ptrs.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
