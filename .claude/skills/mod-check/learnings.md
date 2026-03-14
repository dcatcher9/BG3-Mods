# Mod-Check Learnings

Cross-mod knowledge accumulated from audit runs. Read this at the start of every mod-check to avoid repeating past mistakes and to apply proven patterns.

<!-- Last updated: 2026-03-14 -->

---

## Mistakes & Corrections

Things that were flagged as bugs but turned out to be wrong, or fixes that broke things.

- **SG_Stunned vs STUNNED**: `SG_Stunned` is a status *group* (used in `StatusImmunity(SG_Stunned)`), NOT an applicable status. Always use `STUNNED` when applying stun via `Osi.ApplyStatus`. Same pattern likely applies to other SG_ prefixed names.

- **HideOverheadUI does not need AC(0)**: `Boosts ""` with `HideOverheadUI "0"` is sufficient for hiding overhead display. Adding `AC(0)` is unnecessary — confirmed in-game.

- **Dying event killer param**: The killer GUID is not always in the same Cause parameter of `Dying(Object, Cause1, Cause2, Cause3)`. Iterate all three Cause params to find the killer reliably.

- **Hardcoded save ability mapping is wrong**: Don't map damage types to save abilities (Fire→DEX, Cold→CON). The original spell already has save data in its `SpellRoll` field — extract it with `Ext.Stats.Get(spellName).SpellRoll` and pattern match `SavingThrow%(Ability%.(%w+)`.

- **ExecuteWeaponAttack handles melee and ranged**: `ExecuteWeaponAttack(MainHand)` uses whatever weapon is equipped — no need for separate melee/ranged handling.

---

## Proven Patterns & Best Practices

Approaches that have been validated to work correctly in BG3 modding.

### Stat / Data Patterns

- **Field length limit ~4000-5000 chars**: Per stat data field (StatsFunctors, ToggleOnFunctors, etc.). Exceeding causes game hang at ~55% loading. Fix: split across multiple PassiveData entries with Conditions gating.

- **Dynamic status creation**: `Ext.Stats.Create(name, "StatusData")` → set fields → `Ext.Stats.Sync(name)` → `Osi.ApplyStatus()`. Works for runtime-generated statuses with variable damage/saves. Remember to Sync before applying.

- **LevelMapValue in Boosts**: Must use `LevelMapValue(Name)` wrapper — raw name silently fails.

- **StackId for mutual exclusion**: Statuses sharing a `StackId` + `StackType "Overwrite"` automatically replace each other. Use a shared base status with `using` to DRY the common fields.

### Lua Patterns

- **Recursion guard table**: For chain/recursive mechanics (like 因果律 chain attacks), use a per-entity table (`local chainGuard = {}`) set before triggering and cleared after. Prevents on-hit passives from re-triggering the chain.

- **UsingSpell listener for spell tracking**: `Ext.Osiris.RegisterListener("UsingSpell", 5, "after", ...)` captures the last spell cast per character. Useful for mechanics that need to know what spell triggered an attack.

- **SpellRoll field parsing**: `stat.SpellRoll` contains save info as string. Pattern: `roll:match('SavingThrow%(Ability%.(%w+)')` extracts the save ability.

- **Utils.GetNearbyEnemies reuse**: The codebase has utility functions — check before writing custom proximity logic.

- **Snapshot-then-iterate**: When removing statuses during iteration, snapshot the list first to avoid modifying during `pairs()`.

- **entity.Stats.Abilities[3]** = Constitution score (1-indexed: STR=1, DEX=2, CON=3, INT=4, WIS=5, CHA=6).

### Cross-System Interaction

- **AoE spells trigger per-target**: A Fireball hitting 5 targets fires 5 separate AttackedBy events. Chain mechanics must account for this (potentially 5 separate chains from one spell).

- **PHYSICAL_DAMAGE distinction**: `{Slashing=true, Piercing=true, Bludgeoning=true}` table distinguishes weapon attacks from spell attacks by damage type.

- **Server→Client net messages**: Server-side loca updates don't propagate to client rendering. Use `Ext.Net.PostMessageToClient` + client-side `Ext.Loca.UpdateTranslatedString` for overhead text.

---

## False Positive Patterns

Common things that look like bugs but aren't — avoid re-flagging these.

- **Empty Boosts on statuses**: Often intentional — overrides inherited boosts or serves as tooltip-only passive.
- **Statuses with duration -1**: Permanent by design, ended by script logic (dismiss/death/dispel).
- **Double Osi.GetStatString calls**: One for truthiness, one for value — minor redundancy, not a bug.
- **Hardcoded UUIDs with inline comments**: Acceptable when comment points to source.

---

## Cleanest Solutions Found

Elegant implementations worth emulating or recommending.

- **Shared base status pattern**: `BANXIAN_JJ5_FAZE_BASE` provides TickFunctors, StackId, StatusPropertyFlags. Individual stances `using` it override only display fields. DRY and maintainable.

- **Elemental mark cycling**: Track current mark index per-attacker, `% #MARKS + 1` to cycle. Separate scan function checks all enemies on battlefield for mark coverage.

- **Excess HP → permanent stat conversion**: Accumulate in PersistentVars, threshold scales with current stat (`entity.Stats.Abilities[N] * multiplier`), convert via dynamic boost status. Self-balancing because threshold grows with the stat.

- **Kill explosion + infection chain**: On kill → AoE damage + apply debuff to survivors → their kills also explode. Creates emergent chain reactions without explicit recursion.
