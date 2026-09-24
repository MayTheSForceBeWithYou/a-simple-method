; Exercise 19: debug lea load
;
; BUG: used lea to 'load' value. Fix to mov from memory; x dq 55; exit 55.
;
; Build: nasm -f elf64 19-debug-lea-load.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    x dq 55

section .text
    global _start
_start:
    mov rdi, [x]
    mov rax, 60
    syscall
