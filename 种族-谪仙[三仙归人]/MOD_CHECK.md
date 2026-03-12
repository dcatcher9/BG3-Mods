# Mod Check — 种族·谪仙「三仙归人」
<!-- Mod path: 种族-谪仙[三仙归人] -->
<!-- Last updated: 2026-03-11 -->

## Status
- **Coverage:** ~65 of ~107 files fully read, ~1 partially read, ~41 not yet read
- **Open issues:** 1 (0 red, 0 orange, 0 yellow, 0 blue, 1 white)
- **Fixed issues:** 30

## Open Issues

### 🔴 Bugs / Errors

*(none)*

### 🟠 Wrong Behavior

*(none)*

### 🟡 Logic / Consistency


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
- [x] **B-07** `Public/XSS_BANXIAN/Stats/Generated/Data/DADAO.txt:1694` `MODE_BANXIAN_DH_YI_TECHNICAL_Passive` — Implemented chaining split-arrow mechanic: passive applies `SIGNAL_DH_YI_SPLIT` on ranged bow hit → Lua handler (`DaoHeng.Yi.SplitArrow`) deals DaoHeng-year-scaled Force damage to nearby enemies via `YIDAO_SPLIT_HIT` status (stat-engine `DealDamage`, triggers secondary effects). Chains recursively with halving damage/probability, capped by depth=5, chance floor=10%, and hit-set dedup. *(fixed 2026-03-11)*
- [x] **WB-04** `Public/XSS_BANXIAN/Stats/Generated/Data/DANYAO.txt` `DR_QIFANHUO_DAN` — Localization confirms pill resets skill cooldowns via `DT_BASE_LONGREST`; empty `Boosts ""` intentionally overrides inherited `DamageReduction(All,Half)`. *(resolved 2026-03-11 — by design)*
- [x] **WB-07** `Public/XSS_BANXIAN/Stats/Generated/Data/DADAO.txt:640` `AURA_OF_YEHUO_TARGET` — `DealDamage(1)` → `DealDamage(1,Fire)`. *(fixed 2026-03-11)*
- [x] **L-03** `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/LingGen.lua:154` — Hardcoded UUID with inline comment pointing to Tags/. Named constant optional. *(resolved 2026-03-11 — acceptable with comment)*
- [x] **L-10** `Public/XSS_BANXIAN/Stats/Generated/Data/DADAO.txt:847` `Target_CallLightning_TianLei` — Removed duplicate `PositionEffect` line. *(fixed 2026-03-11)*
- [x] **T-06** `Public/XSS_BANXIAN/Stats/Generated/Data/DADAO.txt:1061–1067` `JIANDAO_YI_Passies_ZhenKi` — Deleted dead code passive. *(fixed 2026-03-11)*
- [x] **T-07** `Public/XSS_BANXIAN/Stats/Generated/Data/DADAO.txt:915,918,923` `BANXIAN_DH_JAIN_HEART` → `BANXIAN_DH_JIAN_HEART` (4 occurrences). *(fixed 2026-03-11)*
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
| DaoHeng 剑道 (JianDao) | Full | Passive/Interrupt | JianYi/JianXin/JianZhen/Parry/Dodge stances + 6 interrupts; ZhenJian Blast interrupt fully implemented |
| DaoHeng 羿道 (YiDao) | Full | Passive/Spell | Core, DuLing, ShuangFei, ZhuFeng spells + immortal-mode chaining split-arrow passive (signal→Lua→YIDAO_SPLIT_HIT) — all implemented |
| ZhenFa formation magic (阵法) | Full | Spell | 9-level JuLing core + 8 flags (Qian/Kun/Xun/Zhen/Kan/Li/Gen/Dui) + BUFF_1–9 + ZhenFa.lua |
| JinDan resource conversion (金丹术) | Full | Spell | 7 resource types + WarlockSpellSlot 1–6 tiers; MODESWITCH toggle present |
| YuanYing immortal core (元婴) | Full | Passive/Spell | Toggle passive, TECHNICAL heal/KiPoint regen, CONCENTRATION spell support; ShenshiPoint cost intentionally commented out |
| FSZMG YaoXian cultivation (梵圣真魔功) | Partial | Passive + Spell | Levels 1–9; Level9 capstone fixed; DevilForms ObjectSize capped |
| XiuLian qi absorption (修炼) | Full | Spell | Spell, Lua, LINGQI statuses consistent |
| BANXIANSHENTONG polymorphs (神通) | Full | Spell | 72/36-change passives; Rulebook rules confirmed; Base.lua transform logic present |
| RenXian organ system (五脏六腑) | Full | Passive List | BANXIAN_REN.txt fully read (2319 lines); all LingGen tiers, WZPLG, WZCYG, Xian/Sheng layers confirmed |
| FaBao artifact system (法宝) | Full | Feat + Progression | FABAO.txt fully read; 点金/吐火/淬火 + 8 BaoCai materials all implemented |
| FaBao 百脉锻宝诀 (BaiMai) | Full | Passive List | Slots 1–6 + A1/A2/S tier passives all defined; GongFa.lua confirms logic |
| GongFa techniques (功法) | Full | Progression Selector | GONGFA_SELECTOR.txt + DADAO selectors confirmed; GongFa.lua fully read |
| Beast forms BenXiang (本相) | Full | Passive List | 10 forms; WildShapeYaoXian Rulebook rule confirmed |
| ExtraAttack chain | Full | Passive/Aura | ExtraAttack_BanXian–9_BanXian + queue statuses; up to 10 attacks |
| DanYao alchemy system (丹药) | Full | Item + Passive | 35 pills defined; 35 ItemCombos recipes confirmed; drop/brew logic consistent |
| Hardcore mode (BANXIAN_HARDCORE) | Full | Script-only | `Difficulty.OnEnteredCombat_after` applies HARDCORE to NPCs; `Difficulty.HardCore.Start` runs full cultivation awakening |

