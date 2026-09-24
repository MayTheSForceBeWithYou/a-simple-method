; Exercise 17: rotate parity
;
; rol 0x01 through 8; count times bit0 set during rotates starting before=1 + after each? Simpler: ror al,1 on 0x01 -> 0x80; exit 0x80=128.
;
; Build: nasm -f elf64 17-rotate-parity.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
