; Exercise 05: makefile note
;
; Single-file stand-in: exit 0. (Real multi-file in EXERCISE.md style comment.)
;
; Build: nasm -f elf64 05-makefile-note.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
; When expanding: nasm -f elf64 a.asm b.asm; ld a.o b.o -o prog
section .text
    global _start
_start:
    mov rax,60
    xor rdi,rdi
    syscall
