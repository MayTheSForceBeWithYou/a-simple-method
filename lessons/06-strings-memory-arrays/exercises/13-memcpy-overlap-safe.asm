; Exercise 13: memcpy forward
;
; Copy 8 bytes forward non-overlap; checksum low byte sum of dst. src 1..8 sum=36.
;
; Build: nasm -f elf64 13-memcpy-overlap-safe.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    src db 1,2,3,4,5,6,7,8
section .bss
    dst resb 8
section .text
    global _start
_start:
    lea rsi, [src]
    lea rdi, [dst]
    mov rcx, 8
    call memcpy
    xor rdi, rdi
    xor rcx, rcx
.sum:
    cmp rcx, 8
    jge .o
    movzx rax, byte [dst+rcx]
    add rdi, rax
    inc rcx
    jmp .sum
.o:
    mov rax, 60
    syscall
memcpy:
    ; TODO: implement memcpy
