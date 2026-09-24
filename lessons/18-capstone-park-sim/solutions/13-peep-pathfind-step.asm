; Exercise 13: peep pathfind step
;
; Peep follows path; steps remaining 4; exit 4.
;
; Build: nasm -f elf64 13-peep-pathfind-step.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    steps resq 1
section .text
    global _start
_start:
    mov qword [steps],4
    mov rdi,[steps]
    mov rax,60
    syscall
