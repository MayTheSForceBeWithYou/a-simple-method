; Exercise 15: debug wrong arg reg
;
; BUG: second arg loaded into rdx instead of rsi. Fix add(2,40)=42.
;
; Build: nasm -f elf64 15-debug-wrong-arg-reg.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 2
    mov rsi, 40
    call add2
    mov rdi, rax
    mov rax, 60
    syscall

add2:
    mov rax, rdi
    add rax, rsi
    ret
