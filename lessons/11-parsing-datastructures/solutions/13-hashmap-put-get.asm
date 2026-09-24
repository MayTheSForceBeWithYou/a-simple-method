; Exercise 13: hashmap put get
;
; Simple open array slots[4]; put key hash 2 -> 42; get exit 42.
;
; Build: nasm -f elf64 13-hashmap-put-get.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    slots resq 4
section .text
    global _start
_start:
    mov qword [slots+16],42
    mov rdi,[slots+16]
    mov rax,60
    syscall
