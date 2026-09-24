; Exercise 03: bss store
;
; resb 1 in .bss. Store 7 into it, load into rdi, exit.
;
; Build: nasm -f elf64 03-bss-store.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    slot resb 1

section .text
    global _start
_start:
    mov byte [slot], 7
    movzx rdi, byte [slot]
    mov rax, 60
    syscall
