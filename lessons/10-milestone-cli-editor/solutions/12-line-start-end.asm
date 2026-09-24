; Exercise 12: line start end
;
; In "ab\ncd" find line start for cur=4 (index of c)->3; exit 3.
;
; Build: nasm -f elf64 12-line-start-end.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    buf db "ab",10,"cd",0
section .text
    global _start
_start:
    mov rcx,4
.l:
    test rcx,rcx
    jz .d
    dec rcx
    cmp byte [buf+rcx],10
    jne .l
    inc rcx
.d:
    mov rdi,rcx
    mov rax,60
    syscall
