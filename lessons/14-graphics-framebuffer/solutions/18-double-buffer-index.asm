; Exercise 18: double buffer index
;
; Flip buffer index 0<->1; start 0 flip twice exit 0.
;
; Build: nasm -f elf64 18-double-buffer-index.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    idx resq 1
section .text
    global _start
_start:
    mov qword [idx],0
    xor qword [idx],1
    xor qword [idx],1
    mov rdi,[idx]
    mov rax,60
    syscall
