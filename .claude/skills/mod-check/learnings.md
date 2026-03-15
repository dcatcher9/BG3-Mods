# Mod-Check Learnings

Cross-mod knowledge accumulated from audit runs. Read this at the start of every mod-check to avoid repeating past mistakes and to apply proven patterns.

<!-- Last updated: 2026-03-14 -->

---

## Mistakes & Corrections

Things that were flagged as bugs but turned out to be wrong, or fixes that broke things.

- **SG_ prefixes are status groups, not applicable statuses**: `SG_Stunned`, `SG_Charmed`, etc. are status *groups* (used in `StatusImmunity(SG_Stunned)`), NOT applicable statuses. Always use specific status IDs: `STUNNED` not `SG_Stunned`, `CHARMED` not `SG_Charmed`. Applies to both `Osi.ApplyStatus` in Lua AND `ApplyStatus()` in stat functors (.txt files).

- **HideOverheadUI does not need AC(0)**: `Boosts ""` with `HideOverheadUI "0"` is sufficient for hiding overhead display. Adding `AC(0)` is unnecessary — confirmed in-game.

- **Dying event killer param**: The killer GUID is not always in the same Cause parameter of `Dying(Object, Cause1, Cause2, Cause3)`. Iterate all three Cause params to find the killer reliably.

- **Hardcoded save ability mapping is wrong**: Don't map damage types to save abilities (Fire→DEX, Cold→CON). The original spell already has save data in its `SpellRoll` field — extract it with `Ext.Stats.Get(spellName).SpellRoll` and pattern match `SavingThrow%(Ability%.(%w+)`.

- **ExecuteWeaponAttack handles melee and ranged**: `ExecuteWeaponAttack(MainHand)` uses whatever weapon is equipped — no need for separate melee/ranged handling.

---

## Proven Patterns & Best Practices

Approaches that have been validated to work correctly in BG3 modding.

### Stat / Data Patterns

- **Field length limit ~4000-5000 chars**: Per stat data field (StatsFunctors, ToggleOnFunctors, etc.). Exceeding causes game hang at ~55% loading. Fix: split across multiple PassiveData entries with Conditions gating.

- **Dynamic status creation**: `Ext.Stats.Create(name, "StatusData")` → set fields → `Ext.Stats.Sync(name)` → `Osi.ApplyStatus()`. Works for runtime-generated statuses with variable damage/saves. Remember to Sync before applying. Use this for dice damage (`DealDamage(Nd6,Type)`) and variable Boosts — `Osi.ApplyDamage` only supports flat integers.

- **`Osi.UseSpell(caster, spell, target)` for spell replication**: Makes the caster fully cast the spell on the target — engine handles dice, attack roll/save, and all spell effects. Far cleaner than manually recreating damage+save via dynamic statuses. Caveats: may consume spell slots, may trigger on-hit listeners (use recursion guards). Use `IgnoreHasSpell` in stat functor form: `UseSpell(SpellName, true, true)`.

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

- **`Osi.GetHostCharacter()` ≠ selected character**: Returns the host player's created character (Tav/Dark Urge), NOT the currently selected party member. To get the selected character, use `ClientControl` tag component on the client side (`Ext.Entity.GetAllEntitiesWithComponent("ClientControl")`) and bridge to server via `Ext.Net.PostMessageToServer`. Source: `bg3se/BG3Extender/GameDefinitions/Components/Data.h:215` defines `DEFINE_TAG_COMPONENT(eoc, ClientControlComponent, ClientControl)`.

---

## False Positive Patterns

Common things that look like bugs but aren't — avoid re-flagging these.

- **Empty Boosts on statuses**: Often intentional — overrides inherited boosts or serves as tooltip-only passive.
- **Statuses with duration -1**: Permanent by design, ended by script logic (dismiss/death/dispel).
- **Double Osi.GetStatString calls**: One for truthiness, one for value — minor redundancy, not a bug.
- **Hardcoded UUIDs with inline comments**: Acceptable when comment points to source.

- **OnDamaged context in passives**: `context.Target` = the passive OWNER (who took damage), `context.Source` = the attacker (who dealt damage). When checking if the attacker has a debuff (e.g., domain aura debuff), use `context.Source`, NOT `context.Target`. Confirmed by cross-referencing with WANFA passive which checks `context.Target` for the owner's own passive.

- **Duplicated constants in debug tools**: Debug/console tools (like `!bx` commands) intentionally duplicate constants from other modules for self-containment. Don't flag as redundancy.

- **BG3 AuraStatuses do NOT auto-clean**: When a source status with `AuraStatuses` expires, the applied aura statuses on targets do NOT automatically remove. You must add explicit `RemoveConditions "not HasStatus('SOURCE_STATUS',context.ObservedEntity)"` + `RemoveEvents "OnStatusRemoved"` to each aura-applied status. Verified by comparing LINGYU_DEBUFF (has RemoveConditions, works) vs ABSOLUTE_DEBUFF (missing, persists indefinitely).

- **Non-persistent Lua tables break on reload**: Local Lua tables (not backed by PersistentVars) reset when the game is saved/reloaded. Any mechanic tracking state in local tables (like stack counts) must either persist via PersistentVars or reconstruct state on SessionLoaded/GameStateChanged by reading entity status data.

---

## Cleanest Solutions Found

Elegant implementations worth emulating or recommending.

- **Shared base status pattern**: `BANXIAN_JJ5_FAZE_BASE` provides TickFunctors, StackId, StatusPropertyFlags. Individual stances `using` it override only display fields. DRY and maintainable.

- **Elemental mark cycling**: Track current mark index per-attacker, `% #MARKS + 1` to cycle. Separate scan function checks all enemies on battlefield for mark coverage.

- **Excess HP → permanent stat conversion**: Accumulate in PersistentVars, threshold scales with current stat (`entity.Stats.Abilities[N] * multiplier`), convert via dynamic boost status. Self-balancing because threshold grows with the stat.

- **Kill explosion + infection chain**: On kill → AoE damage + apply debuff to survivors → their kills also explode. Creates emergent chain reactions without explicit recursion.

- **Convex hull targeting for AoE**: Graham Scan on XZ coordinates of marked enemies, then PointInConvexHull check for bystanders. Creates dynamic, position-based AoE without fixed radius. Elegant for "area between marked targets" mechanics.
