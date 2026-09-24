; Exercise 22: stretch file copy mem
;
; STRETCH: copy 4 bytes between two mmap regions; checksum 10 for 1,2,3,4.
;
; Build: nasm -f elf64 22-stretch-file-copy-mem.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    srcinit db 1,2,3,4
section .text
    global _start
_start:
    ; mmap dst
    mov rax,9
    xor rdi,rdi
    mov rsi,4096
    mov rdx,3
    mov r10,0x22
    mov r8,-1
    xor r9,r9
    syscall
    mov rbx,rax
    lea rsi,[srcinit]
    mov rdi,rbx
    mov rcx,4
    rep movsb
    xor rdi,rdi
    movzx rax,byte [rbx]
    add rdi,rax
    movzx rax,byte [rbx+1]
    add rdi,rax
    movzx rax,byte [rbx+2]
    add rdi,rax
    movzx rax,byte [rbx+3]
    add rdi,rax
    mov rax,60
    syscall
