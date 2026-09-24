; Exercise 05: mov chain
;
; Set al=3, bl=5, cl=7. Sum into dil, movzx to rdi, exit (expect 15).
;
; Build: nasm -f elf64 05-mov-chain.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
