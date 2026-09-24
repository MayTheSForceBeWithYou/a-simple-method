; Exercise 04: tree sum flat
;
; Simulate binary heap array dq 1,2,3,4,5 (5 nodes). Recursively sum heap indices. Exit 15.
;
; Build: nasm -f elf64 04-tree-sum-flat.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    heap dq 1,2,3,4,5
    n equ 5
section .text
    global _start
_start:
    xor rdi, rdi
    call heap_sum
    mov rdi, rax
    mov rax, 60
    syscall
heap_sum:
    cmp rdi, n
    jge .z
    push rdi
    mov rax, [heap+rdi*8]
    push rax
    mov rax, rdi
    imul rax, 2
    inc rax
    mov rdi, rax
    call heap_sum
    pop rdx
    add rdx, rax
    push rdx
    mov rdi, [rsp+8]
    imul rdi, 2
    add rdi, 2
    call heap_sum
    pop rdx
    add rax, rdx
    add rsp, 8
    ret
.z:
    xor rax, rax
    ret
