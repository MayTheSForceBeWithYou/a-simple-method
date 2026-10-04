; Exercise 19: extern declare
;
; %pragma or just comment extern foo; local call exit 9.
;
; Build: nasm -f elf64 19-extern-declare.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    call foo
    mov rdi,rax
    mov rax,60
    syscall
foo:
    ; TODO: implement foo
