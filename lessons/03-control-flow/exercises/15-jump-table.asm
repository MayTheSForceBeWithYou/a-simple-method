; Exercise 15: jump table
;
; rax=1. Jump table of 3 cases setting rdi to 10/20/30. Exit 20.
;
; Build: nasm -f elf64 15-jump-table.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
