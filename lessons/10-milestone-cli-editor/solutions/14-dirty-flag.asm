; Exercise 14: dirty flag
;
; Edit sets dirty=1; save clears; exit dirty 0.
;
; Build: nasm -f elf64 14-dirty-flag.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    dirty resb 1
section .text
    global _start
_start:
    mov byte [dirty],1
    ; save
    mov byte [dirty],0
    movzx rdi, byte [dirty]
    mov rax,60
    syscall
