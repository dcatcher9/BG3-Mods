---
name: mod-check
description: Full audit of a BG3 mod — bugs, logic errors, redundancy, typos, syntax errors, consistency, and simplification opportunities.
---

# Mod Check

Perform a thorough audit of the specified mod (or the mod in the current context).
If no mod is specified, ask the user which one to check.

## Step 1 — Discover files

Glob all files under the mod folder, excluding binary assets (`.DDS`, `.png`, `.dat`, `.osi`, `.pak`).

Group files by type:
- **LSX** — `.lsx` files under `Public/`
- **Stats** — `.txt` files under `Stats/Generated/`
- **Lua** — `.lua` files under `ScriptExtender/Lua/`
- **Localization** — `.xml` files under `Localization/`
- **Config** — `ScriptExtender/Config.json`
- **Story/Osiris** — `Story/RawFiles/Goals/*.txt`, `story_header.div`

## Step 2 — Read and audit each group

Read every file in each group and apply the checks below.
Work through all groups before writing the report.

### LSX files (Progressions, Feats, SpellLists, Races, etc.)

- **XML syntax**: unclosed tags, mismatched attribute quotes, malformed UUIDs (`xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` format), unmatched brackets/quotes (e.g. `(` without `)`, `[` without `]`, `"` without closing `"`)
- **Duplicate entries**: same `UUID` or `id` attribute appearing more than once in the same file
- **Broken cross-references**: a UUID referenced in one file (e.g. a SpellList UUID in Progressions) that does not exist in the file that should define it
- **Consistency**: attribute naming style matches the file's own conventions; all entries in a list use the same set of attributes
- **Redundancy**: entries that are identical or near-identical to another entry in the same file; attributes set to their default value when the default is implicit

### Stats `.txt` files

- **Syntax**: `new entry` / `type` / `data` / `using` structure is valid; no missing quotes, stray characters, or unmatched brackets/parentheses/quotes
- **Broken `using` references**: the parent stat name must exist somewhere in the same or a vanilla base stat
- **Duplicate stat names**: same `new entry` name defined more than once
- **Logic errors**: a stat that contradicts its declared type (e.g. a Spell with no `SpellType`, a Status with no `StatusType`)
- **Redundancy**: `data` fields that repeat the inherited value from `using` without change
- **Simpler alternatives**: long chains of `using` that could be flattened, or separate entries that are identical except for one field and could share a base

### Lua files

- **Syntax**: parse errors, unclosed `do/end`, `if/end`, `function/end` blocks, unmatched `(`, `[`, `{`, `"`, `'`
- **Logic errors**: conditions that are always true/false, unreachable code, missing `nil` checks before indexing
- **API misuse**: calls to `Ext` APIs that don't exist or have wrong argument counts (check against `bg3se/Docs/API.md`)
- **Redundancy**: functions or variables defined but never used; identical logic repeated across files
- **Simpler solutions**: Lua doing something that could be handled purely with stat data; manual loops where `Ext` utilities exist

### Localization XML

- **Syntax**: well-formed XML, no unclosed tags, no unmatched brackets/quotes in attribute values or text content
- **Duplicate `contentuid`** values
- **Typos in English strings**: obvious spelling mistakes (non-English strings are out of scope — do not flag them)
- **Orphaned entries**: a `contentuid` that appears in the localization file but is not referenced by any `.lsx` or `.txt` file in the mod

### Config.json

- **Valid JSON syntax**
- **ModuleUUID** matches the folder UUID used across `Public/` and `Mods/`

## Step 3 — Write the report

Output a structured report grouped by severity:

```
## 🔴 Bugs / Errors
Issues that will cause crashes, missing features, or incorrect behaviour at runtime.
List each with: file path, line or entry name, description, suggested fix.

## 🟡 Logic / Consistency Issues
Things that work but are wrong by design intent or inconsistent with the rest of the mod.

## 🟠 Redundancy
Duplicate entries, dead code, or values that repeat a default.

## 🔵 Simplification Opportunities
Places where a simpler approach exists (flatten stat chain, remove Lua in favour of data, etc.).

## ⚪ Typos / Minor
Spelling mistakes in English strings, minor naming inconsistencies.

## ✅ Summary
X files checked. N issues found (R red, Y yellow, O orange, B blue, W white).
```

If a group has no issues, write `— none found` for that section.
Do not invent issues. Only report what you can directly observe in the file contents.
