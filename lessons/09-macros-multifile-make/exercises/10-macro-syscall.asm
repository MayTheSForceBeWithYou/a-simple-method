; Exercise 10: macro syscall
;
; %macro SYSCALL3 0 ... uses rax rdi rsi rdx already set; exit after write. Print "K\n" exit 0.
;
; Build: nasm -f elf64 10-macro-syscall.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p
;
; --- your code below ---
