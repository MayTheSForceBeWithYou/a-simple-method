; Exercise 23: stretch make dependency
;
; STRETCH: encode dependency count 3 objects; exit 3.
;
; Build: nasm -f elf64 23-stretch-make-dependency.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi,3
    mov rax,60
    syscall
