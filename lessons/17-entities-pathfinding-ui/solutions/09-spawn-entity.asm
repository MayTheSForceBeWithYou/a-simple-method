; Exercise 09: spawn entity
;
; Bump entity id; first spawn id=1; exit 1.
;
; Build: nasm -f elf64 09-spawn-entity.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .bss
    next_id resq 1
section .text
    global _start
_start:
    inc qword [next_id]
    mov rdi,[next_id]
    mov rax,60
    syscall
