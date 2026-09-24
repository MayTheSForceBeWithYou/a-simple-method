; Exercise 14: multifile sim globals
;
; Simulate module: global helper_add; call with 20,22 exit 42.
;
; Build: nasm -f elf64 14-multifile-sim-globals.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
    global helper_add
_start:
    mov rdi,20
    mov rsi,22
    call helper_add
    mov rdi,rax
    mov rax,60
    syscall
helper_add:
    mov rax,rdi
    add rax,rsi
    ret
