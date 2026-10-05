; Exercise 12: nested frame
;
; outer calls inner; both have frames. inner returns rdi+rsi; outer adds 1. Call outer(10,20)->31.
;
; Build: nasm -f elf64 12-nested-frame.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 10
    mov rsi, 20
    call outer
    mov rdi, rax
    mov rax, 60
    syscall
outer:
    ; TODO: implement outer
inner:
    ; TODO: implement inner
