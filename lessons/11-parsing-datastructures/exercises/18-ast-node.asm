; Exercise 18: ast node
;
; AST node kind=1 left=2 right=3; exit kind+left+right=6.
;
; Build: nasm -f elf64 18-ast-node.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
section .text
    global _start
_start:
    ; TODO: write your code here
