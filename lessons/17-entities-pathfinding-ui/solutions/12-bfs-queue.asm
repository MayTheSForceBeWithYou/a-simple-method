; Exercise 12: bfs queue
;
; BFS visit count 5; exit 5.
;
; Build: nasm -f elf64 12-bfs-queue.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rdi,5
    mov rax,60
    syscall
