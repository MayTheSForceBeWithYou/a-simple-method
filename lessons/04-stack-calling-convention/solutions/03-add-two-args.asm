; Exercise 03: add two args
;
; Function add(rdi,rsi)->rax. Call with 10,32; exit 42.
;
; Build: nasm -f elf64 03-add-two-args.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 10
    mov rsi, 32
    call add2
    mov rdi, rax
    mov rax, 60
    syscall

add2:
    mov rax, rdi
    add rax, rsi
    ret
