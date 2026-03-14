---
name: bg3-implement
description: Implement new BG3 mod mechanics — stats, passives, statuses, spells, Lua handlers, and localization. Use this skill whenever the user wants to add a new ability, rework a mechanic, create a passive/spell/status, write Lua game logic, or wire up a feature across stat files, Lua scripts, and localization XML. Also use when the user describes a gameplay mechanic they want built, even if they don't use technical terms.
---

# BG3 Implement

Build new game mechanics for BG3 mods. This skill encodes the exact syntax, patterns, and cross-file wiring needed to implement features correctly the first time.

---

## Before you start

1. **Read the mod's existing patterns.** Check a few stat entries, Lua modules, and localization entries in the target mod to match its conventions (naming prefixes, contentuid format, module structure).
2. **Read `learnings.md`** from the `mod-check` skill (`<project>/.claude/skills/mod-check/learnings.md`) if it exists — it contains validated patterns and known pitfalls.
3. **Clarify the mechanic** with the user if anything is ambiguous: trigger conditions, damage types, scaling, duration, stacking behavior, target selection.

---

## File Types and Syntax

### Stats `.txt` — Stat Entries

Location: `Public/<ModFolder>/Stats/Generated/Data/*.txt`

```
new entry "STAT_NAME"
type "DataType"
using "ParentStat"
data "FieldName" "Value"
data "AnotherField" "Value"
```

**Rules:**
- `type` is required: `PassiveData`, `StatusData`, `SpellData`, `Character`, `Weapon`, `Armor`, `Interrupt`, `Object`
- `using` is optional — inherits all fields from parent, override by re-declaring
- `data` fields are key-value pairs, always quoted
- Comments: `//`
- Multi-value fields use `;` separator: `"ActionPoint:1;BonusActionPoint:1"`
- Localization references: `"contentuid;version"` (e.g., `"stringsofmodmadebyxss20250218jj003a01;1"`)

**Common DataTypes:**

| Type | Key Fields |
|------|-----------|
| `PassiveData` | `Properties` (`IsToggled`, `IsHidden`), `StatsFunctors`, `Conditions`, `Boosts`, `ToggleOnFunctors`, `ToggleOffFunctors` |
| `StatusData` | `StatusType` (`BOOST`, `EFFECT`), `OnApplyFunctors`, `OnRemoveFunctors`, `TickFunctors`, `StackId`, `StackType`, `StatusPropertyFlags`, `Duration` |
| `SpellData` | `SpellType` (`Shout`, `Target`, `Zone`, `Projectile`), `SpellProperties`, `TargetConditions`, `SpellRoll`, `SpellSuccess`, `SpellFail` |

**Critical: Field Length Limit**
Each stat data field has a ~4000-5000 character limit. Exceeding it causes the game to hang at ~55% loading with no error message. If a field (especially `StatsFunctors`, `ToggleOnFunctors`, `Conditions`) approaches this limit, split across multiple stat entries with `Conditions` gating.

**Common Functors:**
```
DealDamage(2d6,Fire,Magical)
DealDamage(LevelMapValue(BanXianDice),Psychic)
RegainHitPoints(2d6)
ApplyStatus(STATUS_NAME,duration,turns)
RemoveStatus(SelfOnEquip,STATUS_NAME)
ExecuteWeaponAttack(MainHand)
SavingThrow(Ability.Wisdom,SourceSpellDC())
IF(HasStatus('STATUS_NAME',context.Target)):DealDamage(1d6,Fire)
```

**Common Boosts:**
```
AC(2)
DamageBonus(1d4,Fire)
Ability(Constitution,2)
ActionResource(KiPoint,1,0)
Resistance(Fire,Resistant)
StatusImmunity(SG_Stunned)
HideOverheadUI("0")
TemporaryHitPoints(10)
```

**LevelMapValue:** When using a LevelMapValue name in Boosts, wrap it: `LevelMapValue(Name)`. Raw name silently fails.

### StatusData Patterns

**Mutual exclusion** — shared `StackId` + `StackType "Overwrite"`:
```
new entry "BASE_STATUS"
type "StatusData"
data "StatusType" "BOOST"
data "StackId" "MY_STANCE_GROUP"
data "StackType" "Overwrite"

new entry "STANCE_A"
type "StatusData"
using "BASE_STATUS"
data "DisplayName" "..."
data "Icon" "..."
```

