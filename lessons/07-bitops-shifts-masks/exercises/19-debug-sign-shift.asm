; Exercise 19: debug sign shift
;
; BUG: used shr on negative intending arithmetic. Fix with sar; -16>>2 = -4; exit with al of -4 (252).
;
; Build: nasm -f elf64 19-debug-sign-shift.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax, -16
    shr rax, 2
    movzx rdi, al
    mov rax,60
    syscall
