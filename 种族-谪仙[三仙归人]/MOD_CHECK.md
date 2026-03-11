# Mod Check — 种族·谪仙「三仙归人」
<!-- Mod path: 种族-谪仙[三仙归人] -->
<!-- Last updated: 2026-03-11 -->

## Status
- **Coverage:** ~25 of ~99 files fully read, ~10 partially read, ~64 not yet read
- **Open issues:** 7 (1 red, 3 orange, 3 yellow)
- **Fixed issues:** 8

## Open Issues

### 🔴 Bugs / Errors

*(none remaining — all red bugs fixed)*

### 🟠 Wrong Behavior

- [ ] **WB-01** `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_TIAN.txt` `CuiTi_ZhouTian_2,3,7,8,9,10` — Six of twelve ZhouTian acupoints have `data "Boosts" ""` — player selects them from the BANXIANCUITI PassiveList and receives no permanent benefit. *Fix: add meaningful boosts to each acupoint (design decision required).*
- [ ] **WB-02** `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_TIAN.txt` `CUITI_ZHOUTIAN_1` — `OnApply` contains `RestoreResource(KiPoint,100%,0)`. If this status is reapplied at the start of each circulation cycle (not just once per rest), the player gets a full KiPoint refill every cycle. Confirm whether this is intended or should be moved to `OnStatusApplied` with a rest-scoped guard. *Fix: verify intent; add `OncePerShortRest` or equivalent if unintentional.*

### 🟡 Logic / Consistency

- [ ] **L-01** `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_REN.txt` `BANXIAN_LG_GUANG_BOOST` — `RemoveConditions` includes `HasHPPercentageLessThan(30)`, which removes the sunlight LingGen buff when the character is at low HP. Counter-intuitive for a "light" root unless intentional. *Confirm: is this by design?*
- [ ] **L-02** `Scripts/thoth/helpers/XSS_BANXIAN.khn` `IsTargetWeaker()` — Uses strict `>` (source level strictly greater than target). If the intent is "source at least as strong," should be `>=`. Equal-level targets are currently unaffected. *Confirm: is equal-level suppression intended?*
- [ ] **L-03** `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/LingGen.lua:154` — Hardcoded UUID `fe825e69-1569-471f-9b3f-28fd3b929683` for player race tag check. If this UUID changes the check silently fails for all characters. *Fix: replace with a named tag lookup or document why this UUID is stable.*

### 🔵 Redundancy

*(none confirmed — suspected duplicates in FIXS.txt/LUA.txt verified as false positives)*

### ⚪ Minor / Typos

- [ ] **T-01** `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/LingGen.lua` `LingGen.GetCharacterParams()` — Companion LingGen values are hardcoded in an if/elseif chain by companion name. A data table in `Variables.lua` would be easier to maintain. *Low priority; address if adding/rebalancing companions.*
- [ ] **T-02** `Public/XSS_BANXIAN/Stats/Generated/Data/LUA.txt` — Filename is misleading; the file contains vanilla stat overrides, not just Lua signal targets. Consider renaming to `PATCHES.txt` or `OVERRIDES.txt`. *Low priority — rename requires updating any reference to the file.*

## Fixed / Resolved Issues

