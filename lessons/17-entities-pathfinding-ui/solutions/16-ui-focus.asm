; Exercise 16: ui focus
;
; Tab cycles focus index mod 3; from 2 -> 0; exit 0.
;
; Build: nasm -f elf64 16-ui-focus.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    focus resq 1
section .text
    global _start
_start:
    mov qword [focus],2
    inc qword [focus]
    mov rax,[focus]
    xor rdx,rdx
    mov rbx,3
    div rbx
    mov [focus],rdx
    mov rdi,rdx
    mov rax,60
    syscall
