; Exercise 22: stretch itoa
;
; STRETCH: itoa 123 into buffer; write then exit 0. Also set len cell=3 and exit 3 instead if no write needed.
;
; Build: nasm -f elf64 22-stretch-itoa.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    buf resb 16
    len resq 1
section .text
    global _start
_start:
    mov rdi, 123
    lea rsi, [buf]
    call itoa
    mov rdi, rax
    mov rax, 60
    syscall
itoa:
    ; TODO: implement itoa
