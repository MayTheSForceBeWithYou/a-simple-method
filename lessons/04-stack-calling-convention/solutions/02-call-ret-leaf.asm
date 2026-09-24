; Exercise 02: call ret leaf
;
; Write leaf answer that returns 42 in rax. call it; exit with that.
;
; Build: nasm -f elf64 02-call-ret-leaf.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    call answer
    mov rdi, rax
    mov rax, 60
    syscall

answer:
    mov rax, 42
    ret
