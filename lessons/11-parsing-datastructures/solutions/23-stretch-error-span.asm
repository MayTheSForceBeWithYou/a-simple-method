; Exercise 23: stretch error span
;
; STRETCH: error at offset 4 length 1; exit 4.
;
; Build: nasm -f elf64 23-stretch-error-span.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    err_off resq 1
section .text
    global _start
_start:
    mov qword [err_off],4
    mov rdi,[err_off]
    mov rax,60
    syscall
