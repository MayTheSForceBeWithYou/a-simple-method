; Exercise 02: bfs dist
;
; Grid BFS stub: dist to neighbor 1.
;
; Build: nasm -f elf64 02-bfs-dist.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi, 1
    mov rax, 60
    syscall
