; Exercise 13: store through ptr
;
; lea rdx,[slot]; mov qword [rdx], 77; mov rdi,[slot]; exit.
;
; Build: nasm -f elf64 13-store-through-ptr.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
