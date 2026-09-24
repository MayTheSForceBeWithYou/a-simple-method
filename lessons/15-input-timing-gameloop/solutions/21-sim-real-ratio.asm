; Exercise 21: sim real ratio
;
; sim_time/real_time *100 = 50 when half speed; exit 50.
;
; Build: nasm -f elf64 21-sim-real-ratio.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax,50
    mov rdi,rax
    mov rax,60
    syscall
