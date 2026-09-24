; Exercise 17: panel layout
;
; Stack y += h+pad; h=10 pad=2 twice from 0 -> 24; exit 24.
;
; Build: nasm -f elf64 17-panel-layout.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    xor rdi,rdi
    add rdi,12
    add rdi,12
    mov rax,60
    syscall
