; Exercise 07: peep happy
;
; happiness clamp 0..100; set 120->100.
;
; Build: nasm -f elf64 07-peep-happy.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, 120
    cmp rax, 100
    jle .ok
    mov rax, 100
.ok:
    mov rdi, rax
    mov rax, 60
    syscall
