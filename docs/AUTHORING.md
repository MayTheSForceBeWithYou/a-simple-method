# Authoring Guide — x86-64 NASM Assembly Course

**Audience:** anyone writing or revising LESSON.md files in this repository.  
**Basis:** Otto Didact content authoring guide, bridge-the-C-asm lessons, and RPG course audit findings.

---

## 1. Required LESSON.md structure

Each LESSON.md must follow this template:

```markdown
# Lesson NN — Title

## What this lesson asks of you

2–4 sentences stating what the reader will be able to do after completing this lesson
and why it matters. This is NOT a restatement of the title or a summary of sections.
State what changes in the reader's thinking.

## [Named foundation sections — as many as needed]

Foundation sections teach the core concepts, mechanisms, and vocabulary.

## Worked example

At least one complete worked example showing the reasoning process, including
at least one plausible wrong reading and why it is rejected.

## Distinctions worth keeping straight

Common confusions this lesson addresses (register sizes, addressing modes,
flag behaviors, syscall conventions, ABI details). Two-column table:
the confusion | what actually separates them.

## Check yourself

3–5 free-recall prompts requiring production, not recognition.
These are prose questions, not formatted exercises.
Answerable from the lesson alone.

## Key takeaways

3–6 single-sentence defensible claims. Each should be substantive enough
to be disagreed with. Not a summary of section headings.

## Lookup (optional)

Links to man pages, Intel manual sections, syscall numbers, ABI documents.
Reference material only — the lesson teaches, man pages spell.
```

All sections except "Lookup" are **mandatory**.

---

## 2. Voice and tone

- **Adult, specific readers.** No cheerleading, no filler, no vague hand-waving.
- **Second person, present tense, active voice.** "You load the syscall number into `rax`," not "the syscall number should be loaded."
- **Define every term on first use**, then use it precisely.
- **Never first person about your own workplace** or real organizations.
- **No window dressing.** Cut throat-clearing ("It is important to note that…").
- Clear analogies are welcome when they explain a mechanism, but never as a substitute for the mechanism itself.

---

## 3. Foundations prose rules

### Precision

1. **One term per concept.** Pick the canonical term (register, operand, displacement, syscall number) and use it consistently.
2. **Expand acronyms at first use.** ELF (Executable and Linkable Format), ABI (Application Binary Interface), SIB (Scale-Index-Base).
3. **Contrasts belong in tables.** When comparing 2–3 things along the same dimensions (register sizes, addressing modes, section types), use a table with every cell filled.
4. **Concrete register/flag/memory states over adjectives.** Prefer "`ZF` is set when the result is zero" over "the zero flag indicates a zero-ish result."

### Tool output and artifacts

5. **If you tell the reader to "note" or "find" something, teach the recognition rule.** Name the column, show a real line, say which token is what. Example: "In `objdump -d` output, the first column is the address, the middle columns are instruction bytes in hex, and the rightmost shows the disassembly."
6. **Decode tool output as columns/fields, not as a blob.** When `objdump`, `readelf`, `nm`, or `gdb` prints multiple hex values on one line, explain what each field represents.
7. **Give a navigation move before interpretation.** "Search for `<main>:`", "scroll to the `.data` label", "break on line 42" — anchor the reader before asking them to interpret busy output.
8. **Show the shape of a real line from this toolchain.** Use examples matching GNU `nasm -f elf64` + `ld` on x86-64 Linux. Note when output varies (PIE, addresses) and stress that column *meaning* does not.

### Worked examples and wrong readings

9. **Every worked example must show the reasoning, not just the answer.** Make each inference step visible, including ones an expert would skip.
10. **Include at least one rejected wrong reading.** State the plausible mistake a competent junior would make and explain why it fails. Example: "A common error is to use `mov al, [rsi]` expecting to load 8 bytes — but `al` is an 8-bit register, so only one byte is loaded."
11. **Practice must be portable.** Exercises should work with the tools documented in the lesson (nasm, ld, gdb) without requiring paid products, cloud tenancies, or credentials.

### Code and listings

12. **Fenced code is not narrated** (accessibility constraint). Anything load-bearing must also appear in prose surrounding the code block.
13. **Never dump full man pages.** Quote a flag or struct field only when the lesson needs it. Man pages belong under **Lookup**, not inline.
14. **Do not include line numbers in code content** (they make copy-paste harder). Only use line numbers in references to existing files.

---

## 4. Build commands and flags

### Naming compiler/assembler flags

15. **`-f elf64`, `-g`, `-O0`, `-O2` are build flags**, not source tokens. When prose says "at `-O0`" or "with `-g`", clarify where the flag comes from on first use: "`nasm -f elf64`", "the Makefile's `CFLAGS`", etc.
16. Suggest `make -n` when the reader needs to see the actual command line.

### Rebuild precision

