; Exercise 27: stretch pow2
;
; STRETCH: compute 2^8 with a loop of adds or imul (you may use labels/jmp — preview of 03). Exit 256&255=0 OR exit 0 after verifying — prefer: put 256 in rdi and exit — wait exit max 255. Exit (2^8 - 256)=0 by computing rax=1; shift preview: use 8 imuls by 2 starting from 1, then sub 256, exit 0.
;
; Build: nasm -f elf64 27-stretch-pow2.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
