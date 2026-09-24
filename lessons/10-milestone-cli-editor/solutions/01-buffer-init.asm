; Exercise 01: buffer init
;
; resb 64 buffer; store length 0 in len dq; exit len.
;
; Build: nasm -f elf64 01-buffer-init.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    buf resb 64
    len resq 1
section .text
    global _start
_start:
    mov qword [len], 0
    mov rdi, [len]
    mov rax, 60
    syscall
