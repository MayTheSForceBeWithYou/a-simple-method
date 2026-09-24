; Exercise 25: adc chain
;
; Add two 128-bit values lo/hi: a=(1,0) b=(0xFFFFFFFFFFFFFFFF,0). Use add/adc. Exit with CF after adc (1) via setc.
;
; Build: nasm -f elf64 25-adc-chain.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
