; Exercise 08: from scratch gap start
;
; FROM SCRATCH: gap buffer indices gap_start=0 gap_end=8 capacity 8 empty; exit gap_end-gap_start (=8 free).
;
; Build: nasm -f elf64 08-from-scratch-gap-start.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    gap_s resq 1
    gap_e resq 1
section .text
    global _start
_start:
    mov qword [gap_s], 0
    mov qword [gap_e], 8
    mov rdi, [gap_e]
    sub rdi, [gap_s]
    mov rax, 60
    syscall
