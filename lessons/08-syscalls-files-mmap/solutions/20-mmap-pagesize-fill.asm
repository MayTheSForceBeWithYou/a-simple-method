; Exercise 20: mmap pagesize fill
;
; Fill first 16 bytes of mmap with 1; sum=16; exit 16.
;
; Build: nasm -f elf64 20-mmap-pagesize-fill.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
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
    mov rbx,rax
    mov rcx,16
    mov rdi,rbx
    mov al,1
    rep stosb
    xor rdi,rdi
    xor rcx,rcx
.s:
    cmp rcx,16
    jge .o
    movzx rax, byte [rbx+rcx]
    add rdi,rax
    inc rcx
    jmp .s
.o:
    mov rax,60
    syscall
