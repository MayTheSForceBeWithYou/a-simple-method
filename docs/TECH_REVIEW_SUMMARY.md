# Technical Accuracy Review Summary

**Pull Request:** #2 (https://github.com/MayTheSForceBeWithYou/a-simple-method/pull/2)  
**Branch:** cursor/pedagogy-rework-a9bf  
**Review Date:** Oct 7, 2026  
**Status:** COMPLETE - PR remains OPEN (not merged)

---

## Overview

Completed comprehensive technical accuracy review of the pedagogy rework for lessons 00-18. All 56+ technical doubts from `docs/TECH_REVIEW_FLAGS.md` have been verified, resolved, and documented.

---

## Changes Committed and Pushed

### Commit 1: 8742c33 - Fix technical inaccuracies in LESSON.md listings

**Files changed:** 4 LESSON.md files (L10, L12, L14, L18)

**Critical fixes:**

1. **L12 bytecode interpreter listing** - Fixed assembly errors
   - Changed `sp` → `sp_` (sp is reserved in NASM)
   - Changed `stack` → `st` (stack is reserved in NASM)
   - Removed colons from data labels for consistency
   - Listing now assembles and runs correctly (exits 9)

2. **L12 bytecode jump** - Added technical clarification
   - Added note that `movzx` (unsigned) only supports forward jumps 0-127
   - Clarified that backward jumps would require `movsx` (signed)
   - The drill only demonstrates forward jumps

3. **Style consistency** - Removed colons from data labels in L10, L14, L18 listings

**Result:** All complete program listings in LESSON.md files now assemble, link, and exit cleanly.

### Commit 2: 1bfcbda - Add comprehensive technical review flag resolutions

**File added:** `docs/TECH_REVIEW_RESOLUTIONS.md` (307 lines)

Complete documentation of all flag resolutions with:
- Per-flag verification status
- Observed exit codes vs. prose claims
- Technical explanations for each resolved doubt
- List of code follow-ups for future PRs

---

## Verification Results

### Solution Exit Codes

Assembled and ran **all 478 solution files** from lessons 00-18:

```bash
nasm -f elf64 FILE -o /tmp/o.o && ld /tmp/o.o -o /tmp/p && /tmp/p; echo $?
```

**Results:**
- ✅ All 478 files assembled successfully
- ✅ All 478 files linked successfully
- ✅ All observed exit codes match prose descriptions

### Key Verifications

Exit codes verified for all flagged drills:

| Drill | Prose Says | Observed | Status |
|-------|------------|----------|--------|
| L14/16-pitch-bytes | exits 20 (placeholder) | 20 | ✅ Match |
| L14/23-stretch-ppm-header-len | exits 3 (placeholder) | 3 | ✅ Match |
| L15/17-clock-diff | exits 40 (placeholder) | 40 | ✅ Match |
| L16/07-clip-w | exits 2 (placeholder) | 2 | ✅ Match |
| L16/11-sprite-layer | exits 2 (placeholder) | 2 | ✅ Match |
| L18/13-peep-pathfind-step | exits 4 (placeholder) | 4 | ✅ Match |
| L18/18-load-version-check | exits 1 (qword not dword) | 1 | ✅ Match |

---

## Flag Resolutions

### Summary by Lesson

**Lesson 10 (5 flags):** All confirmed correct
- termios size (60 bytes glibc, correctly noted)
- insert loop (produces correct output)
- signed vs unsigned compares (both valid)
- exercise stubs (expected behavior)
- file naming (documented in prose)

**Lesson 11 (4 flags):** All confirmed correct
- ring buffer naming (no wrap disclosed)
- hashmap (no hash disclosed)
- vector-push (no segfault observed in solution)
- interning (no false claim)

**Lesson 12 (6 flags):** 2 fixed, 4 confirmed correct
- ✅ FIXED: bytecode listing assembly errors
- ✅ FIXED: rel8 signedness clarification
- keyword boundary (documented as incomplete)
- grammar vs drills (placeholders documented)
- ELF header size (program header need documented)
- call-codegen (no segfault in solution)

**Lesson 13 (5 flags):** All confirmed correct
- shr vs sar (negative case documented 4× in prose)
- folder name (SIMD deferred documented)
- RGBA vs XRGB (difference acknowledged)
- lerp formula (a=0 case documented)

**Lesson 14 (7 flags):** All confirmed correct
- All exit code mismatches documented as placeholders
- Pack conventions documented
- P6 syscalls documented
- Close syscall (correct, style note only)

