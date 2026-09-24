; Exercise 04: clamp fixed
;
; Clamp Q16.16 value 10<<16 to max 8<<16; exit 8.
;
; Build: nasm -f elf64 04-clamp-fixed.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov eax, 10<<16
    mov ebx, 8<<16
    cmp eax, ebx
    jle .ok
    mov eax, ebx
.ok:
    shr eax, 16
    mov edi, eax
    mov rax, 60
    syscall
