; Exercise 02: fixed add
;
; 1.5 + 2.5 in Q16.16; exit 4.
;
; Build: nasm -f elf64 02-fixed-add.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov eax, (1<<16)+(1<<15)
    mov ebx, (2<<16)+(1<<15)
    add eax, ebx
    shr eax, 16
    mov edi, eax
    mov rax, 60
    syscall
