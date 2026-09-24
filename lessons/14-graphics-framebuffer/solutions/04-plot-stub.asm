; Exercise 04: plot stub
;
; Plot color 7 at index 0; exit 7.
;
; Build: nasm -f elf64 04-plot-stub.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    fb resb 16
section .text
    global _start
_start:
    mov byte [fb], 7
    movzx rdi, byte [fb]
    mov rax, 60
    syscall