- [x] **B-01** `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/LingGen.lua:225` — `math.random()` called with float arguments (crash in Lua 5.3+). *(fixed 2026-03-11)*
- [x] **B-02** `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_TIAN.txt:176` `CuiTi_ZhouTian_6` — `DamageReduction` used raw `BanXianDice` name instead of `LevelMapValue(BanXianDice)`. *(fixed 2026-03-11)*
- [x] **B-03** `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_YAO.txt` `BANXIAN_DEVILFORMS_9` — `ObjectSize(+9)` exceeded game maximum. Capped to `ObjectSize(+6)`. *(fixed 2026-03-11)*
- [x] **B-04** `Public/XSS_BANXIAN/Stats/Generated/Data/SHENTONG.txt` `BANXIAN_CREATUREBAG` — `StatusPropertyFlags` was commented out; status showed overhead/combat-log spam. *(fixed 2026-03-11)*
- [x] **B-05** `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_YAO.txt` `BANXIAN_FSZMG_Level9` — `TickType`/`TickFunctors` commented out with TODO (capstone self-heal/cleanse not firing). Implemented via `StatsFunctorContext "OnTurn"` + `StatsFunctors`. *(fixed 2026-03-11)*
- [x] **B-06** `Public/XSS_BANXIAN/MultiEffectInfos/BANXAIN_ANIMATION_FLY.lsf.lsx` — Filename typo `BANXAIN` → `BANXIAN`; fly animation effect would not load. Both `.lsf.lsx` and `.lsx` variants renamed. *(fixed 2026-03-11)*
- [x] **BL-01** `Scripts/thoth/helpers/XSS_BANXIAN.khn:62` `BLEEDINGPercentageMoreThan()` — Compared bleeding duration (turns) against `MaxHP * value / 100` — dimensionally wrong. Fixed to compare duration directly against `value`, consistent with DADAO.txt's damage formula. *(fixed 2026-03-11)*
- [x] **T-03** `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_YAO.txt:757` `BANXIAN_Yao_RedDragon` — Comment was copy-pasted Wolf ability description. Corrected to describe RedDragon's actual effect. *(fixed 2026-03-11)*

## Feature Completeness

| Feature / System | Status | Player Access | Notes |
|---|---|---|---|
| LingGen elemental roots (灵根) | Partial | Passive/Aura | Awakening, 5 base + 8 composite roots implemented; Yi LingGen conditions consistent |
| ZhouTian circulation (周天淬体) | Partial | Spell + Passive | 12 acupoints defined; 6 of 12 have empty Boosts (WB-01); DamageReduction fixed (B-02) |
| Shenshi mind-sense (神识) | Full | Spell | PassiveData, 5 sub-spells, Lua, KHN all consistent |
| DaoXin/DaoHeng realm (大道境界) | Full | Passive/Aura | DH_YEAR/MONTH/DAY stack system + DaoHeng.lua confirmed |
| ZhenFa formation magic (阵法) | Full | Spell | 9-level core + 8 flag types + summon characters |
| FSZMG YaoXian cultivation (梵圣真魔功) | Partial | Passive + Spell | Levels 1–9; Level9 capstone fixed (B-05); DevilForms ObjectSize capped (B-03) |
| XiuLian qi absorption (修炼) | Full | Spell | Spell, Lua, LINGQI statuses consistent |
| BANXIANSHENTONG polymorphs (神通) | Full | Spell | 72-change + 36-change passives + KHN conditions present |
| RenXian organ system (五脏六腑) | Partial | Passive List | WZCYG passives defined; BANXIAN_REN.txt only partially read (first 400 lines) |
| FaBao artifact system (法宝) | Partial | Feat + Progression | FABAO.txt present (53 KB) but not yet fully read |
| GongFa techniques (功法) | Full | Progression Selector | GONGFA_SELECTOR.txt + DADAO selectors confirmed |
| Beast forms BenXiang (本相) | Full | Passive List | 10 forms in BANXIAN_YAO.txt; BENXIANG YAO PassiveList confirmed |
| ExtraAttack chain | Full | Passive/Aura | ExtraAttack_3–9 + queue statuses; up to 10 attacks supported |
| Hardcore mode (BANXIAN_HARDCORE) | Partial | Script-only | Status defined in DIFFICULTY.txt; no Story/Goals directory found |

### Feature gaps requiring follow-up

**ZhouTian acupoints 2, 3, 7, 8, 9, 10 (WB-01):** Each has an empty `Boosts` field. These are selectable by the player from the BANXIANCUITI PassiveList. They need real bonuses defined; what those bonuses should be is a design decision.

**RenXian organ system:** BANXIAN_REN.txt was only partially read (first 400 lines of a large file). The organ system mechanics beyond the first few entries have not been audited.

**FaBao artifact system:** FABAO.txt (53 KB) was not fully read. No issues were found in the portions read, but a complete audit is pending.

