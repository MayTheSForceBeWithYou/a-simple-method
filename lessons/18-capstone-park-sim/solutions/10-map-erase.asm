; Exercise 10: map erase
;
; Erase cell to EMPTY=0; exit 0.
;
; Build: nasm -f elf64 10-map-erase.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    map resb 16
section .text
    global _start
_start:
    mov byte [map+5],1
    mov byte [map+5],0
    movzx rdi,byte [map+5]
    mov rax,60
    syscall
