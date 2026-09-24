; Exercise 06: prologue locals
;
; Function stores local = rdi+1 on stack frame; returns it. Call with 41; exit 42.
;
; Build: nasm -f elf64 06-prologue-locals.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
