; Exercise 09: q16 from int
;
; Convert 5 to Q16.16; >>16 back exit 5.
;
; Build: nasm -f elf64 09-q16-from-int.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov eax,5
    shl eax,16
    shr eax,16
    mov edi,eax
    mov rax,60
    syscall
