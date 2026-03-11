# Mod Check — 种族·谪仙「三仙归人」
<!-- Mod path: 种族-谪仙[三仙归人] -->
<!-- Last updated: 2026-03-11 -->

## Status
- **Coverage:** ~37 of ~107 files fully read, ~4 partially read, ~66 not yet read
- **Open issues:** 7 (0 red, 2 orange, 4 yellow, 0 blue, 1 white)
- **Fixed issues:** 13

## Open Issues

### 🔴 Bugs / Errors

*(none remaining — all red bugs fixed)*

### 🟠 Wrong Behavior

- [ ] **WB-01** `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_TIAN.txt` `CuiTi_ZhouTian_2,3,7,8,9,10` — Six of twelve ZhouTian acupoints have `data "Boosts" ""` — player selects them from the BANXIANCUITI PassiveList and receives no permanent benefit. *Fix: add meaningful boosts to each acupoint (design decision required).*
- [ ] **WB-02** `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_TIAN.txt` `CUITI_ZHOUTIAN_1` — `OnApply` contains `RestoreResource(KiPoint,100%,0)`. If this status is reapplied at the start of each circulation cycle (not just once per rest), the player gets a full KiPoint refill every cycle. Confirm whether this is intended or should be moved to `OnStatusApplied` with a rest-scoped guard. *Fix: verify intent; add `OncePerShortRest` or equivalent if unintentional.*
- [ ] **WB-04** `Public/XSS_BANXIAN/Stats/Generated/Data/DANYAO.txt` `DR_QIFANHUO_DAN` — 七返火丹 has `data "Boosts" ""` and only applies `DT_BASE_LONGREST` on use. No fire-related bonus despite the thematic name. *Fix: add intended fire boost, or document that long-rest restore is the complete effect.*

### 🟡 Logic / Consistency

- [ ] **L-01** `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_REN.txt` `BANXIAN_LG_GUANG_BOOST` — `RemoveConditions` includes `HasHPPercentageLessThan(30)`, which removes the sunlight LingGen buff when the character is at low HP. Counter-intuitive for a "light" root unless intentional. *Confirm: is this by design?*
- [ ] **L-02** `Scripts/thoth/helpers/XSS_BANXIAN.khn` `IsTargetWeaker()` — Uses strict `>` (source level strictly greater than target). If the intent is "source at least as strong," should be `>=`. Equal-level targets are currently unaffected. *Confirm: is equal-level suppression intended?*
- [ ] **L-03** `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/LingGen.lua:154` — Hardcoded UUID `fe825e69-1569-471f-9b3f-28fd3b929683` for player race tag check. Added inline comment pointing to Tags/. *Remaining: optionally replace with a named constant in Variables.lua.*
- [ ] **L-04** `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/Base.lua:81` `DualAttack_Before()` — No nil guard before `entity.ActionResources.Resources[BonusActionPoint_UUID][1].Amount`. Crashes if entity lacks the bonus-action resource. *Fix: wrap with `if entity.ActionResources.Resources[UUID] and entity.ActionResources.Resources[UUID][1] then`.*
- [ ] **L-05** `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/EventHandlers.lua:91,95` — `Variables.Constants.Hostile` dict and `PersistentVars['Jiandao_Projectile']` are single-slot stores for timer callbacks. Simultaneous casts by two characters corrupt each other's data before the timer fires. *Fix: key by caster UUID (e.g., `PersistentVars['Jiandao_Projectile_'..Caster]`).*

### 🔵 Redundancy

*(none confirmed — suspected duplicates in FIXS.txt/LUA.txt verified as false positives)*

### ⚪ Minor / Typos

- [ ] **T-01** `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/LingGen.lua` `LingGen.GetCharacterParams()` — Companion LingGen values are hardcoded in an if/elseif chain by companion name. A data table in `Variables.lua` would be easier to maintain. *Low priority; address if adding/rebalancing companions.*

## Fixed / Resolved Issues

