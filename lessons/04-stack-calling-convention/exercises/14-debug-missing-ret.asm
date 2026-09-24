; Exercise 14: debug missing ret
;
; BUG: function falls through. Fix with ret. Should exit 3.
;
; Build: nasm -f elf64 14-debug-missing-ret.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    call three
    mov rdi, rax
    mov rax, 60
    syscall

three:
    mov rax, 3
