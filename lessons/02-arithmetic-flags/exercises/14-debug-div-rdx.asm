; Exercise 14: debug div rdx
;
; BUG: forgot xor rdx,rdx before div. Fix; 100/10 quot exit 10.
;
; Build: nasm -f elf64 14-debug-div-rdx.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 100
    mov rbx, 10
    div rbx
    mov rdi, rax
    mov rax, 60
    syscall
