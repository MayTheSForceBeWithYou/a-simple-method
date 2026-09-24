; Exercise 13: variadic max
;
; max_n(n, ...) n in rdi, n qwords on stack. max of 5,9,2,9 -> wait n=3 values 5,1,9 exit 9.
;
; Build: nasm -f elf64 13-variadic-max.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
