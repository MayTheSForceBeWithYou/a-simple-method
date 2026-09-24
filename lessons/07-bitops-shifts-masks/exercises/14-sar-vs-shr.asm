; Exercise 14: sar vs shr
;
; For -4 (64-bit): shr 1 vs sar 1; exit (sar_result == -2) as 1.
;
; Build: nasm -f elf64 14-sar-vs-shr.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
