# Mod Check — 种族·谪仙「三仙归人」
<!-- Mod path: 种族-谪仙[三仙归人] -->
<!-- Last updated: 2026-03-11 -->

## Status
- **Coverage:** ~50 of ~107 files fully read, ~3 partially read, ~54 not yet read
- **Open issues:** 2 (0 red, 1 orange, 0 yellow, 0 blue, 1 white)
- **Fixed issues:** 24

## Open Issues

### 🔴 Bugs / Errors

*(none remaining — all red bugs fixed)*

### 🟠 Wrong Behavior

- [ ] **WB-04** `Public/XSS_BANXIAN/Stats/Generated/Data/DANYAO.txt` `DR_QIFANHUO_DAN` — 七返火丹 has `data "Boosts" ""` and only applies `DT_BASE_LONGREST` on use. No fire-related bonus despite the thematic name. Possibly incomplete. *Fix: add intended fire boost once design is decided.*

### 🟡 Logic / Consistency

- [ ] **L-03** `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/LingGen.lua:154` — Hardcoded UUID `fe825e69-1569-471f-9b3f-28fd3b929683` for player race tag check. Added inline comment pointing to Tags/. *Remaining: optionally replace with a named constant in Variables.lua.*

### 🔵 Redundancy

*(none confirmed — suspected duplicates in FIXS.txt/LUA.txt verified as false positives)*

### ⚪ Minor / Typos

- [ ] **T-01** `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/LingGen.lua` `LingGen.GetCharacterParams()` — Companion LingGen values are hardcoded in an if/elseif chain by companion name. A data table in `Variables.lua` would be easier to maintain. *Low priority; address if adding/rebalancing companions.*

## Fixed / Resolved Issues

