; Exercise 07: callee saved
;
; Caller puts 9 in rbx. Callee must preserve rbx. Callee uses rbx temporarily but restores. Exit rbx (9).
;
; Build: nasm -f elf64 07-callee-saved.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
