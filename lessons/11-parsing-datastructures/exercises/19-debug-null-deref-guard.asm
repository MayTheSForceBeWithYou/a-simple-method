; Exercise 19: debug null guard
;
; BUG: walks next without null check. Fix empty list sum=0.
;
; Build: nasm -f elf64 19-debug-null-deref-guard.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    xor rsi,rsi
    xor rdi,rdi
.l:
    ; BUG: missing null check
    add rdi,[rsi]
    mov rsi,[rsi+8]
    jmp .l
.d:
    mov rax,60
    syscall
