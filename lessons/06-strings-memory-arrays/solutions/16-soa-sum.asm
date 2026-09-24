; Exercise 16: soa sum
;
; SoA xs={1,2,3} ys={4,5,6}; sum all 21.
;
; Build: nasm -f elf64 16-soa-sum.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    xs dq 1,2,3
    ys dq 4,5,6
section .text
    global _start
_start:
    mov rdi, [xs]
    add rdi, [xs+8]
    add rdi, [xs+16]
    add rdi, [ys]
    add rdi, [ys+8]
    add rdi, [ys+16]
    mov rax, 60
    syscall
