; Exercise 17: closure sim
;
; Pass context pointer in r12 (callee-saved): ctx dq 10; add_ctx(rdi) returns rdi+[ctx]. Call with 5 -> 15.
;
; Build: nasm -f elf64 17-closure-sim.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
