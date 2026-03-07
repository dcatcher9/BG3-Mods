---
name: mod-check
description: Full audit of a BG3 mod — bugs, logic errors, redundancy, typos, syntax errors, consistency, simplification opportunities, and feature completeness. Use this skill whenever the user asks to check, audit, review, or validate a BG3 mod, or wants to know what's broken, missing, or incomplete in a mod.
---

# Mod Check

Perform a thorough audit of the specified mod (or the mod in the current context).
If no mod is specified, ask the user which one to check.

**Important:** Read every file completely before writing any part of the report. Do not stop early or skip files because the mod is large. Thoroughness is the point — missing an issue now means it surfaces later.

## Step 1 — Discover and inventory files

Glob all files under the mod folder, excluding binary assets (`.DDS`, `.png`, `.dat`, `.osi`, `.pak`).

Group files by type:
- **LSX** — `.lsx` files under `Public/`
- **Stats** — `.txt` files under `Stats/Generated/`
- **Lua** — `.lua` files under `ScriptExtender/Lua/`
- **KHN** — `.khn` files anywhere under `Scripts/` (thoth condition scripts, Lua syntax)
- **Localization** — `.xml` files under `Localization/`
- **Config** — `ScriptExtender/Config.json`
- **Story/Osiris** — `Story/RawFiles/Goals/*.txt`, `story_header.div`

At the end of the report, include a **Coverage Checklist** listing every file you read with a checkmark. This makes it easy to spot what was missed if the report is run again.

## Step 2 — Read and audit each group

Read every file in each group and apply the checks below.
Work through all groups before writing the report.

### LSX files (Progressions, Feats, SpellLists, Races, CharacterCreation, etc.)

- **XML syntax**: unclosed tags, mismatched attribute quotes, malformed UUIDs (`xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` format), unmatched brackets/quotes
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

### Lua files (`.lua`)

- **Syntax**: parse errors, unclosed `do/end`, `if/end`, `function/end` blocks, unmatched `(`, `[`, `{`, `"`, `'`
- **Logic errors**: conditions that are always true/false, unreachable code, missing `nil` checks before indexing
- **API misuse**: calls to `Ext` APIs that don't exist or have wrong argument counts (check against `bg3se/Docs/API.md`)
- **Redundancy**: functions or variables defined but never used; identical logic repeated across files
- **Simpler solutions**: Lua doing something that could be handled purely with stat data; manual loops where `Ext` utilities exist

### KHN files (`.khn`) — thoth condition scripts

These files use Lua syntax but are condition scripts evaluated by the thoth framework. Every public function must return either a `ConditionResult(...)` call or a condition chain built from `ConditionResult`, `HasStatus`, `HasPassive`, etc. using the `|`, `&`, `~` operators.

Check for:

- **Return type correctness**: every public function must return a value compatible with `ConditionResult`. A function that returns a plain Lua boolean, `nil`, or a number is a bug — it will silently fail at runtime.
- **`context` nil safety**: `context.Source` and `context.Target` can be nil or invalid. Before indexing properties like `.Level`, `.HP`, `.Wisdom`, check `entity.IsValid` or guard with `if not context.Target or not context.Target.IsValid then`. Flag any function that indexes `context.Target` without such a guard.
- **Operator misuse**: `~`, `|`, `&` are bg3se operator overloads on `ConditionResult` objects, not Lua bitwise/boolean operators. Using them on plain Lua booleans or numbers is a bug. Flag any case where these operators are applied to non-`ConditionResult` values.
- **Variable shadowing**: the pattern `local entity = entity or context.Source` inside a function that already has an `entity` parameter is intentional and valid — do not flag it. But flag cases where a local shadows a meaningful outer variable in a confusing way.
- **Unused functions**: public functions defined but never referenced in any Stats `.txt` file (as a condition string) or other `.khn` file are dead code.
- **Broken status/passive references**: status names like `'BANXIAN_DH_YEAR'` or passive names like `'CuiTi_ZhouTian_1'` used in `HasStatus`/`HasPassive` calls should exist somewhere in the Stats files. Flag any that appear to be dangling references.
- **Logic errors**: threshold comparisons using wrong operators (e.g. `>` vs `>=` when the design comment says "达到阈值"), always-true/false conditions, unreachable branches.

### Localization XML

- **Syntax**: well-formed XML, no unclosed tags, no unmatched brackets/quotes in attribute values or text content
- **Duplicate `contentuid`** values
- **Typos in English strings**: obvious spelling mistakes (non-English strings are out of scope — do not flag them)
- **Orphaned entries**: a `contentuid` that appears in the localization file but is not referenced by any `.lsx` or `.txt` file in the mod