- [x] **B-01** `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/LingGen.lua:225` — `math.random()` called with float arguments (crash in Lua 5.3+). *(fixed 2026-03-11)*
- [x] **B-02** `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_TIAN.txt:176` `CuiTi_ZhouTian_6` — `DamageReduction` used raw `BanXianDice` name instead of `LevelMapValue(BanXianDice)`. *(fixed 2026-03-11)*
- [x] **B-03** `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_YAO.txt` `BANXIAN_DEVILFORMS_9` — `ObjectSize(+9)` exceeded game maximum. Capped to `ObjectSize(+6)`. *(fixed 2026-03-11)*
- [x] **B-04** `Public/XSS_BANXIAN/Stats/Generated/Data/SHENTONG.txt` `BANXIAN_CREATUREBAG` — `StatusPropertyFlags` was commented out; status showed overhead/combat-log spam. *(fixed 2026-03-11)*
- [x] **B-05** `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_YAO.txt` `BANXIAN_FSZMG_Level9` — `TickType`/`TickFunctors` commented out with TODO (capstone self-heal/cleanse not firing). Implemented via `StatsFunctorContext "OnTurn"` + `StatsFunctors`. *(fixed 2026-03-11)*
- [x] **B-06** `Public/XSS_BANXIAN/MultiEffectInfos/BANXAIN_ANIMATION_FLY.lsf.lsx` — Filename typo `BANXAIN` → `BANXIAN`; fly animation effect would not load. Both `.lsf.lsx` and `.lsx` variants renamed. *(fixed 2026-03-11)*
- [x] **BL-01** `Scripts/thoth/helpers/XSS_BANXIAN.khn:62` `BLEEDINGPercentageMoreThan()` — Compared bleeding duration (turns) against `MaxHP * value / 100` — dimensionally wrong. Fixed to compare duration directly against `value`, consistent with DADAO.txt's damage formula. *(fixed 2026-03-11)*
- [x] **T-03** `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_YAO.txt:757` `BANXIAN_Yao_RedDragon` — Comment was copy-pasted Wolf ability description. Corrected to describe RedDragon's actual effect. *(fixed 2026-03-11)*
- [x] **WB-03** `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/DanYao.lua` `WuYunDan()` — Variable `r` was computed but never used; upgrade always succeeded unconditionally. Added `LG_TZ==0` initial branch (→1, r=100) and probability gate `math.random(1,100) <= r`. *(fixed 2026-03-11)*
- [x] **L-04** `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/Base.lua:81` — Added nil guard on `Resources[BonusActionPoint_UUID][1]` before accessing `.Amount`. *(fixed 2026-03-11)*
- [x] **T-04** `Public/XSS_BANXIAN/Stats/Generated/Data/DANYAO.txt:622` — `DT_TAIYI_XIAOHUANDAN` StackId renamed from `DT_TaiYiXiaoHuanDan` to `DT_TAIYI_XIAOHUANDAN` for consistency. *(fixed 2026-03-11)*
- [x] **T-02** `Public/XSS_BANXIAN/Stats/Generated/Data/LUA.txt` — Renamed to `OVERRIDES.txt`; stat entry names and cross-references are unaffected. *(fixed 2026-03-11)*

## Feature Completeness

| Feature / System | Status | Player Access | Notes |
|---|---|---|---|
| LingGen elemental roots (灵根) | Partial | Passive/Aura | 5 base + 8 composite TianLingGen all implemented; Yi LingGen consistent |
| ZhouTian circulation (周天淬体) | Partial | Spell + Passive | 12 acupoints; 6 passives still have empty Boosts (WB-01); statuses have proper effects |
| Shenshi mind-sense (神识) | Full | Spell | PassiveData, 5 sub-spells, Lua, KHN all consistent |
| DaoXin/DaoHeng realm (大道境界) | Full | Passive/Aura | DH_YEAR/MONTH/DAY stack system + DaoHeng.lua confirmed |
| ZhenFa formation magic (阵法) | Full | Spell | 9-level core + 8 flag types + summon characters |
| FSZMG YaoXian cultivation (梵圣真魔功) | Partial | Passive + Spell | Levels 1–9; Level9 capstone fixed; DevilForms ObjectSize capped |
| XiuLian qi absorption (修炼) | Full | Spell | Spell, Lua, LINGQI statuses consistent |
| BANXIANSHENTONG polymorphs (神通) | Full | Spell | 72/36-change passives; Rulebook rules confirmed; Base.lua transform logic present |
| RenXian organ system (五脏六腑) | Partial | Passive List | TianLingGen variants confirmed; BANXIAN_REN.txt lines 801–2319 unread |
| FaBao artifact system (法宝) | Partial | Feat + Progression | Variables constants + Materials table confirmed; FABAO.txt (950 lines) unread |
| FaBao 百脉锻宝诀 (BaiMai) | Full | Passive List | Slots 1–6 + A1/A2/S tier passives all defined; fully read |
| GongFa techniques (功法) | Full | Progression Selector | GONGFA_SELECTOR.txt + DADAO selectors confirmed |
| Beast forms BenXiang (本相) | Full | Passive List | 10 forms; WildShapeYaoXian Rulebook rule confirmed |
| ExtraAttack chain | Full | Passive/Aura | ExtraAttack_3–9 + queue statuses; up to 10 attacks |
| DanYao alchemy system (丹药) | Full | Item + Passive | 35 pills defined; drop/brew logic confirmed; WuYunDan probability gap (WB-03) |
| Hardcore mode (BANXIAN_HARDCORE) | Partial | Script-only | Status defined; no Story/Goals directory found |

### Feature gaps requiring follow-up

**ZhouTian acupoints 2, 3, 7, 8, 9, 10 (WB-01):** Each passive (the permanent bonus) has an empty `Boosts` field. The circulation *statuses* (e.g., `CUITI_ZHOUTIAN_7`) have proper per-turn effects. The passives need meaningful permanent bonuses defined — design decision required.

**RenXian organ system:** BANXIAN_REN.txt (2319 lines) was read through line 800. TianLingGen composite roots all confirmed implemented. Lines 801–2319 contain the main organ-system passives/statuses and have not yet been audited.

