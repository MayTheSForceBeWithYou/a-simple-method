; Exercise 21: debug cursor oob
;
; BUG: cursor can exceed len. Clamp cur to len; start cur=9 len=3; exit 3.
;
; Build: nasm -f elf64 21-debug-cursor-oob.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    cur resq 1
    len resq 1
section .text
    global _start
_start:
    mov qword [cur],9
    mov qword [len],3
    mov rax,[cur]
    cmp rax,[len]
    jbe .ok
    mov rax,[len]
    mov [cur],rax
.ok:
    mov rdi,[cur]
    mov rax,60
    syscall
