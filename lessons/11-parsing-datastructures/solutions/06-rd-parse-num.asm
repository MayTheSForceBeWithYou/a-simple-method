; Exercise 06: rd parse num
;
; Parse '3' into value; exit 3.
;
; Build: nasm -f elf64 06-rd-parse-num.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    s db "3",0
section .text
    global _start
_start:
    movzx rdi, byte [s]
    sub rdi, '0'
    mov rax, 60
    syscall