### Feature gaps requiring follow-up

**HTBG supplemental-linggen spells (WB-06):** `BANXIAN_HTBG_H/T/J/S/M` all have empty `SpellProperties` and no Lua handler. Design intent unclear — possibly a placeholder for a future "replenish linggen" mechanic.


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
- `Public/XSS_BANXIAN/Tags/409e244f-5b8a-48f0-a51f-398b4efb6a01.lsx` (TIANXIAN tag)
- `Public/XSS_BANXIAN/Tags/409e244f-5b8a-48f0-a51f-398b4efb6b01.lsx` (RENXIAN tag)
- `Public/XSS_BANXIAN/Tags/b4241b97-8b51-4625-ae77-55dc09391bc0.lsx` (NOSOUL tag)
- `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_BASE.txt` (802 lines)
- `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_YAO.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_TIAN.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_REN.txt` (2319 lines)
- `Public/XSS_BANXIAN/Stats/Generated/Data/DADAO.txt` (1707 lines)
- `Public/XSS_BANXIAN/Stats/Generated/Data/XIULIAN.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/SHENSHI.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/SHENTONG.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/GONGFA_SELECTOR.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/DIFFICULTY.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/DANYAO.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/BOOK.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/FABAO.txt` (950 lines)
- `Public/XSS_BANXIAN/Stats/Generated/Data/ZHENFA.txt` (638 lines)
- `Public/XSS_BANXIAN/Stats/Generated/SpellSet.txt` (12 lines)
- `Public/XSS_BANXIAN/Stats/Generated/Equipment.txt` (12 lines)
- `Public/XSS_BANXIAN/Stats/Generated/ItemCombos.txt` (979 lines)
- `Public/XSS_BANXIAN/MultiEffectInfos/BANXIAN_ANIMATION_FLY.lsf.lsx`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/BootstrapServer.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Main.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Variables.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/EventHandlers.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Utils.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/Base.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/DanYao.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/LingGen.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/ShenShi.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/XiuLian.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/DaoHeng.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/GongFa.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/FaBao.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/Difficulty.lua`
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/ZhenFa.lua` (167 lines)
- `Scripts/thoth/helpers/XSS_BANXIAN.khn`

### Partially read
- `Public/XSS_BANXIAN/Stats/Generated/Data/FIXS.txt` (key entries via Grep)
- `Public/XSS_BANXIAN/Stats/Generated/Data/OVERRIDES.txt` (key entries via Grep)
- `Mods/XSS_BANXIAN/Localization/English/XSS_BANXIAN.xml` (first 100 lines; structure and key strings confirmed well-formed)

### Not yet read
- `Public/XSS_BANXIAN/CharacterCreation/RENXIAN.lsx` (1.6 MB — too large; use Grep)
- `Public/XSS_BANXIAN/CharacterCreation/TIANXIAN.lsx` (1.6 MB — too large; use Grep)
- `Public/XSS_BANXIAN/CharacterCreation/YAOXIAN.lsx` (1.6 MB — too large; use Grep)
- `Public/XSS_BANXIAN/Races/Races.lsx` (450 KB — too large; use Grep)
- `Public/XSS_BANXIAN/Progressions/ProgressionDescriptions.lsx`
- `Public/XSS_BANXIAN/CharacterCreationPresets/CharacterCreationPresets.lsx`
- `Public/XSS_BANXIAN/Lists/SkillLists.lsx`
- `Public/XSS_BANXIAN/GUI/newAtlas.lsx`
- `Story/RawFiles/Goals/` (directory not found — confirmed not present; Hardcore mode is Lua-only)
