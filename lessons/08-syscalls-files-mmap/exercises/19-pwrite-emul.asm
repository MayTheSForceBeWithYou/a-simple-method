; Exercise 19: pwrite emul
;
; Emulate pwrite via lseek+write on /dev/null: open, lseek end, write. Exit 0 on success.
;
; Build: nasm -f elf64 19-pwrite-emul.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
