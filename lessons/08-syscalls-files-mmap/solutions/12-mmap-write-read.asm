; Exercise 12: mmap write read
;
; mmap 4096; write 99 at +100; read back; exit 99. SYS_mmap=9 PROT_RW=3 MAP_PRIVATE|ANON=0x22
;
; Build: nasm -f elf64 12-mmap-write-read.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    mov rax,9
    xor rdi,rdi
    mov rsi,4096
    mov rdx,3
    mov r10,0x22
    mov r8,-1
    xor r9,r9
    syscall
    cmp rax,0
    jl .f
    mov rbx,rax
    mov byte [rbx+100],99
    movzx rdi, byte [rbx+100]
    mov rax,60
    syscall
.f:
    mov rdi,2
    mov rax,60
    syscall
