; Exercise 08: caller saved reload
;
; Put 5 in rdx; call a function that returns 1; then add rdx — must reload rdx because caller-saved. Exit 6.
;
; Build: nasm -f elf64 08-caller-saved-reload.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdx, 5
    push rdx
    call one
    pop rdx
    add rax, rdx
    mov rdi, rax
    mov rax, 60
    syscall

one:
    ; TODO: implement one
