; Exercise 03: memcmp
;
; memcmp 3 bytes; equal -> 0 exit.
;
; Build: nasm -f elf64 03-memcmp.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    a db 1,2,3
    b db 1,2,3
section .text
    global _start
_start:
    lea rdi, [a]
    lea rsi, [b]
    mov rdx, 3
    call memcmp
    mov rdi, rax
    mov rax, 60
    syscall
memcmp:
    ; TODO: implement memcmp
