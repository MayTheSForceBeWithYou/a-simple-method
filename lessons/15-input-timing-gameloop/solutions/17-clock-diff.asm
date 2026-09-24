; Exercise 17: clock diff
;
; t1-t0 = 40; exit 40.
;
; Build: nasm -f elf64 17-clock-diff.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax,100
    mov rbx,60
    sub rax,rbx
    mov rdi,rax
    mov rax,60
    syscall
