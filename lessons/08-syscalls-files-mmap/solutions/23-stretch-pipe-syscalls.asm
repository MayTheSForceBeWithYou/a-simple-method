; Exercise 23: stretch pipe note
;
; STRETCH: SYS_pipe=22 into fds array; if success exit 0. (May work)
;
; Build: nasm -f elf64 23-stretch-pipe-syscalls.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    fds resd 2
section .text
    global _start
_start:
    mov rax,22
    lea rdi,[fds]
    syscall
    mov rdi,rax
    mov rax,60
    syscall
