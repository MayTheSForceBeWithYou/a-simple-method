; Exercise 06: aos sum
;
; AoS records {dq x,y} two ents. Sum all coords exit.
;
; Build: nasm -f elf64 06-aos-sum.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    ; (1,2), (3,4)
    rec dq 1,2, 3,4
section .text
    global _start
_start:
    xor rdi, rdi
    add rdi, [rec]
    add rdi, [rec+8]
    add rdi, [rec+16]
    add rdi, [rec+24]
    mov rax, 60
    syscall
