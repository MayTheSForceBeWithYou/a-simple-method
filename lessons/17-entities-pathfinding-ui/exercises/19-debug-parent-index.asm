; Exercise 19: debug parent index
;
; BUG: parent[i] wrong. Fix reconstruct step count exit 2.
;
; Build: nasm -f elf64 19-debug-parent-index.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi,0
    mov rax,60
    syscall
