; Exercise 17: void side effect
;
; Procedure writes byte '!' and newline to a global buf via args (rsi=buf). Then write syscall from _start. Exit 0.
;
; Build: nasm -f elf64 17-void-side-effect.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
