; Exercise 05: save r12
;
; Use r12 in callee; must push/pop. Caller expects r12=42 still; exit 42.
;
; Build: nasm -f elf64 05-save-r12.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
