; Exercise 09: insert at cursor
;
; Buffer empty; cursor 0; insert "X"; len=1 cursor=1; exit cursor.
;
; Build: nasm -f elf64 09-insert-at-cursor.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    buf resb 64
    len resq 1
    cur resq 1
section .text
    global _start
_start:
    mov qword [len],0
    mov qword [cur],0
    mov rcx,[cur]
    mov byte [buf+rcx],'X'
    inc qword [len]
    inc qword [cur]
    mov rdi,[cur]
    mov rax,60
    syscall
