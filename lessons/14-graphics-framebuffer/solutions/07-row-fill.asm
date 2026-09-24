; Exercise 07: row fill
;
; Fill 3 pixels with 9; exit mid.
;
; Build: nasm -f elf64 07-row-fill.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    row resb 3
section .text
    global _start
_start:
    mov byte [row], 9
    mov byte [row+1], 9
    mov byte [row+2], 9
    movzx rdi, byte [row+1]
    mov rax, 60
    syscall
