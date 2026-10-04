; Exercise 12: strcat lite
;
; dst has "Hi", append "!", len of dst after = 3; exit 3.
;
; Build: nasm -f elf64 12-strcat-lite.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    dst db "Hi",0,0,0,0
    src db "!",0
section .text
    global _start
_start:
    lea rdi, [dst]
    lea rsi, [src]
    call strcat
    lea rdi, [dst]
    call strlen
    mov rdi, rax
    mov rax, 60
    syscall
strcat:
    ; TODO: implement strcat
strlen:
    ; TODO: implement strlen
