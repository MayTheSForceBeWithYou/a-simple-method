; Exercise 16: pitch bytes
;
; pitch=width*4 aligned up to 16: width=5 -> 20 align 32? 20; exit 20.
;
; Build: nasm -f elf64 16-pitch-bytes.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
