; Exercise 19: bytecode jump
;
; Bytecode: JMP +2 over LOAD 99, LOAD 5, HALT; exit 5.
;
; Build: nasm -f elf64 19-bytecode-jump.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
