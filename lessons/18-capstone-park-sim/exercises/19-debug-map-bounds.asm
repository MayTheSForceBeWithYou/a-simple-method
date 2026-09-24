; Exercise 19: debug map bounds
;
; BUG: no bounds check. Clamp x=99 to w-1=7; exit 7.
;
; Build: nasm -f elf64 19-debug-map-bounds.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax,99
    mov rdi,rax
    and rdi,255
    mov rax,60
    syscall
