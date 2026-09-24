; Exercise 16: mov imm vs reg
;
; Load 100 into rax (imm), copy to rbx, copy rbx to rdi, exit.
;
; Build: nasm -f elf64 16-mov-imm-vs-reg.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
