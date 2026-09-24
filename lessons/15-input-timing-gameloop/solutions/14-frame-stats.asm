; Exercise 14: frame stats
;
; fps counter frames=60 over 1s; exit 60.
;
; Build: nasm -f elf64 14-frame-stats.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    frames resq 1
section .text
    global _start
_start:
    mov qword [frames],60
    mov rdi,[frames]
    mov rax,60
    syscall