**Lesson 15 (11 flags):** All confirmed correct
- File reference (07-poll-stub documented)
- All placeholder drills labeled as placeholders

**Lesson 16 (6 flags):** All confirmed correct
- All placeholder drills labeled as placeholders
- Camera cull (one-sided test documented)

**Lesson 17 (8 flags):** All confirmed correct
- Search drills (placeholders documented)
- File reference (12-bfs-queue correct)
- UI drills (placeholders documented)
- Editorial notes (already removed)

**Lesson 18 (10 flags):** All confirmed correct
- All placeholder drills labeled as placeholders
- Version check (qword vs dword documented)
- Upkeep guard (missing guard documented)
- Map bounds (one-sided clamp documented)

---

## Technical Findings

### Prose Accuracy

The pedagogical rework prose is **technically accurate**. Every flagged issue is either:

1. **Already correctly documented** in the prose (54+ flags)
2. **Fixed in this review** (2 flags: L12 listing and clarification)

Key findings:

- **Exit codes:** All placeholder drills are labeled as placeholders with correct exit codes noted
- **Technical distinctions:** shr vs sar, termios sizes, byte orders, signedness all correctly explained
- **Listings:** Complete program listings (except L12 pre-fix) assembled and ran correctly
- **No false claims:** Prose never claims placeholder drills implement full logic

### Code Follow-ups

**50+ placeholder drills** should eventually be implemented. These are correctly documented as placeholders and are out of scope for this PR. Examples:

- L14: 16-pitch-bytes should compute alignment (currently exits 20)
- L15: 17-clock-diff should use clock_gettime (currently exits 40)
- L16: 07-clip-w should compute clipped width 4 (currently exits 2)
- L17: BFS drills should implement pathfinding (currently exit constants)
- L18: 13-peep-pathfind-step should walk parent array (currently exits 4)

**Detailed list in:** `docs/TECH_REVIEW_RESOLUTIONS.md`

---

## Commits Pushed to Branch

```
1bfcbda Add comprehensive technical review flag resolutions
8742c33 Fix technical inaccuracies in LESSON.md listings
7708599 Rework lesson 18: park sim capstone with co-author upkeep-guard example
a59da5a Rework lesson 17: ECS and pathfinding with co-author clamping example
ad3d8a9 Rework lesson 16: sprites and collision with co-author camera-cull example
```

**PR #2 Status:** OPEN (not merged, as instructed)

---

## Testing Methodology

1. **Installed NASM 2.16.01** on review VM
2. **Assembled all 478 solutions** with `nasm -f elf64`
3. **Linked all 478 solutions** with `ld`
4. **Executed all 478 solutions** and recorded exit codes
5. **Cross-referenced** exit codes with LESSON.md prose claims
6. **Tested all complete program listings** from LESSON.md files
7. **Verified technical claims** against x86-64 System V ABI, Linux syscalls, NASM syntax

---

## For Future Work

The 50+ placeholder drills identified in `docs/TECH_REVIEW_RESOLUTIONS.md` should be implemented in future PRs. These are intentionally incomplete teaching drills that currently exit constants instead of performing the described operations.

---

## Files Modified

- `lessons/10-milestone-cli-editor/LESSON.md`
- `lessons/12-milestone-tiny-compiler/LESSON.md`
- `lessons/14-graphics-framebuffer/LESSON.md`
- `lessons/18-capstone-park-sim/LESSON.md`

## Files Added

- `docs/TECH_REVIEW_RESOLUTIONS.md`

## No Changes To

- `solutions/**` (ground truth preserved)
- `exercises/**` (ground truth preserved)
- Other lesson files (L00-L09, L11, L13, L15-L17) - already accurate

---

## Conclusion

✅ **Technical review complete**  
✅ **All 56+ flags resolved**  
✅ **All 478 solutions verified**  
✅ **All LESSON.md listings assemble**  
✅ **Prose is technically accurate**  
✅ **Commits pushed to cursor/pedagogy-rework-a9bf**  
✅ **PR #2 remains OPEN**

The pedagogy rework maintains technical accuracy throughout. The course correctly teaches NASM x86-64 assembly, Linux syscalls, and System V AMD64 ABI. All claimed exit codes match observed behavior. All placeholder drills are appropriately labeled. The two fixes (L12 listing) ensure learners can copy-paste and run all code examples.
