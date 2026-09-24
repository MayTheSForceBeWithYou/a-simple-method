; Exercise 10: insert middle
;
; buf "AC" len2 cur1; insert B -> "ABC"; exit middle byte 66.
;
; Build: nasm -f elf64 10-insert-middle.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    buf db "AC",0,0,0,0
section .bss
    len resq 1
    cur resq 1
section .text
    global _start
_start:
    mov qword [len],2
    mov qword [cur],1
    ; shift right from end
    mov rcx,[len]
.shift:
    cmp rcx,[cur]
    jl .put
    mov al,[buf+rcx-1]
    mov [buf+rcx],al
    dec rcx
    jmp .shift
.put:
    mov byte [buf+1],'B'
    inc qword [len]
    movzx rdi, byte [buf+1]
    mov rax,60
    syscall
