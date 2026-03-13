---
name: mod-check
description: Full audit of a BG3 mod — bugs, logic errors, redundancy, typos, syntax errors, consistency, simplification opportunities, balance issues, and feature implementation review. Use this skill whenever the user asks to check, audit, review, or validate a BG3 mod, or wants to know what's broken, missing, or incomplete in a mod. Also use it when the user asks to continue, resume, or update a previous mod check.
---

# Mod Check

Audits a BG3 mod and maintains persistent **memory files** in `<mod-root>/.mod-check/` so each run builds on accumulated knowledge rather than starting from scratch.

If no mod is specified, ask the user which one to check.

---

## Memory System

All persistent state lives in `<mod-root>/.mod-check/`. Each file covers a different aspect of the mod and updates at its own pace.

| File | What it stores | When to update |
|---|---|---|
| `architecture.md` | File inventory, mod structure, folder purposes, naming conventions | When new files appear or structure changes |
| `features.md` | How each feature/system is implemented — files involved, stats, Lua functions, data flow, player access path. Completeness noted as a field per feature | When features are added, changed, or newly understood |
| `balance.md` | Overpowered / underwhelming features, scaling issues, missing counterplay, risk of degenerate combos | When balance-relevant findings emerge |
| `patterns.md` | Coding patterns, design decisions, "by design" quirks that should not be re-flagged | When new intentional patterns are confirmed |
| `coverage.md` | Which files have been fully/partially read, line counts, what was checked per file | Every run |
| `open-issues.md` | Currently open issues — no fixed-issue history | Every run |
| `audit-log.md` | One-line-per-run log: date, files checked, issues found/fixed count | Append each run |

### Memory lifecycle within a conversation

1. **On skill start** — read all memory files to load prior knowledge
2. **Before context compaction** — flush any in-progress findings to the memory files so nothing is lost when earlier messages are compressed
3. **After context compaction** — re-read all memory files to restore working knowledge
4. **On run completion** — final update to all memory files that changed this run

### Principles

- **No fixed-issue bloat.** Once an issue is fixed, remove it from `open-issues.md`. The fix lives in git history. If a "by design" decision is confirmed, move it to `patterns.md` instead.
- **Architecture is durable.** File inventory and mod structure rarely change — don't re-discover what's already recorded.
- **Features describe implementation, not just status.** For each feature system, record which files implement it, how the parts connect (stat → passive → Lua handler → status), and how the player accesses it. Completeness is a byproduct of understanding the implementation.
- **Balance is separate from correctness.** A feature can be bug-free but overpowered. Track these in `balance.md`, not as issues.

---

## Step 0 — Load memory

Read all files in `<mod-root>/.mod-check/` if the folder exists.

- **If memory exists**: note what's already known — architecture, coverage, open issues, patterns. Focus this run on uncovered files, recently changed files, and verifying open issues.
- **If no memory exists**: start fresh. The folder and files will be created at the end.

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

Group by type:
- **LSX** — `.lsx` under `Public/`
- **Stats** — `.txt` under `Stats/Generated/`
- **Lua** — `.lua` under `ScriptExtender/Lua/`
- **KHN** — `.khn` under `Scripts/` (thoth condition scripts — Lua syntax)
- **Localization** — `.xml` under `Localization/`
- **Config** — `ScriptExtender/Config.json`
- **Story/Osiris** — `Story/RawFiles/Goals/*.txt`, `story_header.div`

Cross-reference against `coverage.md` to identify what still needs reading.

Compare against `architecture.md` — if new files appeared, note them.

**In a single run, aim to fully audit 10–20 files.** Prioritize: (1) files not yet read, (2) files with partial coverage, (3) recently changed files. Explicitly note deferrals in the report.

---

## Step 2 — Read and audit each file group

Read files in parallel where possible. Apply the checks below.

### Handling large files

When a file is too large to read completely in one call:
- Use **Grep** first to locate specific entries, then read relevant sections with `offset`/`limit`.
- Document as **partial** in `coverage.md` with line range read.
- Use targeted Grep patterns to check for known issues even in unread sections.
- Never silently skip a large file — always note it with size and what you checked.

### Verify before reporting

Before adding a cross-reference bug or duplicate to the issue list, **confirm it with a search**. Unverified suspicions lead to false positives.

---

