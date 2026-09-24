; Exercise 19: debug dt units
;
; BUG: mixed ms/us. Fix treat 16000us as 16ms steps of 16 -> 1 step; exit 1.
;
; Build: nasm -f elf64 19-debug-dt-units.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax,16000
    xor rdx,rdx
    mov rbx,16
    div rbx
    mov rdi,rax
    and rdi,255
    mov rax,60
    syscall
