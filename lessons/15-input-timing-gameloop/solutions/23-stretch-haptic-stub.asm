; Exercise 23: stretch haptic stub
;
; STRETCH: rumble frames remaining 2; exit 2.
;
; Build: nasm -f elf64 23-stretch-haptic-stub.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    rumble resq 1
section .text
    global _start
_start:
    mov qword [rumble],2
    mov rdi,[rumble]
    mov rax,60
    syscall