**Permanent status**: `data "Duration" "-1"` — ended by script logic only.

**Tick every turn**: `data "TickFunctors" "DealDamage(1d6,Fire)"` — fires on status holder's turn start.

**Status groups vs status names**: `SG_Stunned` is a group (for `StatusImmunity`). `STUNNED` is the actual applicable status. Never apply `SG_` prefixed names via `Osi.ApplyStatus`.

### Localization XML

Location: `Mods/<ModFolder>/Localization/English/<ModName>.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<contentList date="25/05/2024 12:47">
  <content contentuid="uniqueid" version="1">Display text here</content>
</contentList>
```

**Rules:**
- `contentuid` must be globally unique. Match the mod's existing naming convention.
- `version` is typically `"1"`.
- Stats reference loca as `"contentuid;version"` in `DisplayName`/`Description`.
- Supports LSTag markup: `<LSTag Type="Image" Info="SoftWarning"/>` for icons in text.
- `DescriptionParams` values appear as `[1]`, `[2]`, etc. in the description text.

---

## Lua Patterns

Location: `Mods/<ModFolder>/ScriptExtender/Lua/Server/`

### Module Structure

```lua
local ModuleName = {}

function ModuleName.Init()
    -- Register listeners here
end

function ModuleName.OnStatusApplied_before(status, attacker, target)
    -- Called by EventHandlers
end

return ModuleName
```

### Listener Registration

```lua
-- Osiris events (server-side)
Ext.Osiris.RegisterListener("AttackedBy", 7, "after", function(target, attacker, a3, a4, a5, a6, damageType) ... end)
Ext.Osiris.RegisterListener("StatusApplied", 4, "before", function(status, target, causee, storyActionID) ... end)
Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(caster, spell, spellType, spellElement, storyActionID) ... end)
Ext.Osiris.RegisterListener("Dying", 4, "after", function(object, cause1, cause2, cause3) ... end)

-- Entity events
Ext.Entity.Subscribe("TurnStarted", function(entity, component) ... end)
```

### Essential Nil Safety

Every external lookup can return nil. Always guard:

```lua
local entity = Ext.Entity.Get(uuid)
if not entity then return end

local stat = Ext.Stats.Get(statName)
if not stat then return end

local turns = Osi.GetStatusTurns(target, statusName) or 0
```

### Dynamic Status Creation

For runtime statuses with variable parameters:

```lua
local name = "DYNAMIC_STATUS_" .. suffix
local stat = Ext.Stats.Create(name, "StatusData")
stat.StatusType = "BOOST"
stat.Duration = 1
stat.OnApplyFunctors = "DealDamage(" .. dice .. "," .. dmgType .. ")"
Ext.Stats.Sync(name)  -- MUST sync before applying
Osi.ApplyStatus(target, name, duration, turns, source)
```

### Recursion Guard

For chain/recursive mechanics that trigger on-hit:

```lua
local chainGuard = {}

local function ChainAttack(attacker, target)
    if chainGuard[attacker] then return end
    chainGuard[attacker] = true
    -- ... do the chain attack ...
    chainGuard[attacker] = nil
end
```

### Snapshot Before Iteration

When removing statuses during iteration:

```lua
local statuses = {}
for _, s in pairs(entity.StatusContainer.Statuses) do
    table.insert(statuses, s)
end
for _, s in ipairs(statuses) do
    Osi.RemoveStatus(target, s.StatusId)
end
```

### Server-to-Client Communication

Server-side loca updates don't reach client rendering. Use net messages:

```lua
-- Server
Ext.Net.PostMessageToClient(target, "ChannelName", Ext.Json.Stringify({handle = h, text = t}))

-- Client (BootstrapClient.lua)
Ext.RegisterNetListener("ChannelName", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    Ext.Loca.UpdateTranslatedString(data.handle, data.text)
end)
```

### PersistentVars

State that survives save/load:

```lua
-- BootstrapServer.lua initializes: PersistentVars = {}
-- Access anywhere:
PersistentVars['MyKey_' .. uuid] = value
```

### Useful Entity Fields

```lua
entity.Stats.Abilities[1]  -- STR (1-indexed: STR=1, DEX=2, CON=3, INT=4, WIS=5, CHA=6)
entity.Stats.Level          -- Character level
entity.ServerCharacter.Template.Name  -- Template name (for companion ID)
```

