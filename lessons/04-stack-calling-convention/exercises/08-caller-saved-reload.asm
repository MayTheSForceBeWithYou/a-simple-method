; Exercise 08: caller saved reload
;
; Put 5 in rdx; call a function that returns 1; then add rdx — must reload rdx because caller-saved. Exit 6.
;
; Build: nasm -f elf64 08-caller-saved-reload.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
