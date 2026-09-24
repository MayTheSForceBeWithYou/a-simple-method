; Exercise 22: stretch partition
;
; STRETCH: partition helper for [1,5,2,4] pivot last; after partition count of elems <=pivot left. Simpler: partition returns final pivot index for arr. Exit index 2 for this data if pivot=4... Use lomuto; exit pivot index.
;
; Build: nasm -f elf64 22-stretch-quicksort-partition.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
;
; --- your code below ---
