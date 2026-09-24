; Exercise 17: utf8 ascii cursor
;
; ASCII-only: moving right increments cursor by 1; exit 5 after 5 moves.
;
; Build: nasm -f elf64 17-utf8-ascii-cursor.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    cur resq 1
section .text
    global _start
_start:
    mov qword [cur],0
    mov rcx,5
.l:
    inc qword [cur]
    loop .l
    mov rdi,[cur]
    mov rax,60
    syscall
