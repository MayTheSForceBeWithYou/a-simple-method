; Exercise 10: factorial iter proc
;
; fact(n) iterative as procedure. fact(5)=120; exit 120&255=120.
;
; Build: nasm -f elf64 10-factorial-iter-proc.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 5
    call fact
    mov rdi, rax
    and rdi, 255
    mov rax, 60
    syscall

fact:
    ; TODO: implement fact
