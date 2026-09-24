; Exercise 13: codegen mov
;
; Emit conceptual: store imm 42 into slot; exit 42.
;
; Build: nasm -f elf64 13-codegen-mov.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
