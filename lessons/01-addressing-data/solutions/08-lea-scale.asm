; Exercise 08: lea scale
;
; Without memory load: rbx=100, rcx=3. lea rdi,[rbx+rcx*4] (112), exit.
;
; Build: nasm -f elf64 08-lea-scale.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rbx, 100
    mov rcx, 3
    lea rdi, [rbx+rcx*4]
    mov rax, 60
    syscall
