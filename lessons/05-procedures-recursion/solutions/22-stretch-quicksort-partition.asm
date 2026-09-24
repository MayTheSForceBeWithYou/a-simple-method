; Exercise 22: stretch partition
;
; STRETCH: partition helper for [1,5,2,4] pivot last; after partition count of elems <=pivot left. Simpler: partition returns final pivot index for arr. Exit index 2 for this data if pivot=4... Use lomuto; exit pivot index.
;
; Build: nasm -f elf64 22-stretch-quicksort-partition.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .data
    arr dq 1,5,2,4
section .text
    global _start
_start:
    lea rdi, [arr]
    xor rsi, rsi
    mov rdx, 3
    call partition
    mov rdi, rax
    mov rax, 60
    syscall
partition:
    ; rdi=base rsi=lo rdx=hi
    mov r8, [rdi+rdx*8] ; pivot
    mov rax, rsi
    dec rax             ; i
    mov rcx, rsi
.l:
    cmp rcx, rdx
    jge .fin
    cmp qword [rdi+rcx*8], r8
    jg .nx
    inc rax
    mov r9, [rdi+rax*8]
    mov r10, [rdi+rcx*8]
    mov [rdi+rax*8], r10
    mov [rdi+rcx*8], r9
.nx:
    inc rcx
    jmp .l
.fin:
    inc rax
    mov r9, [rdi+rax*8]
    mov r10, [rdi+rdx*8]
    mov [rdi+rax*8], r10
    mov [rdi+rdx*8], r9
    ret