17. **When an edit propagates through the pipeline, state what changes *inside* each artifact**, not just "which files change." After a rebuild, typically all artifacts (`.o`, binary, listings) have new timestamps. The meaningful question is what moved inside: instruction bytes, data section layout, relocations, control flow.

---

## 5. Exercises and practice

18. **Exercises should not ask students to vandalize lasting code to learn something.** If prose instructs "delete this line to see what breaks," reword toward a side experiment or a separate throwaway file.
19. **Do not give solution bodies for student stubs** inside LESSON.md. Worked examples interpret *artifacts* (register contents, flag states, disassembly, tool output), not completed TODO implementations.
20. **Solutions belong in `solutions/` directory**, referenced but not pasted inline.

---

## 6. "Check yourself" prompts

21. **Write prompts that require production, not recognition.** "Name the six argument registers in order" not "Do you understand the argument registers?"
22. **Prompts must be answerable from the lesson alone.** If answering requires external man pages or prior lessons not linked, the prompt is wrong or the lesson has a hole.
23. **3–5 prompts per lesson.** Do not supply answers inline; the lesson itself is the answer.

---

## 7. Key takeaways

24. **3–6 single-sentence defensible claims.** Each should be substantive enough to be wrong. "The stack grows downward on x86-64" is a takeaway. "Stacks are important" is not.
25. **Not a summary of section headings.** Takeaways distill the *insights* the reader should internalize, not the structural outline.

---

## 8. What must never appear

26. **No real organizations, hosts, IP addresses, or people.** Use documentation ranges (RFC 5737: `192.0.2.0/24`, `198.51.100.0/24`, `203.0.113.0/24`) and `example.com` / `example.org`.
27. **No dangling cross-references.** A reference to a file or lesson that does not exist tells the reader something was withheld.
28. **No commentary about the course itself, source notes, or the author's study plan** inside lesson prose.

---

## 9. Technical accuracy constraint

**Do not guess on technical questions.** If you find doubt about:
- Register behavior (which bits are affected, zero-extension vs sign-extension)
- Flag semantics (when CF/OF/ZF/SF are set or cleared)
- Syscall numbers or arguments
- ABI calling convention details
- Instruction encoding or addressing mode validity
- Whether a code listing would actually assemble

**Do NOT silently change it.** Instead, **flag it in `docs/TECH_REVIEW_FLAGS.md`** with:
- Lesson number and file
- Line or section
- Quoted text
- The specific doubt

A separate technical reviewer will verify and resolve these.

---

## 10. Verification build line

To verify a NASM listing in this repository, the standard build is:

```bash
nasm -f elf64 FILE.asm -o /tmp/o.o && ld /tmp/o.o -o /tmp/p
```

Use this to spot-check listings when in doubt, but do not rewrite lesson code on your own authority if behavior is unclear — flag it instead.

---

## 11. Lesson-to-lesson consistency

28. **Keep lesson numbering, filenames, and headings that other files link to.** The `LEARNING_ROADMAP.md` and exercises depend on stable lesson identifiers.
29. **Cross-reference by lesson number** (e.g., "see Lesson 04 for calling conventions"), not by vague "earlier" or "later."

---

## 12. Depth calibration

30. **Depth should match the lesson's role in the course.** Early foundational lessons (00–04) teach mechanisms in detail. Milestone lessons (10, 12, 18) integrate. Advanced lessons (13–17) assume prior foundation and focus on domain-specific techniques.
31. **Prefer concrete examples over abstract descriptions.** "Here is how `lea` computes an address without loading memory" with a three-line example beats a paragraph of prose.

---

## Review checklist (before committing a revised lesson)

- [ ] All mandatory sections present and in template order
- [ ] Advance organizer states what changes in the reader's thinking, not a title restatement
- [ ] At least one worked example with a rejected wrong reading
- [ ] "Check yourself" prompts require production and are answerable from lesson
- [ ] Key takeaways are defensible claims, not heading summaries
- [ ] No first person about real workplaces, no real IPs/orgs
- [ ] Contrasts are tables with filled cells
- [ ] Tool output instructions include recognition rules (columns, search anchors)
- [ ] Code blocks have surrounding prose for accessibility
- [ ] Any technical doubts flagged in `docs/TECH_REVIEW_FLAGS.md`
- [ ] Build commands specify flags explicitly ("`nasm -f elf64`")
- [ ] Cross-references use stable lesson numbers

---

## Sources

- Otto Didact `content-authoring-guide.md` — certification exam prep pedagogy (structure, item writing, worked examples, retrieval)
- Otto Didact `learning-science-onepager.md` — spacing, retrieval, desirable difficulties
- `bridge-AUTHORING.md` — C/asm course rules (precision on artifacts, flag naming, tool output decoding, rejected readings)
- `rpg-INSTRUCTIONAL_AUDIT.md` and style reviews — practice folder doctrine, no production vandalism, adult tone, LESSON depth requirement
