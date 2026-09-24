# Lesson 05 — Procedures & Recursion

## Goals
Deepen call/ret discipline: multiple locals, spilling, recursion depth, mutual recursion, tail-call opportunities (and when NASM/CPU won't help you).

## Outline (full drills next pass)
1. Multi-local frames and addressing via rbp
2. Saving all callee-saved you touch
3. Recursion patterns: factorial, fib, ackermann-lite, tree sum
4. Mutual recursion (even/odd)
5. Converting recursion → explicit stack

## Status
**FULL (this pass):** 24 exercises + solutions.

## Build
`nasm -f elf64 FILE -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?`
