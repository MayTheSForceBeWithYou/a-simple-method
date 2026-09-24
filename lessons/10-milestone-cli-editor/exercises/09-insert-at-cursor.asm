; Exercise 09: insert at cursor
;
; Buffer empty; cursor 0; insert "X"; len=1 cursor=1; exit cursor.
;
; Build: nasm -f elf64 09-insert-at-cursor.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