### LSX files (Progressions, Feats, SpellLists, Races, CharacterCreation, etc.)

- **XML syntax**: unclosed tags, mismatched attribute quotes, malformed UUIDs
- **Duplicate entries**: same UUID or id attribute more than once — verify with Grep
- **Broken cross-references**: UUID in one file not defined in target file — verify by searching
- **Consistency**: attribute naming style matches file conventions
- **Redundancy**: attributes set to their implicit default value

### Stats `.txt` files

- **Syntax**: `new entry` / `type` / `data` / `using` structure; no unmatched brackets/quotes
- **Broken `using` references**: parent stat must exist — verify with Grep
- **Duplicate stat names**: same `new entry` name more than once — verify with Grep
- **Logic errors**: stat contradicts its declared type (e.g. Spell with no `SpellType`)
- **Redundancy**: `data` fields repeating inherited value unchanged
- **LevelMapValue usage**: `LevelMapValue(Name)` wrapper required in Boosts — raw name is a bug
- **Field length**: `StatsFunctors`/`ToggleOnFunctors` approaching ~4000 chars risks loading hang at 55%

### Lua files (`.lua`)

- **Syntax**: unclosed `do/end`, `if/end`, `function/end`, unmatched brackets
- **Nil safety**: missing nil checks on `Ext.Entity.Get`, `Ext.Stats.Get`, `GetStatusTurns`, `Osi.GetStatString` results before indexing
- **Logic errors**: always-true/false conditions, unreachable code
- **Type errors**: floats where integers required (e.g. `math.random` in Lua 5.3+)
- **API misuse**: wrong argument counts, nonexistent `Ext` API calls
- **Race conditions**: modifying tables during `pairs()` iteration
- **Redundancy**: unused functions/variables, dead code

### KHN files (`.khn`) — thoth condition scripts

Lua syntax, but every public function must return `ConditionResult` or chain with `|`, `&`, `~`.

- **Return type**: returning plain boolean/nil/number is a silent runtime bug
- **Nil safety**: `context.Source`/`context.Target` can be nil — guard before indexing
- **Operator misuse**: `~`, `|`, `&` on plain booleans/numbers instead of `ConditionResult`
- **Broken references**: status/passive names in `HasStatus`/`HasPassive` must exist in Stats — spot-check
- **Logic errors**: threshold comparisons, always-true/false conditions
- **Unused functions**: public functions never referenced in any `.txt` or `.khn`

### Localization XML

- **Syntax**: well-formed XML
- **Duplicate `contentuid`** values
- **Typos** in display strings (repeated characters, wrong characters)
- **Orphaned entries**: `contentuid` not referenced by any `.lsx` or `.txt`

### Config.json

- **Valid JSON syntax**
- **ModuleUUID** matches the folder UUID in `Public/` and `Mods/`

---

## Step 3 — Feature Implementation Review

The goal is to understand and document *how* each feature works, not just whether it's "complete."

### 3a — Identify feature systems

Collect features from: CharacterCreation LSX, Progressions LSX, ActionResourceDefinitions, Stats file naming patterns, Localization/Hints, Lua module structure.

Group related entries into named **feature systems** based on naming conventions.

### 3b — Document each system's implementation

For each feature system, record in `features.md`:
- **What it does** (one sentence)
- **Implementation chain**: which files implement it and how they connect (e.g. `PassiveData in DADAO.txt → triggers SIGNAL status → DaoHeng.lua handler → applies boost status`)
- **Player access**: how the player encounters it (Character Creation / Progression / Spell / Passive / Script-only / Inaccessible)
- **Completeness**: Full / Partial / Stub — with brief note on what's missing if not Full

### 3c — Feature table

```
| Feature / System | Completeness | Player Access | Implementation Chain (key files) |
|---|---|---|---|
| Example system | Full | Passive/Aura | DADAO.txt → DaoHeng.lua → status boosts |
```

---

## Step 4 — Balance Review

Separate from correctness. A feature can be perfectly implemented but problematically tuned.

Flag in `balance.md`:

### Overpowered indicators
- Damage/healing that scales without meaningful cap
- Stacking mechanics that grow exponentially
- Abilities that bypass core game constraints (action economy, concentration, etc.) without trade-off
- "Win button" combinations — feature combos that trivialize content

