; Exercise 19: debug offset bpp
;
; BUG: used *3 for RGBA8888. Fix *4; x=2 offset=8; exit 8.
;
; Build: nasm -f elf64 19-debug-offset-bpp.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi,2
    imul rdi,4
    mov rax,60
    syscall
