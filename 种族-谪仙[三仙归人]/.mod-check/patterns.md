# Patterns & Design Decisions — 种族·谪仙「三仙归人」
<!-- Last updated: 2026-03-14 -->

## Coding Patterns

### Nil safety
- All `GetStatusTurns` calls use `or 0` (or `or 1`, `or -1` where appropriate) fallback
- All `Ext.Entity.Get` results are nil-checked before component access
- All `Ext.Stats.Get` results are nil-checked before field access
- All `Osi.GetStatString` results are nil-checked before passing to other functions
- Status iteration uses snapshot-then-iterate pattern to avoid modifying during `pairs()`
- Dynamic overhead text uses server→client net message (`BanXian_OverheadText`) + `Ext.Loca.UpdateTranslatedString` on client side
- Selected character tracking uses client→server net message (`BanXian_SelectedChar`)
- Companion identification uses `entity.ServerCharacter.Template.Name`

### PersistentVars keying
- Per-character data keyed by UUID
- Per-weapon data uses stat name
- Timer state uses per-character keyed names
- NPC tracking uses `BANXIANLIST_NO_` prefix
- Shadow clone state uses `XUYING_CLONE_`/`XUYING_OWNER_` prefix pairs
- Five-element cycle uses `WUXING_STAGE_` prefix
- Life/death law uses `SHENGMIE_EXCESS_`/`SHENGMIE_CON_` prefix

### Event architecture
- EventHandlers.lua registers all Osiris listeners and dispatches to system modules
- Each system module exposes `OnStatusApplied_before/after`, `OnUsingSpell_after` etc.
- JingJie.lua registers its own listeners in Init() (not routed through EventHandlers)
- Signals use `SIGNAL_*` statuses applied/removed

### Movement detection via position tracking
- No stat-only `OnMove` trigger exists for passives. Use Lua: record position on TurnStarted, compare on TurnEnded, if distance > threshold → trigger effect.
- Pattern: `faxiangTurnStartPos[guid] = {x,y,z}` on TurnStarted → check `dx*dx + dz*dz` on TurnEnded → AoE via Utils.GetNearbyEnemies.

### Spell replication via `Osi.UseSpell`
- Used in 因果律 chain for spell chains (replaces old dynamic status approach)
- Used in 剑道 projectile return
- Recursion guard (`yinGuoChaining` table) prevents infinite loop

### Dynamic status creation
- Pattern: `Ext.Stats.Create → set fields → :Sync() → Osi.ApplyStatus()`
- Used for dice damage, variable Boosts, status markers
- Check `Ext.Stats.Get(name) == nil` before creating
- Used extensively in new T6-T10 for variable damage statuses (VoidSunderKillExplosion, FaxiangDynamicDamage, DomainHighestHPDamage, ProcessTribulation, JieleiHutiCounter, NitianmingCheck)

### Shared base status pattern
- `BANXIAN_JJ5_FAZE_BASE` provides shared TickFunctors, StackId, StatusPropertyFlags for law stances
- `BANXIAN_JJ5_SHENGMIE_EXPLODE` used as base for all dynamic explosion/damage statuses

### Stat organization
- Base shared in BANXIAN_BASE.txt, race-specific in TIAN/YAO/REN.txt
- DaDao paths in DADAO.txt, JingJie (T5-10) in BANXIAN_JINGJIE.txt
- Each feature system has its own file

## Intentional Design (do not re-flag)

- **Empty Boosts on ZhouTian acupoints 2,3,7,8,9,10**: JingjieBoost() dynamically creates statuses.
- **DaoXinStable() always returns true**: Placeholder for future "道心不稳" mechanic.
- **DR_QIFANHUO_DAN empty Boosts**: Intentionally overrides inherited DamageReduction.
- **Full KiPoint restore on ZhouTian cycle**: Intentional design.
- **BANXIAN_LG_GUANG_BOOST low-HP persistence**: Light root stronger under pressure.
- **IsTargetWeaker strict `>`**: Equal-level targets unaffected by design.
- **HTBG sub-spells empty**: Retained as placeholder.
- **LingGen.lua hardcoded UUID**: Acceptable with inline comment.
- **FaBao.LianHua.GetThreshold double Osi.GetStatString call**: Minor redundancy, not a bug.
- **Dismiss-on-recast pattern for 掌日 Control**: Intentional dismiss mechanic.
- **HideOverheadUI without AC(0)**: Confirmed in-game.
- **Control statuses permanent by design**: Duration -1 for target, FreezeDuration for caster.
- **Empty tooltip passives**: YINGUO_PASSIVE, WUXING_PASSIVE, FAXIANG_AURA, LINGYU_PASSIVE exist as UI anchors.
- **Shared law stance base status**: FAZE_BASE provides common fields.
- **Recursion guards**: yinGuoChaining, XUYING_RECALLING_ prevent reentry.
- **Debug.lua self-contained constants**: DADAO_SUFFIX/SHENSHI_UUID duplicated intentionally.
- **ProcessTribulation estimated self-damage**: Uses `stacks×16` avg estimate, not actual dice rolls. Design choice for consistent self-damage.
- **VOID_EROSION no max stack**: 3-turn duration + 1 attack/turn on clone effectively caps at 3 stacks.
- **JIEQI_PIERCE only ignores Resistant, not Immune**: Design choice — immunity is intentionally stronger than the pierce effect.
- **SWAP_BLUR uses StatusType BLUR**: Correct — gives attack disadvantage against the user, matching "虚化" (becoming ethereal). Not a type mismatch.