### Config.json

- **Valid JSON syntax**
- **ModuleUUID** matches the folder UUID used across `Public/` and `Mods/`

## Step 3 — Feature Completeness Audit

This step answers: *what does the mod promise, and can the player actually access it?*

### 3a — Identify declared features

Collect all features the mod declares by reading:
- **CharacterCreation LSX files** — subraces and their names (e.g. RenXian, TianXian, YaoXian) and the traits/abilities listed for each
- **Progressions LSX** — every passive, spell, action resource, and ability granted at each level; the ProgressionDescriptions for human-readable names
- **ActionResourceDefinitions** — custom resources (e.g. ShenshiPoint, KiPoint variants) and their max values
- **Stats Data files** — top-level systems implied by naming conventions (e.g. a cluster of `BANXIAN_LG_*` statuses implies a LingGen system; `BANXIAN_DH_*` implies a DaoXin/Realm system; `CUITI_ZHOUTIAN_*` implies a ZhouTian cultivation system)
- **Localization / Hints** — human-facing feature names and descriptions that promise specific gameplay behavior

Group related entries into named **feature systems** (e.g. "LingGen elemental root system", "ZhouTian circulation system", "Shenshi mind-control system", "DaoXin heart stability system", "Realm marks (DH marks) system").

### 3b — Assess each feature

For each identified feature or feature system, determine:

**Implementation status:**
- **Fully implemented** — the stat/passive/spell exists, supporting conditions (`.khn`) exist and are consistent, and any Lua logic that drives it exists and appears correct
- **Partially implemented** — some parts exist but others are missing (e.g. a passive is defined but the condition it references doesn't exist, or a system has stacks defined but no trigger to grant them)
- **Not implemented** — declared in CharacterCreation or Progressions but no backing stat, passive, or Lua logic found

**Player accessibility:**
- **Character Creation** — player can select it during character creation (present in CharacterCreation LSX and linked to a valid subrace/preset)
- **Progression** — player gains it automatically on level up (present in a Progressions entry with correct class/subclass tag)
- **Spell/Ability** — player can use it directly from the action bar (it's a Spell or SpellList entry granted via progression)
- **Passive/Aura only** — the feature activates automatically; no direct player action needed (fine, but note if the player has no way to see or understand it)
- **Script-only** — only triggered by Lua events, never exposed in any UI or progression entry (flag if this seems unintentional)
- **Inaccessible** — defined in stats but not granted by any progression, CharacterCreation, or spell list; the player can never reach it through normal gameplay

### 3c — Feature completeness table

Output a table at the top of the Feature Completeness section:

```
| Feature / System         | Status       | Player Access         | Notes |
|--------------------------|-------------|----------------------|-------|
| LingGen elemental roots  | Partial      | Passive/Aura         | Stacks defined, threshold triggers present, but no progression entry grants initial LingGen setup |
| ZhouTian circulation     | Full         | Passive/Aura + Spell | ...   |
| ...                      | ...          | ...                  | ...   |
```

Then after the table, for each **Partial** or **Not Implemented** entry, give a short paragraph explaining specifically what is missing and what would be needed to complete it.

## Step 4 — Write the bug/issue report

Output a structured report grouped by severity:

```
## Feature Completeness
(table and gap descriptions from Step 3)

## Bugs / Errors
Issues that will cause crashes, missing features, or incorrect behaviour at runtime.
List each with: file path, line or entry name, description, suggested fix.

## Logic / Consistency Issues
Things that work but are wrong by design intent or inconsistent with the rest of the mod.

## Redundancy
Duplicate entries, dead code, or values that repeat a default.

## Simplification Opportunities
Places where a simpler approach exists (flatten stat chain, remove Lua in favour of data, etc.).

## Typos / Minor
Spelling mistakes in English strings, minor naming inconsistencies.

## Summary
X files checked. N issues found (R red, Y yellow, O orange, B blue, W white).
Feature completeness: F fully implemented, P partial, N not implemented.

## Coverage Checklist
- [x] Public/XSS_BANXIAN/CharacterCreation/RENXIAN.lsx
- [x] Public/XSS_BANXIAN/Stats/Generated/Data/Data.txt
- [x] Scripts/thoth/helpers/XSS_BANXIAN.khn
- ... (every file read)
```

If a group has no issues, write `— none found` for that section.
Do not invent issues. Only report what you can directly observe in the file contents.