### SpellRoll Parsing

Extract save ability from a spell's stat definition:

```lua
local stat = Ext.Stats.Get(spellName)
if stat and stat.SpellRoll and type(stat.SpellRoll) == 'string' then
    local ability = stat.SpellRoll:match('SavingThrow%(Ability%.(%w+)')
    -- ability = "Wisdom", "Dexterity", etc.
end
```

---

## Cross-File Wiring Checklist

When implementing a new mechanic, ensure all pieces connect:

```
1. [ ] Stat entry created (.txt) — correct type, fields, using chain
2. [ ] Localization added (.xml) — DisplayName + Description contentuids match stat refs
3. [ ] DescriptionParams match — functor expressions in stat align with [1],[2] in loca text
4. [ ] Lua handler wired — listener registered in Init(), dispatched by EventHandlers
5. [ ] Status/passive referenced correctly — exact names match between .txt and .lua
6. [ ] Player access path exists — spell list / progression / passive grant connects to player
7. [ ] Mutual exclusion set — StackId/StackType if stances or toggles
8. [ ] Field length checked — long functor/condition lists under ~4000 chars
9. [ ] Nil safety — all Ext.Entity.Get, Ext.Stats.Get, Osi.GetStatusTurns guarded
10. [ ] Recursion guard — if mechanic can trigger itself (on-hit chains, etc.)
```

---

## Implementation Workflow

### Step 1 — Design the data flow

Before writing anything, sketch the mechanic as a chain:

```
Player activates [Spell/Passive/Toggle]
  → Applies [Status] to self/target
  → [Lua listener] fires on [event]
  → Calculates [effect]
  → Applies [result status/damage/boost]
```

Share this with the user to confirm before coding.

### Step 2 — Write stat entries

Create entries in the appropriate `.txt` file. Follow the mod's naming convention (check existing prefixes). Wire `using` inheritance from existing base entries where applicable.

### Step 3 — Write Lua handlers

Add handler functions to the appropriate system module. Register listeners in `Init()`. Wire into EventHandlers if the mod uses centralized dispatch.

### Step 4 — Add localization

Add `<content>` entries for every DisplayName and Description. Match the mod's contentuid convention. Include `DescriptionParams` formatting with `[1]`, `[2]` placeholders.

### Step 5 — Verify wiring

Run through the cross-file checklist above. Grep for each stat name, status name, and contentuid to confirm all references resolve.

---

## Common Pitfalls

| Pitfall | What happens | Fix |
|---------|-------------|-----|
| Field > ~4000 chars | Game hangs at 55% load | Split across multiple entries |
| `SG_Stunned` in ApplyStatus | Silently fails | Use `STUNNED` (the status, not the group) |
| Missing `Ext.Stats.Sync()` | Dynamic status has no effect | Always Sync before Apply |
| Raw LevelMapValue name in Boosts | Silently ignored | Wrap in `LevelMapValue(Name)` |
| `Dying` killer in wrong param | Explosion targets wrong entity | Check all 3 Cause params |
| AoE spell + per-hit chain | 5 targets = 5 chains | Use recursion guard table |
| Hardcoded save mapping | Wrong save DC for spells | Read from `SpellRoll` field |
| `ExecuteWeaponAttack` melee/ranged split | Unnecessary complexity | `MainHand` handles both |
| Modifying table during pairs() | Undefined behavior / skipped entries | Snapshot first |

---

## Step 6 — Update shared learnings

After implementation is complete, update the shared knowledge base at `<project>/.claude/skills/mod-check/learnings.md` if any of these occurred:

| Category | When to add |
|----------|------------|
| **Mistakes & Corrections** | You tried an approach that failed and had to fix it — record what went wrong and what worked |
| **Proven Patterns** | You discovered or confirmed a BG3 technique that works reliably |
| **False Positive Patterns** | Something that looks like a bug but is actually correct BG3 behavior |
| **Cleanest Solutions** | An implementation pattern that turned out particularly clean or DRY |

**Rules:**
- Deduplicate — check if the learning already exists before adding
- Be specific — include API names, field names, exact patterns
- Include the "why" — explain why the mistake happened or why the pattern works
- Keep entries to 1-3 lines each
