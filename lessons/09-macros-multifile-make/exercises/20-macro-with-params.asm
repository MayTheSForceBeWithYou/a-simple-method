; Exercise 20: macro with params
;
; %macro ADD3 3; mov rax,%1; add %2; add %3; ADD3 10,20,12 exit 42.
;
; Build: nasm -f elf64 20-macro-with-params.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
