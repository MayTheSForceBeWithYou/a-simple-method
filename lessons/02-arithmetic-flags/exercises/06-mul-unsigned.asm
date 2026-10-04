; Exercise 06: mul unsigned
;
; rax=100000, rbx=3; mul rbx; exit with low 8 bits of rax via movzx... actually exit with rax truncated: use rdi=rax after mul if fits; expect 300000 mod 256? Better: exit status = (rax & 0xff) after confirming product — use mov rdi, rax then and rdi, 255. Product 300000. Status 300000&255=224.
;
; Build: nasm -f elf64 06-mul-unsigned.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