**FaBao artifact system:** FABAO.txt (950 lines) remains unread. Variables.lua confirms the full 8-material × 3-slot (Weapon/Armor/Ring) passive mapping. A complete audit of FABAO.txt is pending.

**WuYunDan probability gate (WB-03):** Variable `r` in `DanYao.WuYunDan()` is computed per tier but never used. If probabilistic success was intended, the gate is missing.

**Hardcore mode:** `BANXIAN_HARDCORE` status exists in DIFFICULTY.txt. No `Story/RawFiles/Goals/` directory found — Osiris story scripts may be absent or this feature relies solely on Lua.

## Coverage

### Fully read
- `Mods/XSS_BANXIAN/meta.lsx`
- `Mods/XSS_BANXIAN/ScriptExtender/Config.json`
- `Public/XSS_BANXIAN/Progressions/Progressions.lsx`
- `Public/XSS_BANXIAN/ActionResourceDefinitions/ActionResourceDefinitions.lsx`
- `Public/XSS_BANXIAN/Lists/SpellLists.lsx`
- `Public/XSS_BANXIAN/Lists/PassiveLists.lsx`
- `Public/XSS_BANXIAN/Feats/Feats.lsx`
- `Public/XSS_BANXIAN/Feats/FeatDescriptions.lsx`
- `Public/XSS_BANXIAN/ErrorDescriptions/ConditionErrors.lsx`
- `Public/XSS_BANXIAN/Hints/Hints.lsx`
- `Public/XSS_BANXIAN/Levelmaps/LevelMapValues.lsx`
- `Public/XSS_BANXIAN/Shapeshift/Rulebook.lsx`
- `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_YAO.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_TIAN.txt` (798 lines — fully read across sessions)
- `Public/XSS_BANXIAN/Stats/Generated/Data/XIULIAN.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/SHENSHI.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/SHENTONG.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/GONGFA_SELECTOR.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/DIFFICULTY.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/DANYAO.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/BOOK.txt`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/BootstrapServer.lua` *(was at wrong path in prior record)*
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Main.lua` *(was at wrong path in prior record)*
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Variables.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/EventHandlers.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/Base.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/DanYao.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/LingGen.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/ShenShi.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/XiuLian.lua`
- `Scripts/thoth/helpers/XSS_BANXIAN.khn`
- `Public/XSS_BANXIAN/MultiEffectInfos/BANXIAN_ANIMATION_FLY.lsf.lsx` (filename typo fixed)

### Partially read
- `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_BASE.txt` (key sections via Grep; not fully read)
- `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_REN.txt` (lines 1–800 of 2319)
- `Public/XSS_BANXIAN/Stats/Generated/Data/DADAO.txt` (~100 lines read + targeted Grep)
- `Public/XSS_BANXIAN/Stats/Generated/Data/FIXS.txt` (key entries via Grep)
- `Public/XSS_BANXIAN/Stats/Generated/Data/OVERRIDES.txt` (formerly LUA.txt; key entries via Grep)
- `Public/XSS_BANXIAN/Stats/Generated/Data/ZHENFA.txt` (partial)
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/DaoHeng.lua` (first 100 lines of ~400+)

### Not yet read
- `Public/XSS_BANXIAN/CharacterCreation/RENXIAN.lsx` (1.6 MB — too large for full read; use Grep)
- `Public/XSS_BANXIAN/CharacterCreation/TIANXIAN.lsx` (1.6 MB — too large for full read; use Grep)
- `Public/XSS_BANXIAN/CharacterCreation/YAOXIAN.lsx` (1.6 MB — too large for full read; use Grep)
- `Public/XSS_BANXIAN/Races/Races.lsx` (450 KB — too large; use Grep for targeted checks)
- `Public/XSS_BANXIAN/Progressions/ProgressionDescriptions.lsx`
- `Public/XSS_BANXIAN/CharacterCreationPresets/CharacterCreationPresets.lsx`
- `Public/XSS_BANXIAN/Lists/SkillLists.lsx`
- `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_BASE.txt` (full read pending)
- `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_REN.txt` (lines 801–2319 pending)
- `Public/XSS_BANXIAN/Stats/Generated/Data/DADAO.txt` (1707 lines; bulk unread)
- `Public/XSS_BANXIAN/Stats/Generated/Data/FABAO.txt` (950 lines — unread)
- `Public/XSS_BANXIAN/Stats/Generated/Data/SpellSet.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Equipment.txt`
- `Public/XSS_BANXIAN/Stats/Generated/ItemCombos.txt`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Utils.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/DaoHeng.lua` (lines 101+ pending)
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/GongFa.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/FaBao.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/Difficulty.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/ZhenFa.lua`
- `Mods/XSS_BANXIAN/Localization/English/XSS_BANXIAN.xml`
- `Public/XSS_BANXIAN/GUI/newAtlas.lsx`
- `Public/XSS_BANXIAN/Tags/` (all .lsx files)
- `Story/RawFiles/Goals/` (directory not found — may not exist)
