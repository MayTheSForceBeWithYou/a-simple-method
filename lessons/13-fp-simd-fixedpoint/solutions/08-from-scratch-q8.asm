; Exercise 08: from scratch q8
;
; FROM SCRATCH: Q8.8 1.5*2 exit integer 3.
;
; Build: nasm -f elf64 08-from-scratch-q8.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov eax, (1<<8)+(1<<7)
    mov ebx, 2<<8
    imul eax, ebx
    shr eax, 8
    mov edi, eax
    mov rax, 60
    syscall
