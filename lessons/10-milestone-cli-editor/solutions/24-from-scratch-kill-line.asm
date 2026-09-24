; Exercise 24: from scratch kill line
;
; FROM SCRATCH: "ab\ncd" kill from cur=0 to newline -> len becomes 3 ("\ncd"); exit 3.
;
; Build: nasm -f elf64 24-from-scratch-kill-line.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    buf db "ab",10,"cd",0
section .bss
    len resq 1
    cur resq 1
section .text
    global _start
_start:
    mov qword [len],5
    mov qword [cur],0
    ; find nl
    mov rcx,0
.f:
    cmp byte [buf+rcx],10
    je .got
    inc rcx
    jmp .f
.got:
    ; delete [0,rcx)
    mov r8,rcx
    mov r9,[len]
    mov rdi,0
    mov rsi,r8
.cpy:
    cmp rsi,r9
    jge .done
    mov al,[buf+rsi]
    mov [buf+rdi],al
    inc rsi
    inc rdi
    jmp .cpy
.done:
    mov [len],rdi
    mov rdi,[len]
    mov rax,60
    syscall
