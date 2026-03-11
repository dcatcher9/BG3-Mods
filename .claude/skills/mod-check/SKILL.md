---
name: mod-check
description: Full audit of a BG3 mod — bugs, logic errors, redundancy, typos, syntax errors, consistency, simplification opportunities, and feature completeness. Use this skill whenever the user asks to check, audit, review, or validate a BG3 mod, or wants to know what's broken, missing, or incomplete in a mod. Also use it when the user asks to continue, resume, or update a previous mod check.
---

# Mod Check

Audits a BG3 mod and maintains a persistent `MOD_CHECK.md` summary in the mod's root folder. Each run builds on the previous one — findings accumulate, coverage grows, and already-fixed issues are tracked.

If no mod is specified, ask the user which one to check.

---

## Step 0 — Load existing state

Before doing anything else, look for `MOD_CHECK.md` in the mod's root folder.

- **If it exists**: read it. Note which files are already fully read, which are partial, and which issues are open vs. fixed. Focus this run on files not yet fully covered and on verifying previously flagged issues.
- **If it doesn't exist**: start fresh. The file will be created at the end of the run.

This means each run is incremental. You don't need to re-read files that are already fully checked unless there's a reason (e.g., the user says they've made changes).

---

## Step 1 — Discover and inventory files

Glob all files under the mod folder. Exclude binary assets (`.DDS`, `.png`, `.dat`, `.osi`, `.pak`).

Use **separate Globs for each source tree** — a single recursive Glob often misses nested directories:
- `Public/<ModFolder>/**/*.lsx` and `Public/<ModFolder>/**/*.txt`
- `Mods/<ModFolder>/ScriptExtender/Lua/**/*.lua`
- `Scripts/**/*.khn`
- `Localization/**/*.xml`
- `Mods/<ModFolder>/ScriptExtender/Config.json`
- `Story/RawFiles/Goals/*.txt`

Group the discovered files by type:
- **LSX** — `.lsx` under `Public/`
- **Stats** — `.txt` under `Stats/Generated/`
- **Lua** — `.lua` under `ScriptExtender/Lua/`
- **KHN** — `.khn` under `Scripts/` (thoth condition scripts — Lua syntax)
- **Localization** — `.xml` under `Localization/`
- **Config** — `ScriptExtender/Config.json`
- **Story/Osiris** — `Story/RawFiles/Goals/*.txt`, `story_header.div`

Cross-reference against the coverage list in `MOD_CHECK.md` (if it exists) to identify which files still need reading.

**In a single run, aim to fully audit 10–20 files.** Prioritize: (1) files not yet read at all, (2) files with only partial coverage, (3) recently changed files if the user mentions changes. Explicitly note in the report what you deferred and why.

---

## Step 2 — Read and audit each file group

Read files in parallel where possible. Apply the checks below.

### Handling large files

When a file is too large to read completely in one call:
- Use **Grep** first to locate specific entries, then read only the relevant sections with `offset`/`limit`.
- Document it as **partial** in the coverage list with the line range read.
- Use targeted Grep patterns to check for known issues even in unread sections (e.g., grep for `using` references to verify the parent exists).
- Never silently skip a large file — always note it in the coverage list with its size and what you were able to check.

### Verify before reporting

Before adding a cross-reference bug or duplicate to the issue list, **confirm it with a search**. A missing UUID reference or duplicate stat name must be verified by actually searching both files involved. Unverified suspicions lead to false positives.

---

### LSX files (Progressions, Feats, SpellLists, Races, CharacterCreation, etc.)

- **XML syntax**: unclosed tags, mismatched attribute quotes, malformed UUIDs (`xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`), unmatched brackets/quotes
- **Duplicate entries**: same `UUID` or `id` attribute more than once in the same file — verify with Grep before reporting
- **Broken cross-references**: a UUID in one file that should be defined in another — verify by searching the target file
- **Consistency**: attribute naming style and attribute set matches the file's conventions
- **Redundancy**: attributes set to their implicit default value

### Stats `.txt` files

- **Syntax**: `new entry` / `type` / `data` / `using` structure; no unmatched brackets/quotes
- **Broken `using` references**: parent stat must exist in the same file or a vanilla stat — verify with Grep
- **Duplicate stat names**: same `new entry` name more than once — verify with Grep
- **Logic errors**: stat contradicts its declared type (e.g. Spell with no `SpellType`)
- **Redundancy**: `data` fields that repeat the inherited value unchanged
- **LevelMapValue usage**: `LevelMapValue(Name)` wrapper required when referencing a level map in a Boost — raw name used as a number is a bug
- **Field length**: `StatsFunctors`/`ToggleOnFunctors` fields approaching ~4000 chars risk a loading hang at 55%; flag if close

### Lua files (`.lua`)

- **Syntax**: unclosed `do/end`, `if/end`, `function/end`, unmatched `(`, `[`, `{`
- **Logic errors**: always-true/false conditions, missing nil checks before indexing
- **Type errors**: passing floats where integers are required (e.g. `math.random` in Lua 5.3+)
- **API misuse**: wrong argument counts or nonexistent `Ext` API calls
- **Redundancy**: functions or variables defined but never used
- **Hardcoded values**: UUIDs or magic numbers that should be named constants

### KHN files (`.khn`) — thoth condition scripts

These use Lua syntax but every public function must return a `ConditionResult` or a chain using `|`, `&`, `~`.

- **Return type**: a function returning a plain boolean, nil, or number is a silent runtime bug
- **Nil safety**: `context.Source`/`context.Target` can be nil — index their properties only after a validity guard
- **Operator misuse**: `~`, `|`, `&` are overloads on `ConditionResult` — using them on plain booleans/numbers is a bug
- **Broken references**: status/passive names in `HasStatus`/`HasPassive` calls must exist in Stats files — spot-check with Grep
- **Logic errors**: threshold comparisons (`>` vs `>=`), always-true/false conditions
- **Unused functions**: public functions never referenced in any Stats `.txt` or `.khn` file

### Localization XML

- **Syntax**: well-formed XML
- **Duplicate `contentuid`** values
- **Typos** in English strings (non-English strings are out of scope)
- **Orphaned entries**: `contentuid` not referenced by any `.lsx` or `.txt`

### Config.json

- **Valid JSON syntax**
- **ModuleUUID** matches the folder UUID used in `Public/` and `Mods/`

---

## Step 3 — Feature Completeness Audit

*What does the mod promise, and can the player actually access it?*

### 3a — Identify feature systems

Collect features from: CharacterCreation LSX, Progressions LSX, ActionResourceDefinitions, Stats file naming patterns, Localization/Hints.

Group related entries into named **feature systems** based on naming conventions (e.g. a cluster of `MOD_SYSTEM_*` statuses implies a system called "System").

### 3b — Assess each system

**Implementation status:**
- **Full** — stat/passive/spell, conditions, and Lua logic all exist and are consistent
- **Partial** — some pieces exist, others are missing or commented out
- **Not implemented** — declared in CharacterCreation/Progressions but no backing stat or logic found

**Player accessibility:**
- **Character Creation / Progression / Spell / Passive-only / Script-only / Inaccessible**

### 3c — Feature completeness table

```
| Feature / System | Status  | Player Access    | Notes |
|------------------|---------|------------------|-------|
| Example system   | Partial | Passive/Aura     | Stacks defined but no trigger to grant them |
```

For each Partial or Not Implemented entry, add a short paragraph explaining what's missing and what would complete it.

---

## Step 4 — Write the report

Produce a structured report with these sections. If a section has no findings, write `— none found`.

```
## Feature Completeness
(table + gap paragraphs)

## Bugs / Errors
Crashes, broken features, incorrect runtime behavior.
Each entry: file path (relative), entry name or line, description, suggested fix.

## Logic / Consistency Issues
Works but is wrong by design intent or inconsistent with the rest of the mod.

## Redundancy
Duplicates, dead code, values that repeat an inherited default.

## Simplification Opportunities
Simpler approaches: flatten stat chain, replace Lua with stat data, etc.

## Typos / Minor
English spelling mistakes, naming inconsistencies.

## Summary
X files checked this run (Y total across all runs). N new issues found.
Severity: R red, O orange, Y yellow, B blue, W white.
Feature completeness: F full, P partial, N not implemented.

## Coverage (this run)
Files newly fully read, newly partially read, and deferred (with reason).
```

---

## Step 5 — Update MOD_CHECK.md

After writing the report, update `MOD_CHECK.md` in the mod's root folder. This file is the persistent record across all runs.

**Format:**

```markdown
# Mod Check — <Mod Display Name>
<!-- Mod path: relative/path/to/mod/root -->
<!-- Last updated: YYYY-MM-DD -->

## Status
- **Coverage:** X of N files fully read, Y partially read, Z not yet read
- **Open issues:** N (R red, O orange, Y yellow, B blue, W white)
- **Fixed issues:** M

## Open Issues

### 🔴 Bugs / Errors
- [ ] **B-01** `Public/Mod/Stats/file.txt` `EntryName` — Description. *Fix: suggested fix.*
- [ ] **B-02** `Mods/Mod/Lua/file.lua:225` — Description. *Fix: suggested fix.*

### 🟠 Wrong Behavior
- [ ] **WB-01** ...

### 🟡 Logic / Consistency
- [ ] **L-01** ...

### 🔵 Redundancy
- [ ] **R-01** ...

### ⚪ Minor / Typos
- [ ] **T-01** ...

## Fixed / Resolved Issues
- [x] **B-01** `file.lua:225` — Short description. *(fixed YYYY-MM-DD)*
- [~] **L-02** `file.khn` — Description. *(won't fix — intentional by design)*

## Feature Completeness
| Feature / System | Status  | Player Access | Notes |
|------------------|---------|---------------|-------|
| Example system   | Partial | Passive/Aura  | ...   |

## Coverage
### Fully read
- `Public/Mod/Stats/Generated/Data/file.txt`

### Partially read
- `Public/Mod/Stats/Generated/Data/largefile.txt` (lines 1–400; ~2000 total)

### Not yet read
- `Public/Mod/CharacterCreation/RACES.lsx` (450 KB — too large; use Grep for targeted checks)
- `Public/Mod/Stats/Generated/Data/BIGFILE.txt` (deferred — not a priority for this pass)
```

**Merge rules when updating:**
- Preserve all existing open issues unless the user explicitly marked them fixed
- Issues the user has checked off (`[x]`) move to the Fixed section
- Add new issues from this run with the next available ID in each category
- Update the Coverage section — promote partial→full if fully read this run, add newly discovered files
- Update the Status line counts
- Do not remove deferred files from the "Not yet read" list just because you didn't read them this run — they stay until actually read

---

## Step 6 — Offer to fix (optional)

After presenting the report and updating `MOD_CHECK.md`, ask:

> "Would you like me to fix the red/orange issues now, or any specific ones?"

If yes, apply fixes to the source files, then update `MOD_CHECK.md` — move fixed issues to the Fixed section with today's date.
