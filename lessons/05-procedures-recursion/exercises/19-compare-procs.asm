; Exercise 19: compare procs
;
; cmp_i64(a,b) returns -1/0/1. cmp(3,5) -> -1; exit with al=255 via movzx of signed? Use add 1 -> 0 exit for less. Better: return 0 for less,1 eq,2 greater; exit 0.
;
; Build: nasm -f elf64 19-compare-procs.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
