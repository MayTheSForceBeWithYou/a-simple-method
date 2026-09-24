; Exercise 02: place track
;
; Track piece type 3; exit 3.
;
; Build: nasm -f elf64 02-place-track.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 3
    mov rax, 60
    syscall
