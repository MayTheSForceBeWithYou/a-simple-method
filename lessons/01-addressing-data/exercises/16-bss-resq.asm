; Exercise 16: bss resq
;
; resq 4. Store 1,2,3,4 into consecutive qwords; sum into rdi (10); exit.
;
; Build: nasm -f elf64 16-bss-resq.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
