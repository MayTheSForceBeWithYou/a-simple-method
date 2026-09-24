; Exercise 18: spatial hash insert
;
; Insert entity into cell bucket count++; exit 1.
;
; Build: nasm -f elf64 18-spatial-hash-insert.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    count resq 1
section .text
    global _start
_start:
    inc qword [count]
    mov rdi,[count]
    mov rax,60
    syscall
