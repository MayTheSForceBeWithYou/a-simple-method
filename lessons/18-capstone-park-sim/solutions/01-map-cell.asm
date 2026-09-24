; Exercise 01: map cell
;
; Set cell type path=1; exit 1.
;
; Build: nasm -f elf64 01-map-cell.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    map resb 256
section .text
    global _start
_start:
    mov byte [map+10], 1
    movzx rdi, byte [map+10]
    mov rax, 60
    syscall
