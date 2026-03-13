# Patterns & Design Decisions — 种族·谪仙「三仙归人」
<!-- Last updated: 2026-03-12 -->

## Coding Patterns

### Nil safety
- All `GetStatusTurns` calls use `or 0` (or `or 1`, `or -1` where appropriate) fallback
- All `Ext.Entity.Get` results are nil-checked before component access
- All `Ext.Stats.Get` results are nil-checked before field access
- All `Osi.GetStatString` results are nil-checked before passing to other functions
- Status iteration uses snapshot-then-iterate pattern to avoid modifying during `pairs()`

### PersistentVars keying
- Per-character data is keyed by UUID (e.g., `PersistentVars['JingjieBoost_'..UUID]`)
- Per-weapon data uses stat name (e.g., `PersistentVars['FABAO_Stats_'..TYPE..'_'..FABAO]`)
- Timer state uses per-character keyed names (e.g., `'LingGen_Timer_'..UUID`)
- NPC tracking uses `BANXIANLIST_NO_` prefix

### Event architecture
- EventHandlers.lua registers all Osiris listeners and dispatches to system modules
- Each system module (DaoHeng, FaBao, etc.) exposes `OnStatusApplied_before/after`, `OnUsingSpell_after` etc.
- Signals use `SIGNAL_*` statuses applied/removed to trigger cross-system communication

### Stat organization
- Base shared stats in `BANXIAN_BASE.txt`
- Race-specific stats in `BANXIAN_TIAN/YAO/REN.txt`
- DaDao paths consolidated in `DADAO.txt`
- Each feature system has its own file (FABAO, DANYAO, XIULIAN, etc.)

## Intentional Design (do not re-flag)

- **Empty Boosts on ZhouTian acupoints 2,3,7,8,9,10**: Intentional — `Utils.BanXian.JingjieBoost()` dynamically creates and applies `BANXIAN_JJ_*` statuses with Ability bonuses scaling to realm.

- **DaoXinStable() always returns true**: `BANXIAN_DH_HEART_UNSTABLE` status is checked in ~35 DADAO.txt conditions but never defined or applied. Intentional placeholder for future "道心不稳" mechanic.

- **DR_QIFANHUO_DAN empty Boosts**: Empty `Boosts ""` in DANYAO.txt intentionally overrides inherited `DamageReduction(All,Half)`.

- **Full KiPoint restore on ZhouTian cycle**: `CUITI_ZHOUTIAN_1` restoring all KiPoints every cycle is intentional design.

- **BANXIAN_LG_GUANG_BOOST low-HP persistence**: `HasHPPercentageLessThan(30)` in RemoveConditions prevents removal at low HP — intentional; light root is stronger under pressure.

- **IsTargetWeaker strict `>`**: Equal-level targets are unaffected by design.

- **HTBG sub-spells empty**: 5 sub-spells with empty SpellProperties and no Lua handler — retained as placeholder. Design intent unknown.

- **LingGen.lua hardcoded UUID**: Line 154 has hardcoded UUID with inline comment pointing to Tags/. Acceptable with comment.

- **FaBao.LianHua.GetThreshold double Osi.GetStatString call**: Lines 189-190 call `Osi.GetStatString(Object)` twice (once for truthiness check, once for value). Minor redundancy, not a bug.
