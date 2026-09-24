; Exercise 23: stretch multiplayer stub
;
; STRETCH: net tick id 2; exit 2. (local stub)
;
; Build: nasm -f elf64 23-stretch-multiplayer-stub.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    tick_id resq 1
section .text
    global _start
_start:
    mov qword [tick_id],2
    mov rdi,[tick_id]
    mov rax,60
    syscall
