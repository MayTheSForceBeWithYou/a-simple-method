; Exercise 07: tail ish loop
;
; Rewrite rec sum_to as loop (tail form). sum_to 6 = 21.
;
; Build: nasm -f elf64 07-tail-ish-loop.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 6
    call sum_to
    mov rdi, rax
    mov rax, 60
    syscall
sum_to:
    ; TODO: implement sum_to
