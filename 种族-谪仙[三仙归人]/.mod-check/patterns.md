# Patterns & Design Decisions — 种族·谪仙「三仙归人」
<!-- Last updated: 2026-03-14 -->

## Coding Patterns

### Nil safety
- All `GetStatusTurns` calls use `or 0` (or `or 1`, `or -1` where appropriate) fallback
- All `Ext.Entity.Get` results are nil-checked before component access
- All `Ext.Stats.Get` results are nil-checked before field access
- All `Osi.GetStatString` results are nil-checked before passing to other functions
- Status iteration uses snapshot-then-iterate pattern to avoid modifying during `pairs()`
- Dynamic overhead text uses server→client net message (`BanXian_OverheadText`) + `Ext.Loca.UpdateTranslatedString` on client side, since server-side loca updates don't propagate to client rendering
- Selected character tracking uses client→server net message (`BanXian_SelectedChar`) — client subscribes to `Ext.Events.Tick`, reads `ClientControl` component to find selected character, sends UUID to server when it changes. Debug.lua uses this to target `!bx` commands at the selected party member instead of only the host character.
- Companion identification uses `entity.ServerCharacter.Template.Name` (not `Osi.GetOrigin` which was removed in newer BG3SE)

### PersistentVars keying
- Per-character data is keyed by UUID (e.g., `PersistentVars['JingjieBoost_'..UUID]`)
- Per-weapon data uses stat name (e.g., `PersistentVars['FABAO_Stats_'..TYPE..'_'..FABAO]`)
- Timer state uses per-character keyed names (e.g., `'LingGen_Timer_'..UUID`)
- NPC tracking uses `BANXIANLIST_NO_` prefix
- Shadow clone state uses `XUYING_CLONE_`/`XUYING_OWNER_` prefix pairs
- Five-element cycle uses `WUXING_STAGE_` prefix
- Life/death law uses `SHENGMIE_EXCESS_`/`SHENGMIE_CON_` prefix

### Event architecture
- EventHandlers.lua registers all Osiris listeners and dispatches to system modules
- Each system module (DaoHeng, FaBao, JingJie, etc.) exposes `OnStatusApplied_before/after`, `OnUsingSpell_after` etc.
- JingJie.lua registers its own listeners in Init() (not routed through EventHandlers) since it was added later
- Signals use `SIGNAL_*` statuses applied/removed to trigger cross-system communication

### Spell replication via `Osi.UseSpell`
- `Osi.UseSpell(caster, spellName, target)` — engine fully casts the spell (dice, attack roll/save, all effects)
- Used in 因果律 chain (JingJie.lua) for spell chains — replaces manual dynamic status damage
- Used in 剑道 projectile return (DaoHeng.lua:314) — `Osi.UseSpell(Causee, spell, Object)`
- Recursion guard (`yinGuoChaining` table) prevents chain spell → AttackedBy → re-chain infinite loop

### Dynamic status creation
- Pattern: `Ext.Stats.Create(name, 'StatusData', base) → set fields → :Sync() → Osi.ApplyStatus()`
- Used for dice damage (五行崩 bursts), variable Boosts (THP, Ability), status markers
- Check `Ext.Stats.Get(name) == nil` before creating to avoid re-registration
- `Osi.ApplyDamage` is flat-integer only — use dynamic statuses when dice expressions are needed for combat log display

### Stat organization
- Base shared stats in `BANXIAN_BASE.txt`
- Race-specific stats in `BANXIAN_TIAN/YAO/REN.txt`
- DaDao paths consolidated in `DADAO.txt`
- Each feature system has its own file (FABAO, DANYAO, XIULIAN, etc.)
- JingJie (Tier 5-10) consolidated in `BANXIAN_JINGJIE.txt`

## Intentional Design (do not re-flag)

- **Empty Boosts on ZhouTian acupoints 2,3,7,8,9,10**: Intentional — `Utils.BanXian.JingjieBoost()` dynamically creates and applies `BANXIAN_JJ_*` statuses with Ability bonuses scaling to realm.

- **DaoXinStable() always returns true**: `BANXIAN_DH_HEART_UNSTABLE` status is checked in ~35 DADAO.txt conditions but never defined or applied. Intentional placeholder for future "道心不稳" mechanic.

- **DR_QIFANHUO_DAN empty Boosts**: Empty `Boosts ""` in DANYAO.txt intentionally overrides inherited `DamageReduction(All,Half)`.

- **Full KiPoint restore on ZhouTian cycle**: `CUITI_ZHOUTIAN_1` restoring all KiPoints every cycle is intentional design.

- **BANXIAN_LG_GUANG_BOOST low-HP persistence**: `HasHPPercentageLessThan(30)` in RemoveConditions prevents removal at low HP — intentional; light root is stronger under pressure.

- **IsTargetWeaker strict `>`**: Equal-level targets are unaffected by design.

- **HTBG sub-spells empty**: 5 sub-spells with empty SpellProperties and no Lua handler — retained as placeholder. Design intent unknown.

- **LingGen.lua hardcoded UUID**: Line 235 has hardcoded UUID with inline comment pointing to Tags/. Acceptable with comment.

- **FaBao.LianHua.GetThreshold double Osi.GetStatString call**: Minor redundancy, not a bug.

- **Dismiss-on-recast pattern for 掌日 Control**: When SHENSHICONTROL_TARGET is re-applied by same caster on same target, Lua detects the existing pair via PersistentVars and removes both statuses. A `dismissingCaster` table with 100ms timer prevents SpellSuccess from re-applying SHENSHICONTROL_CASTER. StatusRemoved cleanup handles death/dispel with `removingControl` reentry guard.

- **HideOverheadUI without AC(0)**: `Boosts ""` + `HideOverheadUI "0"` is sufficient for overhead display. `AC(0)` is NOT required — confirmed in-game 2026-03-13.

- **Control statuses are permanent by design**: SHENSHICONTROL_TARGET has duration -1; SHENSHICONTROL_CASTER uses FreezeDuration + MultiplyEffectsByDuration to encode ShenshiPoint cost as duration.

- **Empty tooltip passives**: YINGUO_PASSIVE, WUXING_PASSIVE, FAXIANG_AURA, LINGYU_PASSIVE have no functors — they exist solely as UI anchors.

- **Shared law stance base status**: `BANXIAN_JJ5_FAZE_BASE` provides shared TickFunctors (Shenshi depletion + auto-deactivation), StackId/StackType, and StatusPropertyFlags for all 3 law stances.

- **Recursion guard for chain mechanics**: `yinGuoChaining` table prevents AttackedBy from re-triggering YinGuoChain during chain execution. `XUYING_RECALLING_` prevents reentry in shadow clone recall/death.

- **Debug.lua self-contained constants**: DADAO_SUFFIX and SHENSHI_UUID are duplicated in Debug.lua for self-containment of the debug tool. Acceptable redundancy.