### Underwhelming indicators
- Features with high investment cost but marginal benefit
- Abilities obsoleted by lower-level features in the same mod
- Scaling that falls off dramatically at higher levels
- Features that sound impactful in description but have negligible mechanical effect

### Format
```
| Feature | Rating | Concern | Details |
|---|---|---|---|
| ExtraAttack 连击 | ⚠️ Strong | Up to 10 attacks/turn | No resource cost; linear scaling with realm |
```

Only flag clear outliers — don't nitpick reasonable design choices. Note the reasoning so the mod author can make an informed decision.

---

## Step 5 — Write the report

Produce a structured report for the user. If a section has no findings, write `— none found`.

```
## Summary
X files checked this run. N new issues found (R red, O orange, Y yellow, B blue, W white).
New features documented: ...
Balance notes: ...

## Bugs / Errors
Each: file path, entry/line, description, suggested fix.

## Logic / Consistency Issues

## Redundancy

## Balance Concerns (new this run)

## Typos / Minor

## Coverage (this run)
Files newly read, partially read, and deferred.
```

---

## Step 6 — Update memory files

After writing the report, update all changed memory files in `<mod-root>/.mod-check/`.

### `architecture.md`
```markdown
# Architecture — <Mod Display Name>
<!-- Last updated: YYYY-MM-DD -->

## Mod Identity
- **Mod folder**: XSS_BANXIAN
- **ModuleUUID**: ...
- **Display name**: ...

## File Tree
(grouped by type, with line counts for large files and brief purpose notes)

## Naming Conventions
(prefix patterns, stat naming rules, etc.)
```

### `features.md`
```markdown
# Features — <Mod Display Name>
<!-- Last updated: YYYY-MM-DD -->

## Feature Table
| Feature / System | Completeness | Player Access | Key Files |
|---|---|---|---|

## Feature Details

### <Feature Name>
**What**: one-sentence description
**Chain**: StatFile entry → Passive/Spell → Lua handler → Status/Effect
**Access**: how the player gets it
**Completeness**: Full / Partial / Stub
**Notes**: implementation details, quirks, dependencies
```

### `balance.md`
```markdown
# Balance — <Mod Display Name>
<!-- Last updated: YYYY-MM-DD -->

| Feature | Rating | Concern | Details |
|---|---|---|---|

## Detailed Notes
(paragraphs expanding on flagged items)
```

### `patterns.md`
```markdown
# Patterns & Design Decisions — <Mod Display Name>
<!-- Last updated: YYYY-MM-DD -->

## Coding Patterns
(e.g. "All GetStatusTurns calls use `or 0` fallback", "PersistentVars keyed by UUID")

## Intentional Design (do not re-flag)
- **<Pattern>**: Description. Why it's intentional.
```

### `coverage.md`
```markdown
# Coverage — <Mod Display Name>
<!-- Last updated: YYYY-MM-DD -->

## Stats
- Fully read: X of N
- Partially read: Y
- Not yet read: Z

### Fully read
- `path/to/file.txt`

### Partially read
- `path/to/large.lsx` (lines 1-400 of ~2000; UUID cross-refs verified)

### Not yet read
- `path/to/file.lsx` (59784 lines — visual presets; low priority)
```

### `open-issues.md`
```markdown
# Open Issues — <Mod Display Name>
<!-- Last updated: YYYY-MM-DD -->
<!-- Count: N open (R red, O orange, Y yellow, B blue, W white) -->

### 🔴 Bugs / Errors
- **B-01** `file.lua:225` — Description. *Fix: suggested fix.*

### 🟠 Wrong Behavior
### 🟡 Logic / Consistency
### 🔵 Redundancy
### ⚪ Minor / Typos
```

When an issue is fixed, simply **delete it** from `open-issues.md`. No "Fixed" section — git history is the record. When an issue turns out to be "by design," move the insight to `patterns.md` and delete from `open-issues.md`.

### `audit-log.md`
```markdown
# Audit Log — <Mod Display Name>

| Date | Files Checked | Issues Found | Issues Fixed | Notes |
|---|---|---|---|---|
| 2026-03-12 | 19 (re-audit) | 12 | 12 | Post-commit re-audit; all nil-safety |
```

---

## Step 7 — Offer to fix (optional)

After presenting the report, ask:

> "Would you like me to fix the red/orange issues now, or any specific ones?"

If yes, apply fixes, then remove the fixed issues from `open-issues.md`.
