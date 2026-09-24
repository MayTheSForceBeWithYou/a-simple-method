; Exercise 16: debug callee clobber
;
; BUG: callee clobbers rbx without save. Fix; exit 11.
;
; Build: nasm -f elf64 16-debug-callee-clobber.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rbx, 11
    call evil
    mov rdi, rbx
    mov rax, 60
    syscall

evil:
    mov rbx, 0
    ret