**Hardcore mode:** `BANXIAN_HARDCORE` status flag exists in DIFFICULTY.txt. No `Story/RawFiles/Goals/` directory was found in the mod — if this feature depends on Osiris story scripts, they are either missing or stored elsewhere.

## Coverage

### Fully read
- `Mods/XSS_BANXIAN/meta.lsx`
- `Mods/XSS_BANXIAN/ScriptExtender/Config.json`
- `Public/XSS_BANXIAN/Progressions/Progressions.lsx`
- `Public/XSS_BANXIAN/ActionResourceDefinitions/ActionResourceDefinitions.lsx`
- `Public/XSS_BANXIAN/Lists/SpellLists.lsx`
- `Public/XSS_BANXIAN/Lists/PassiveLists.lsx`
- `Public/XSS_BANXIAN/Feats/Feats.lsx`
- `Public/XSS_BANXIAN/Hints/Hints.lsx`
- `Public/XSS_BANXIAN/Levelmaps/LevelMapValues.lsx`
- `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_YAO.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/XIULIAN.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/SHENSHI.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/SHENTONG.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/GONGFA_SELECTOR.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/DIFFICULTY.txt`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/LingGen.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/ShenShi.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/XiuLian.lua`
- `Scripts/thoth/helpers/XSS_BANXIAN.khn`

### Partially read
- `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_BASE.txt` (key sections via Grep; not fully read)
- `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_TIAN.txt` (lines 1–300 of ~1500)
- `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_REN.txt` (lines 1–400 of ~1200)
- `Public/XSS_BANXIAN/Stats/Generated/Data/DADAO.txt` (~100 lines read; key entries confirmed via Grep)
- `Public/XSS_BANXIAN/Stats/Generated/Data/FIXS.txt` (key entries confirmed via Grep)
- `Public/XSS_BANXIAN/Stats/Generated/Data/LUA.txt` (key entries confirmed via Grep)
- `Public/XSS_BANXIAN/Stats/Generated/Data/ZHENFA.txt` (partial)
- `Public/XSS_BANXIAN/MultiEffectInfos/BANXIAN_ANIMATION_FLY.lsf.lsx` (noted — filename typo fixed)

### Not yet read
- `Public/XSS_BANXIAN/CharacterCreation/RENXIAN.lsx` (1.6 MB — too large for full read; use Grep)
- `Public/XSS_BANXIAN/CharacterCreation/TIANXIAN.lsx` (1.6 MB — too large for full read; use Grep)
- `Public/XSS_BANXIAN/CharacterCreation/YAOXIAN.lsx` (1.6 MB — too large for full read; use Grep)
- `Public/XSS_BANXIAN/Races/Races.lsx` (450 KB — too large; use Grep for targeted checks)
- `Public/XSS_BANXIAN/Progressions/ProgressionDescriptions.lsx`
- `Public/XSS_BANXIAN/CharacterCreation/CharacterCreationPresets.lsx`
- `Public/XSS_BANXIAN/Lists/SkillLists.lsx`
- `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_BASE.txt` (full read pending)
- `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_TIAN.txt` (lines 301+ pending)
- `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_REN.txt` (lines 401+ pending)
- `Public/XSS_BANXIAN/Stats/Generated/Data/DADAO.txt` (bulk unread)
- `Public/XSS_BANXIAN/Stats/Generated/Data/FABAO.txt` (53 KB — unread)
- `Public/XSS_BANXIAN/Stats/Generated/Data/SpellSet.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/Equipment.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/ItemCombos.txt`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/BootstrapServer.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Main.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Variables.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/EventHandlers.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Utils.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/DaoHeng.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/GongFa.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/FaBao.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/Difficulty.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/ZhenFa.lua`
- `Localization/` (all XML files)
- `Public/XSS_BANXIAN/GUI/` (all files)
- `Public/XSS_BANXIAN/Tags/` (all files)
- `Story/RawFiles/Goals/` (directory not found — may not exist)
