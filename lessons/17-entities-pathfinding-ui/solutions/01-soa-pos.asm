; Exercise 01: soa pos
;
; xs[1]=5 ys[1]=6; exit xs+ys 11.
;
; Build: nasm -f elf64 01-soa-pos.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    xs dq 0,5,0
    ys dq 0,6,0
section .text
    global _start
_start:
    mov rdi, [xs+8]
    add rdi, [ys+8]
    mov rax, 60
    syscall
