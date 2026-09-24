; Exercise 23: leaf no frame
;
; Leaf mul3(rdi)=rdi*3 without prologue. Exit 42 for input 14.
;
; Build: nasm -f elf64 23-leaf-no-frame.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 14
    call mul3
    mov rdi, rax
    mov rax, 60
    syscall

mul3:
    mov rax, rdi
    imul rax, 3
    ret
