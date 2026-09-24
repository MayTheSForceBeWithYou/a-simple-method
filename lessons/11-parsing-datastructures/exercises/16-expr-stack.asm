; Exercise 16: expr stack
;
; Shunting: push 2,3, add -> 5; exit 5.
;
; Build: nasm -f elf64 16-expr-stack.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
