; Exercise 15: aos scale
;
; AoS {x,y} *2 for one entity {3,4}->6,8; exit x+y=14.
;
; Build: nasm -f elf64 15-aos-scale.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    ent dq 3,4
section .text
    global _start
_start:
    shl qword [ent], 1
    shl qword [ent+8], 1
    mov rdi, [ent]
    add rdi, [ent+8]
    mov rax, 60
    syscall
