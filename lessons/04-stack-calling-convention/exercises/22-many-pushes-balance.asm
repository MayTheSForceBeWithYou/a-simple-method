; Exercise 22: many pushes balance
;
; Push 1,2,3; call sum_top3 that reads [rsp+8],[rsp+16],[rsp+24] after call (retaddr at [rsp]). Exit 6.
;
; Build: nasm -f elf64 22-many-pushes-balance.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
