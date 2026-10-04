; Exercise 14: memchr
;
; Find 7 in bytes 3,5,7,9; index 2.
;
; Build: nasm -f elf64 14-memchr.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    buf db 3,5,7,9
section .text
    global _start
_start:
    lea rdi, [buf]
    mov rsi, 7
    mov rdx, 4
    call memchr_idx
    mov rdi, rax
    mov rax, 60
    syscall
memchr_idx:
    ; TODO: implement memchr_idx
