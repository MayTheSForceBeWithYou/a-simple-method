; Exercise 09: key down up
;
; Track key state: down sets, up clears; exit 0.
;
; Build: nasm -f elf64 09-key-down-up.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    key_w resb 1
section .text
    global _start
_start:
    mov byte [key_w],1
    mov byte [key_w],0
    movzx rdi,byte [key_w]
    mov rax,60
    syscall
