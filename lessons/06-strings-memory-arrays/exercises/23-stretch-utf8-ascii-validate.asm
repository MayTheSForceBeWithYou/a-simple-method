; Exercise 23: stretch ascii validate
;
; STRETCH: validate all bytes <128 in "OK\n"; exit 1 if valid.
;
; Build: nasm -f elf64 23-stretch-utf8-ascii-validate.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