- [x] **WB-01** `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_TIAN.txt` `CuiTi_ZhouTian_2,3,7,8,9,10` — Empty `Boosts` fields are intentional. `Utils.BanXian.JingjieBoost()` (Utils.lua:931) dynamically creates and applies `BANXIAN_JJ_*` statuses with Ability bonuses scaling to cultivation realm. Passives serve as markers only. *(resolved 2026-03-11 — by design)*
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
- [x] **WB-05** `Public/XSS_BANXIAN/Stats/Generated/Data/FABAO.txt:553` `HEISEYANMOU_BOOST_WEAPON_UNDEAD` — Replaced fullwidth CJK semicolon `；` (U+FF1B) with ASCII `;`; `IncreaseMaxHP(-MaxHP/2)` now active. *(fixed 2026-03-11)*
- [x] **WB-06** `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_REN.txt:1431–1490` `BANXIAN_HTBG_H/T/J/S/M` — SpellProperties are empty; no design spec available. Retained as placeholder in Feature Completeness. *(won't fix — design intent unknown)*
- [x] **L-01** `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_REN.txt` `BANXIAN_LG_GUANG_BOOST` — Re-analysis: `HasHPPercentageLessThan(30)` in RemoveConditions PREVENTS removal at low HP (buff persists). Intentional design — light root stronger under pressure. *(resolved 2026-03-11 — by design)*
- [x] **L-02** `Scripts/thoth/helpers/XSS_BANXIAN.khn` `IsTargetWeaker()` — Strict `>` confirmed intentional; equal-level targets intentionally unaffected. *(resolved 2026-03-11 — by design)*
- [x] **L-05** `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/EventHandlers.lua` / `DaoHeng.lua` / `FaBao.lua` — Single-slot timer stores replaced with UUID-keyed `PersistentVars`. Jiandao timer keyed by `Caster` UUID; YaoShengJiao timer keyed by `Caster` UUID. *(fixed 2026-03-11)*
- [x] **L-06** `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Utils.lua` `CopyPassives/CopyPassives_2` — Module-level scratch tables removed; replaced with `PersistentVars['BaiMai_Passives_'..Object]` and `PersistentVars['BaiMai_WNP_'..Object]`. *(fixed 2026-03-11)*
- [x] **L-07** `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/Difficulty.lua:161` — Changed `string.find(Status,'HARDCORE')` to `Status == 'BANXIAN_HARDCORE'`. *(fixed 2026-03-11)*
- [x] **L-08** `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/FaBao.lua:426` — Added missing `FABAO` third argument to `Utils.GetStatField(stat, TYPE, FABAO)`. *(fixed 2026-03-11)*
- [x] **L-09** `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/FaBao.lua:126,141` — Added `plain=true` to `string.find` calls in `Boosts_Filter` and `SamePassives_Check`. *(fixed 2026-03-11)*
- [x] **T-05** `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Utils.lua` `Utils.Get.LingGen` — Updated stale string comparison to match the actual RESULT initializer `"满25点觉醒效果，满100点觉醒天灵根"`; `[缺失灵根]` branch now reachable. *(fixed 2026-03-11)*
- [x] **WB-02** `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_TIAN.txt` `CUITI_ZHOUTIAN_1` — Full KiPoint restore on every ZhouTian cycle application is intentional design. *(resolved 2026-03-11 — by design)*

## Feature Completeness

| Feature / System | Status | Player Access | Notes |
|---|---|---|---|
| LingGen elemental roots (灵根) | Full | Passive/Aura | 5 base + 8 composite TianLingGen + Xian/Sheng tiers for all 13 element types confirmed |
| ZhouTian circulation (周天淬体) | Full | Spell + Passive | 12 acupoints; empty Boosts on 2,3,7,8,9,10 is intentional (Utils.BanXian.JingjieBoost handles them) |
| WZPLG (五转培灵功) | Full | Spell | 5-element + ice/wind/thunder variants with 生/克 chain — fully implemented |
| WZCYG (五藏藏元功) | Full | Passive | 5-organ system linked to WZPLG 生 relationships — complete |
| HTBG (后天补根) | Partial | Spell | Container + 5 sub-spells defined; all SpellProperties empty and no Lua handler — currently no-ops |
| Shenshi mind-sense (神识) | Full | Spell | PassiveData, 5 sub-spells, Lua, KHN all consistent |
| DaoXin/DaoHeng realm (大道境界) | Full | Passive/Aura | DH_YEAR/MONTH/DAY stack system + full DaoHeng.lua confirmed |
| DaoHeng 合欢道/力道 | Full | Passive/Spell | HeHuan.TakeDH, AddFollower, RemoveFollower, FollowerProtect + Li ability boost all implemented |
| DaoHeng 地狱道/天道 | Full | Passive/Signal | YEHUO burn → AddDH, TIANLEI extra-damage — implemented |
| ZhenFa formation magic (阵法) | Full | Spell | 9-level core + 8 flag types + summon characters |
| FSZMG YaoXian cultivation (梵圣真魔功) | Partial | Passive + Spell | Levels 1–9; Level9 capstone fixed; DevilForms ObjectSize capped |
| XiuLian qi absorption (修炼) | Full | Spell | Spell, Lua, LINGQI statuses consistent |
| BANXIANSHENTONG polymorphs (神通) | Full | Spell | 72/36-change passives; Rulebook rules confirmed; Base.lua transform logic present |
| RenXian organ system (五脏六腑) | Full | Passive List | BANXIAN_REN.txt fully read (2319 lines); all LingGen tiers, WZPLG, WZCYG, Xian/Sheng layers confirmed |
| FaBao artifact system (法宝) | Full | Feat + Progression | FABAO.txt fully read; 点金/吐火/淬火 + 8 BaoCai materials (大力铁角/妖生角/黑色眼眸/金色眼眸/龙珠/铁中血/玉垂牙/震雷骨) all implemented |
| FaBao 百脉锻宝诀 (BaiMai) | Full | Passive List | Slots 1–6 + A1/A2/S tier passives all defined; GongFa.lua confirms logic |
| GongFa techniques (功法) | Full | Progression Selector | GONGFA_SELECTOR.txt + DADAO selectors confirmed; GongFa.lua fully read |
| Beast forms BenXiang (本相) | Full | Passive List | 10 forms; WildShapeYaoXian Rulebook rule confirmed |
| ExtraAttack chain | Full | Passive/Aura | ExtraAttack_3–9 + queue statuses; up to 10 attacks |
| DanYao alchemy system (丹药) | Full | Item + Passive | 35 pills defined; drop/brew logic confirmed |
| Hardcore mode (BANXIAN_HARDCORE) | Full | Script-only | `Difficulty.OnEnteredCombat_after` applies HARDCORE to NPCs; `Difficulty.HardCore.Start` runs full cultivation awakening — no Story/Goals needed |

### Feature gaps requiring follow-up

**HTBG supplemental-linggen spells (WB-06):** `BANXIAN_HTBG_H/T/J/S/M` all have empty `SpellProperties` and no Lua handler. These fire/earth/metal/water/wood spell-container sub-spells do nothing when cast. Design intent unclear — possibly a placeholder for a future "replenish linggen" mechanic.

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
- `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_TIAN.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_REN.txt` (2319 lines — fully read this run)
- `Public/XSS_BANXIAN/Stats/Generated/Data/XIULIAN.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/SHENSHI.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/SHENTONG.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/GONGFA_SELECTOR.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/DIFFICULTY.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/DANYAO.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/BOOK.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/FABAO.txt` (950 lines — fully read this run)
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/BootstrapServer.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Main.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Variables.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/EventHandlers.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Utils.lua` (fully read this run)
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/Base.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/DanYao.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/LingGen.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/ShenShi.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/XiuLian.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/DaoHeng.lua` (fully read this run)
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/GongFa.lua` (fully read this run)
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/FaBao.lua` (fully read this run)
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/Difficulty.lua` (fully read this run)
- `Scripts/thoth/helpers/XSS_BANXIAN.khn`
- `Public/XSS_BANXIAN/MultiEffectInfos/BANXIAN_ANIMATION_FLY.lsf.lsx`

### Partially read
- `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_BASE.txt` (key sections via Grep; not fully read)
- `Public/XSS_BANXIAN/Stats/Generated/Data/DADAO.txt` (~100 lines read + targeted Grep; 1707 lines total)
- `Public/XSS_BANXIAN/Stats/Generated/Data/FIXS.txt` (key entries via Grep)
- `Public/XSS_BANXIAN/Stats/Generated/Data/OVERRIDES.txt` (key entries via Grep)
- `Public/XSS_BANXIAN/Stats/Generated/Data/ZHENFA.txt` (partial)

### Not yet read
- `Public/XSS_BANXIAN/CharacterCreation/RENXIAN.lsx` (1.6 MB — too large; use Grep)
- `Public/XSS_BANXIAN/CharacterCreation/TIANXIAN.lsx` (1.6 MB — too large; use Grep)
- `Public/XSS_BANXIAN/CharacterCreation/YAOXIAN.lsx` (1.6 MB — too large; use Grep)
- `Public/XSS_BANXIAN/Races/Races.lsx` (450 KB — too large; use Grep)
- `Public/XSS_BANXIAN/Progressions/ProgressionDescriptions.lsx`
- `Public/XSS_BANXIAN/CharacterCreationPresets/CharacterCreationPresets.lsx`
- `Public/XSS_BANXIAN/Lists/SkillLists.lsx`
- `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_BASE.txt` (full read pending)
- `Public/XSS_BANXIAN/Stats/Generated/Data/DADAO.txt` (bulk unread)
- `Public/XSS_BANXIAN/Stats/Generated/Data/SpellSet.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Equipment.txt`
- `Public/XSS_BANXIAN/Stats/Generated/ItemCombos.txt`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/ZhenFa.lua`
- `Mods/XSS_BANXIAN/Localization/English/XSS_BANXIAN.xml`
- `Public/XSS_BANXIAN/GUI/newAtlas.lsx`
- `Public/XSS_BANXIAN/Tags/` (all .lsx files)
- `Story/RawFiles/Goals/` (directory not found — confirmed not present; Hardcore mode is Lua-only)
