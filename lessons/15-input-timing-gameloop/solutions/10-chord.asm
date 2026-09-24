; Exercise 10: chord
;
; W and Shift both down -> run=1; exit 1.
;
; Build: nasm -f elf64 10-chord.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    w resb 1
    shift resb 1
section .text
    global _start
_start:
    mov byte [w],1
    mov byte [shift],1
    movzx eax,byte [w]
    and al,[shift]
    movzx rdi,al
    mov rax,60
    syscall
