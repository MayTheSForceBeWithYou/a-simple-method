; Exercise 07: load stub
;
; Pretend load sets len=3; exit 3.
;
; Build: nasm -f elf64 07-load-stub.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    len resq 1
section .text
    global _start
_start:
    mov qword [len], 3
    mov rdi, [len]
    mov rax, 60
    syscall
