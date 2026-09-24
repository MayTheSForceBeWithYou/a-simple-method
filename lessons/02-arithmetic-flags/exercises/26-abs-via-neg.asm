; Exercise 26: abs via neg
;
; rax=-42. cqto-style abs: if SF then neg. Exit 42. (Use sets + jns or cdq/xor/sub idiom.)
;
; Build: nasm -f elf64 26-abs-via-neg.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
