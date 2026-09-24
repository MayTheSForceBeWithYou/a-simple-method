; Exercise 11: delete forward
;
; "ABCD" cur=1 delete -> "ACD"; len=3 exit 3.
;
; Build: nasm -f elf64 11-delete-forward.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    buf db "ABCD",0
section .bss
    len resq 1
    cur resq 1
section .text
    global _start
_start:
    mov qword [len],4
    mov qword [cur],1
    mov rcx,[cur]
.l:
    mov rax,rcx
    inc rax
    cmp rax,[len]
    jge .fin
    mov al,[buf+rcx+1]
    mov [buf+rcx],al
    inc rcx
    jmp .l
.fin:
    dec qword [len]
    mov rdi,[len]
    mov rax,60
    syscall
