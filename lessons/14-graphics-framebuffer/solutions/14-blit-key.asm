; Exercise 14: blit key
;
; Blit with color key 0 skip; src 0,5,0,5 -> dst sum 10.
;
; Build: nasm -f elf64 14-blit-key.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    src db 0,5,0,5
section .bss
    dst resb 4
section .text
    global _start
_start:
    xor rcx,rcx
.l:
    cmp rcx,4
    jge .s
    mov al,[src+rcx]
    test al,al
    jz .n
    mov [dst+rcx],al
.n:
    inc rcx
    jmp .l
.s:
    xor rdi,rdi
    movzx rax,byte [dst]
    add rdi,rax
    movzx rax,byte [dst+1]
    add rdi,rax
    movzx rax,byte [dst+2]
    add rdi,rax
    movzx rax,byte [dst+3]
    add rdi,rax
    mov rax,60
    syscall
