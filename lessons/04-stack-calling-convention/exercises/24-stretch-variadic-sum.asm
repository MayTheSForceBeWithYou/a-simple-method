; Exercise 24: stretch variadic sum
;
; STRETCH: sum_n(n, ...) where n in rdi, then n qwords on stack. sum_n(4, 3,4,5,6)=18.
;
; Build: nasm -f elf64 24-stretch-variadic-sum.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
