; Exercise 10: despawn freelist
;
; Free id 3 onto freelist top; exit 3.
;
; Build: nasm -f elf64 10-despawn-freelist.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    free_top resq 1
section .text
    global _start
_start:
    mov qword [free_top],3
    mov rdi,[free_top]
    mov rax,60
    syscall
