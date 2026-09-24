# Learn x86-64 Assembly by Doing

Linux **x86-64**, **NASM**, **System V AMD64 ABI**, **Linux syscalls**.  
Path: absolute basics → CLI editor → tiny compiler → 2D game/sim skills at *RCT-depth engineering* (original work only).

## How this course is used

Work through lessons/ on your own time. Teaching content lives in each lesson's LESSON.md, exercises/, and solutions/. Build products (*.o, linked binaries) stay out of the tree — see .gitignore.

## Start here

1. Read [`docs/LEARNING_ROADMAP.md`](docs/LEARNING_ROADMAP.md) — phases, tools, milestones, how to use exercises vs solutions.
2. Begin at [`lessons/00-tools-registers-mov-syscall/LESSON.md`](lessons/00-tools-registers-mov-syscall/LESSON.md).
3. Work only under each lesson’s `exercises/`. Check `solutions/` after a real attempt.

## Build / run (early lessons)

```bash
cd lessons/00-tools-registers-mov-syscall/exercises
nasm -f elf64 01-exit-zero.asm -o /tmp/01.o
ld /tmp/01.o -o /tmp/01
/tmp/01; echo exit:$?
```

Many prompts repeat the build line in the file header. From lesson 09 onward, prefer the lesson `Makefile`.

## Layout

```
asm/
├── README.md
├── docs/LEARNING_ROADMAP.md
└── lessons/
    └── NN-slug/
        ├── LESSON.md
        ├── exercises/   # your work
        └── solutions/   # reference
```

## Toolchain

```bash
# Arch Linux WSL (distro name: arch) — from Windows: wsl -d arch -- ...
sudo pacman -Syu --needed nasm binutils make gdb
nasm -v
```

## Scope of this tree

- **00–04:** full lessons (≥24 exercises + solutions each).
- **05–18:** lesson outlines + starter drills (≥8 each); remaining drills noted in the roadmap for a follow-up fill.

No copyrighted Roller Coaster Tycoon assets or verbatim code — themes are inspirational only.
