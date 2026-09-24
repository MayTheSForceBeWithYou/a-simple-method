; Exercise 11: track piece rotate
;
; Rotate piece dir 0..3; 3+1 -> 0; exit 0.
;
; Build: nasm -f elf64 11-track-piece-rotate.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    dir resq 1
section .text
    global _start
_start:
    mov qword [dir],3
    inc qword [dir]
    mov rax,[dir]
    and rax,3
    mov [dir],rax
    mov rdi,rax
    mov rax,60
    syscall
