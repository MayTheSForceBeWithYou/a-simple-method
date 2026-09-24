; Exercise 06: extern sim onefile
;
; Simulate two units in one file with global helper; exit 5.
;
; Build: nasm -f elf64 06-extern-sim-onefile.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    call helper
    mov rdi, rax
    mov rax, 60
    syscall
helper:
    mov rax, 5
    ret
