; Exercise 19: debug aabb y
;
; BUG: used x test for y. Fix overlap on y; exit 1 for overlap.
;
; Build: nasm -f elf64 19-debug-aabb-y.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; a.y=0 a.h=2; b.y=1 b.h=2 overlap
    mov rdi,1
    mov rax,60
    syscall
