# Mod Check — 种族·谪仙「三仙归人」
<!-- Mod path: 种族-谪仙[三仙归人] -->
<!-- Last updated: 2026-03-12 -->

## Status
- **Coverage:** ~75 of ~107 source files fully read, ~5 partially read (incl. RootTemplates promoted), ~26 not yet read (CC/VFX/asset LSX). All Lua/Stats/KHN/XML re-audited and cross-refs verified. Systematic nil-safety pattern search completed across all Lua files.
- **Open issues:** 0
- **Fixed issues:** 94

## Open Issues

### 🔴 Bugs / Errors
*(none)*

### 🟠 Wrong Behavior
*(none)*

### 🟡 Logic / Consistency
*(none)*

### 🔵 Redundancy
*(none)*

### ⚪ Minor / Typos
*(none)*

## Fixed / Resolved Issues
- [x] **B-17** `DaoHeng.lua:63` `Functors_Steal` — Added `if not objectEntity then return end` nil guard on `Ext.Entity.Get`. *(fixed 2026-03-12)*
- [x] **B-18** `DaoHeng.lua:73` `Functors_Steal` — Added `if status and` guard before accessing `.StatusType` on `Ext.Stats.Get` result. *(fixed 2026-03-12)*
- [x] **B-19** `DaoHeng.lua:75` `Functors_Steal` — Added `or 1` fallback on `GetStatusTurns` for stolen status Duration. *(fixed 2026-03-12)*
- [x] **B-20** `DaoHeng.lua:91` `Functors_Eat` — Added `if not foodEntity then return end` nil guard on `Ext.Entity.Get`. *(fixed 2026-03-12)*
- [x] **B-21** `FaBao.lua:66` `OpenChoiceBox_A` — Added `if not stat then return end` nil guard on `Ext.Stats.Get`. *(fixed 2026-03-12)*
- [x] **B-22** `FaBao.lua:106` `Boosts_Filter` — Added `if not stat then return true end` nil guard on `Ext.Stats.Get`. *(fixed 2026-03-12)*
- [x] **B-23** `FaBao.lua:131` `SamePassives_Check` — Added `if not stat then return true end` nil guard on `Ext.Stats.Get`. *(fixed 2026-03-12)*
- [x] **B-24** `FaBao.lua:147` `HiddenPassives_Check` — Added `if not stat then return true end` nil guard on `Ext.Stats.Get`. *(fixed 2026-03-12)*
- [x] **B-25** `FaBao.lua:165` `AddBoosts_AfterChoice` — Added `if not stat then return end` nil guard on `Ext.Stats.Get`. *(fixed 2026-03-12)*
- [x] **B-26** `FaBao.lua:286–287` `LianHua.AddBoosts` — Added `if not FABAO then return end` + `if not stat then return end` nil guards. *(fixed 2026-03-12)*
- [x] **B-27** `FaBao.lua:575,580` — Wrapped `GetStatusTurns` for `FIREBREATH_BURNING` in `(... or 0)` in two comparisons. *(fixed 2026-03-12)*
- [x] **B-28** `GongFa.lua:53` `ZhouTianRestoreResources` — Added `if not entity then return end` nil guard on `Ext.Entity.Get`. *(fixed 2026-03-12)*
- [x] **B-29** `LingGen.lua:334` `HunDun_ShortRest` — Added `if not entity then return end` nil guard on `Ext.Entity.Get`. *(fixed 2026-03-12)*
- [x] **WB-23** `Utils.lua:440` `YeHuoSource` — Deepened nil guard to `if not entity or not entity.ServerCharacter or not entity.ServerCharacter.StatusManager`. *(fixed 2026-03-12)*
- [x] **WB-24** `Utils.lua:444` `YeHuoSource` — Added `and Status.Cause and Status.Cause.Uuid` guard before accessing `.EntityUuid`. *(fixed 2026-03-12)*
- [x] **WB-25** `Utils.lua:773–778` `CopyPassives` — Cached `Ext.Entity.Get` result; added `cpEntity and cpEntity.PassiveContainer` nil guard. *(fixed 2026-03-12)*
- [x] **WB-26** `Utils.lua:852–855` `CopyStatus` — Cached `Ext.Entity.Get` result; added `csEntity and csEntity:GetComponent("StatusContainer")` nil guard. *(fixed 2026-03-12)*
- [x] **WB-27** `DaoHeng.lua:297` — Added `local faction = Osi.GetFaction(Object); if faction then` guard before `ClearIndividualRelation`. *(fixed 2026-03-12)*
- [x] **B-15** `Utils.lua:848` `CopyStatus()` — Added `and stat` nil guard on `Ext.Stats.Get` result before accessing `.StatusType`. *(fixed 2026-03-12)*
- [x] **B-16** `Base.lua:184` `Transform` — Added `or -1` fallback to `GetStatusTurns` for status copy Duration. *(fixed 2026-03-12)*
- [x] **WB-19** `Utils.lua:614` — Wrapped `stat.Rarity` assignment in nil guard. *(fixed 2026-03-12)*
- [x] **WB-20** `Utils.lua:209–211` — Added `or false` defaults to PersistentVars boolean assignments in `CharacterChangeCancel.Equipable`. *(fixed 2026-03-12)*
- [x] **WB-21** `Base.lua:70` — Added `if not entity then return end` guard in `DualAttack_Before`. *(fixed 2026-03-12)*
- [x] **WB-22** `Utils.lua:805` — Added entity + PassiveContainer nil guard in `CopyPassives_2`. *(fixed 2026-03-12)*
- [x] **L-18** `EventHandlers.lua:69–76` — Refactored LingGen two-phase timer to use per-character keyed PersistentVars and per-character timer names, eliminating race condition. *(fixed 2026-03-12)*
- [x] **L-19** `DanYao.lua:94` — Added `or 0` fallback to `GetStatusTurns` for `BANXIAN_DH_YEAR`. *(fixed 2026-03-12)*
- [x] **T-11** `XSS_BANXIAN.xml:1059` — 获得获得→获得. *(fixed 2026-03-12)*
- [x] **T-12** `XSS_BANXIAN.xml:279` — 该等该→等同该. *(fixed 2026-03-12)*
- [x] **T-13** `XSS_BANXIAN.xml:831` — 的的→的. *(fixed 2026-03-12)*
- [x] **B-13** `FaBao.lua:228` — Added `or 0` fallback to `GetStatusTurns` for `BANXIAN_FABAO_FIREBREATH_BURNING`. *(fixed 2026-03-12)*
- [x] **B-14** `XSS_BANXIAN.khn:36` — Changed `Tagged(...) == 1` to `Tagged(...).Result` so soulless/construct/undead auto-fail DC=99 now fires. *(fixed 2026-03-12)*
- [x] **WB-16** `XSS_BANXIAN.khn:47,55` — Added `context.Source` nil+validity guard to `IsTargetHPLess()` and `TargetHPLessThanYourStrength()`. *(fixed 2026-03-12)*
- [x] **WB-17** `XSS_BANXIAN.khn:542` — Added `context.Source` nil+validity guard to `CanShenshiCheck()`. *(fixed 2026-03-12)*
- [x] **WB-18** `XSS_BANXIAN.xml:503` — Removed stray `</LSTag>`, added missing `、` separator between 恐惧 and 震慑. *(fixed 2026-03-12)*
- [x] **L-17** `DaoHeng.lua:225–241` — Animation backup keyed per spell ID (`'Jiandao_Projectile_AnimationBackup_'..ID`) instead of single global key. *(fixed 2026-03-12)*
- [x] **R-05** `DADAO.txt:984,989` — Renamed `JIANDAO_YI_Passies_Damaged` → `JIANDAO_YI_Passives_Damaged`. *(fixed 2026-03-12)*
- [x] **R-06** `FABAO.txt:86,120` — Removed stray `; ;` double-semicolons in SpellProperties. *(fixed 2026-03-12)*
- [x] **R-07** `LingGen.lua:171` — Removed empty `else` block. *(fixed 2026-03-12)*
- [x] **T-08** `XSS_BANXIAN.xml:389` — 路劲→路径. *(fixed 2026-03-12)*
- [x] **T-09** `XSS_BANXIAN.xml:596,643` — 领域→领悟, 获得获得→获得. *(fixed 2026-03-12)*
- [x] **T-10** `XSS_BANXIAN.xml` guide text — Fixed 10 typos: 掷般→掷骰, 回湖→回溯, double comma, 恢真→恢复, 御后→服用后, 葛草→葛蕈, 益气育→益气膏, 千年人→千年人参, 恢眞→恢复, 提两点→提升2点. *(fixed 2026-03-12)*
- [x] **L-15** `LingGen.lua:65,275–296` — Added consistent 5-arg `Osi.ApplyStatus()` calls. *(fixed 2026-03-12)*
- [x] **T-01** `LingGen.lua` + `Variables.lua` — Companion LingGen data extracted to `Variables.Constants.CompanionLingGen` table; if/elseif chain replaced with table lookup. *(fixed 2026-03-12)*
- [x] **B-08** `BANXIAN_TIAN.txt` + `BANXIAN_YAO.txt` + `DANYAO.txt` — `BanXiangHP` → `BanXianHP` (13 occurrences). *(fixed 2026-03-12)*
- [x] **B-09** `DADAO.txt:785` — `CritcalBanXianDice` → `CriticalBanXianDice`. *(fixed 2026-03-12)*
- [x] **B-10** `FABAO.txt:265` — `TIENIU_WEAPON_APBONUS` → `TIENIU_BOOSTS_APBONUS`. *(fixed 2026-03-12)*
- [x] **B-11** `DANYAO.txt:965` — Duplicate `DR_WenLiSan` renamed to `DR_WENLI_SAN`. *(fixed 2026-03-12)*
- [x] **B-12** `XiuLian.lua:38–39` — Added `or 0` fallback to all 5 `GetStatusTurns` calls. *(fixed 2026-03-12)*
- [x] **WB-08** `DaoHeng.lua:66` — Snapshot status IDs before `pairs()` iteration in `Functors_Steal`. *(fixed 2026-03-12)*
- [x] **WB-09** `DaoHeng.lua:93` — Snapshot status IDs before `pairs()` iteration in `Functors_Eat`. *(fixed 2026-03-12)*
- [x] **WB-10** `FaBao.lua:554` — `Weight*0.1` → `math.floor(Weight*0.1)`. *(fixed 2026-03-12)*
- [x] **WB-11** `FaBao.lua:572` — Added nil check on `GetThreshold()` return. *(fixed 2026-03-12)*
- [x] **WB-12** `Utils.lua:517` — Added nil guard on `Ext.Entity.Get()` in `GetEntityWeight`. *(fixed 2026-03-12)*
- [x] **WB-13** `Base.lua:134` — Faction PersistentVars keyed by Caster UUID. *(fixed 2026-03-12)*
- [x] **WB-14** `Base.lua:151,172` — Added entity + component nil guards in `Transform`. *(fixed 2026-03-12)*
- [x] **WB-15** `FABAO.txt:86,120` — Added missing `GHOST_FENJUE` and `PURPLE` statuses to non-Tian fire tier. *(fixed 2026-03-12)*
- [x] **L-11** `BANXIAN_TIAN.txt:132` — `BoostCondition` → `BoostConditions`. *(fixed 2026-03-12)*
- [x] **L-12** `BANXIAN_YAO.txt:130` — Added `Properties "Highlighted"` to `MoQiao3`. *(fixed 2026-03-12)*
- [x] **L-13** `DADAO.txt:1262` — Reordered `type` before `using`. *(fixed 2026-03-12)*
- [x] **L-14** `XiuLian.lua:19–20` — Added `math.floor()` to ability modifier division. *(fixed 2026-03-12)*
- [x] **L-16** `DaoHeng.lua:225` — Added nil guard on animation backup to prevent overwrite. *(fixed 2026-03-12)*
- [x] **R-02** `BANXIAN_REN.txt:1035,1049` — Removed duplicate `SoundLoop`/`SoundStop` fields. *(fixed 2026-03-12)*
- [x] **R-03** `XSS_BANXIAN.khn:149` — Removed dead code `DHMARKMoreThanYEAR()`. *(fixed 2026-03-12)*
- [x] **R-04** `DanYao.lua:158` — Removed empty `else` block. *(fixed 2026-03-12)*
- [x] **WB-01** `BANXIAN_TIAN.txt` `CuiTi_ZhouTian_2,3,7,8,9,10` — Empty `Boosts` fields intentional; `Utils.BanXian.JingjieBoost()` dynamically creates and applies `BANXIAN_JJ_*` statuses with Ability bonuses scaling to realm. *(by design)*
- [x] **B-01** `LingGen.lua:225` — `math.random()` called with float arguments (crash in Lua 5.3+). *(fixed)*
- [x] **B-02** `BANXIAN_TIAN.txt:176` `CuiTi_ZhouTian_6` — `DamageReduction` used raw `BanXianDice` instead of `LevelMapValue(BanXianDice)`. *(fixed)*
- [x] **B-03** `BANXIAN_YAO.txt` `BANXIAN_DEVILFORMS_9` — `ObjectSize(+9)` exceeded game maximum; capped to `ObjectSize(+6)`. *(fixed)*
- [x] **B-04** `SHENTONG.txt` `BANXIAN_CREATUREBAG` — `StatusPropertyFlags` commented out; status showed overhead/combat-log spam. *(fixed)*
- [x] **B-05** `BANXIAN_YAO.txt` `BANXIAN_FSZMG_Level9` — `TickType`/`TickFunctors` commented out (capstone self-heal not firing); implemented via `StatsFunctorContext "OnTurn"`. *(fixed)*
- [x] **B-06** `MultiEffectInfos/BANXAIN_ANIMATION_FLY.lsf.lsx` — Filename typo `BANXAIN` → `BANXIAN`; fly animation would not load. *(fixed)*
- [x] **B-07** `DADAO.txt:1694` `MODE_BANXIAN_DH_YI_TECHNICAL_Passive` — Implemented split-arrow mechanic: passive applies `SIGNAL_DH_YI_SPLIT` on ranged bow hit → Lua handler deals DaoHeng-scaled Force damage via `YIDAO_SPLIT_HIT`. Chains recursively with halving damage/probability, capped by depth=5. *(fixed)*
- [x] **BL-01** `XSS_BANXIAN.khn:62` `BLEEDINGPercentageMoreThan()` — Compared bleeding duration (turns) against `MaxHP * value / 100` (dimensional mismatch); fixed to compare duration directly against `value`. *(fixed)*
- [x] **WB-02** `BANXIAN_TIAN.txt` `CUITI_ZHOUTIAN_1` — Full KiPoint restore on every ZhouTian cycle is intentional design. *(by design)*
- [x] **WB-03** `DanYao.lua` `WuYunDan()` — Variable `r` computed but never used; upgrade always succeeded. Added `LG_TZ==0` branch and probability gate. *(fixed)*
- [x] **WB-04** `DANYAO.txt` `DR_QIFANHUO_DAN` — Empty `Boosts ""` intentionally overrides inherited `DamageReduction(All,Half)`. *(by design)*
- [x] **WB-05** `FABAO.txt:553` `HEISEYANMOU_BOOST_WEAPON_UNDEAD` — Fullwidth semicolon `；` (U+FF1B) replaced with ASCII `;`; `IncreaseMaxHP(-MaxHP/2)` now active. *(fixed)*
- [x] **WB-06** `BANXIAN_REN.txt:1431–1490` `BANXIAN_HTBG_H/T/J/S/M` — SpellProperties empty; no design spec. Retained as placeholder. *(won't fix — design intent unknown)*
- [x] **WB-07** `DADAO.txt:640` `AURA_OF_YEHUO_TARGET` — `DealDamage(1)` → `DealDamage(1,Fire)`. *(fixed)*
- [x] **L-01** `BANXIAN_REN.txt` `BANXIAN_LG_GUANG_BOOST` — `HasHPPercentageLessThan(30)` in RemoveConditions prevents removal at low HP (buff persists); intentional — light root stronger under pressure. *(by design)*
- [x] **L-02** `XSS_BANXIAN.khn` `IsTargetWeaker()` — Strict `>` confirmed intentional; equal-level targets unaffected by design. *(by design)*
- [x] **L-03** `LingGen.lua:154` — Hardcoded UUID with inline comment pointing to Tags/. Named constant optional. *(acceptable with comment)*
- [x] **L-04** `Base.lua:81` — Added nil guard on `Resources[BonusActionPoint_UUID][1]` before accessing `.Amount`. *(fixed)*
- [x] **L-05** `EventHandlers.lua` / `DaoHeng.lua` / `FaBao.lua` — Single-slot timer stores replaced with UUID-keyed `PersistentVars`. *(fixed)*
- [x] **L-06** `Utils.lua` `CopyPassives/CopyPassives_2` — Module-level scratch tables removed; replaced with `PersistentVars`-keyed storage. *(fixed)*
- [x] **L-07** `Difficulty.lua:161` — `string.find(Status,'HARDCORE')` → `Status == 'BANXIAN_HARDCORE'`. *(fixed)*
- [x] **L-08** `FaBao.lua:426` — Added missing `FABAO` third argument to `Utils.GetStatField(stat, TYPE, FABAO)`. *(fixed)*
- [x] **L-09** `FaBao.lua:126,141` — Added `plain=true` to `string.find` calls in `Boosts_Filter` and `SamePassives_Check`. *(fixed)*
- [x] **L-10** `DADAO.txt:847` `Target_CallLightning_TianLei` — Removed duplicate `PositionEffect` line. *(fixed)*
- [x] **T-02** `LUA.txt` — Renamed to `OVERRIDES.txt`. *(fixed)*
- [x] **T-03** `BANXIAN_YAO.txt:757` `BANXIAN_Yao_RedDragon` — Copy-pasted Wolf comment corrected to describe RedDragon. *(fixed)*
- [x] **T-04** `DANYAO.txt:622` `DT_TAIYI_XIAOHUANDAN` — StackId renamed from `DT_TaiYiXiaoHuanDan` to `DT_TAIYI_XIAOHUANDAN` for consistency. *(fixed)*
- [x] **T-05** `Utils.lua` `Utils.Get.LingGen` — Updated stale string comparison to match actual RESULT initializer; `[缺失灵根]` branch now reachable. *(fixed)*
- [x] **T-06** `DADAO.txt:1061–1067` `JIANDAO_YI_Passies_ZhenKi` — Deleted dead code passive. *(fixed)*
- [x] **T-07** `DADAO.txt:915,918,923` `BANXIAN_DH_JAIN_HEART` → `BANXIAN_DH_JIAN_HEART` (4 occurrences). *(fixed)*

## Feature Completeness

| Feature / System | Status | Player Access | Notes |
|---|---|---|---|
| LingGen 灵根 | Full | Passive/Aura | 5 base + 8 composite TianLingGen + Xian/Sheng tiers for all 13 types |
| ZhouTian 周天淬体 | Full | Spell + Passive | 12 acupoints; empty Boosts on 2,3,7,8,9,10 intentional (JingjieBoost handles them) |
| WZPLG 五转培灵功 | Full | Spell | 5-element + ice/wind/thunder variants with 生/克 chain |
| WZCYG 五藏藏元功 | Full | Passive | 5-organ system linked to WZPLG 生 relationships |
| HTBG 后天补根 | Partial | Spell | Container + 5 sub-spells defined; all SpellProperties empty, no Lua handler — no-ops |
| Shenshi 神识 | Full | Spell | PassiveData, 5 sub-spells, Lua, KHN all consistent |
| DaoXin/DaoHeng 大道境界 | Full | Passive/Aura | DH_YEAR/MONTH/DAY stack system + DaoHeng.lua |
| DaoHeng 合欢道/力道 | Full | Passive/Spell | HeHuan follower system + Li ability boost |
| DaoHeng 地狱道/天道 | Full | Passive/Signal | YEHUO burn → AddDH, TIANLEI extra-damage |
| DaoHeng 剑道 | Full | Passive/Interrupt | JianYi/JianXin/JianZhen stances + 6 interrupts + ZhenJian Blast |
| DaoHeng 羿道 | Full | Passive/Spell | DuLing, ShuangFei, ZhuFeng spells + split-arrow chaining |
| ZhenFa 阵法 | Full | Spell | 9-level JuLing core + 8 trigram flags + BUFF_1–9 |
| JinDan 金丹术 | Full | Spell | 7 resource types + WarlockSpellSlot 1–6; MODESWITCH toggle |
| YuanYing 元婴 | Full | Passive/Spell | Toggle passive, TECHNICAL heal/KiPoint regen, CONCENTRATION spell |
| FSZMG 梵圣真魔功 | Partial | Passive + Spell | Levels 1–9; Level9 capstone fixed; DevilForms ObjectSize capped |
| XiuLian 修炼 | Full | Spell | Spell + Lua + LINGQI statuses consistent |
| SHENTONG 神通 | Full | Spell | 72/36-change polymorphs; Rulebook rules confirmed; Base.lua transform logic |
| RenXian 五脏六腑 | Full | Passive List | All LingGen tiers, WZPLG, WZCYG, Xian/Sheng layers confirmed |
| FaBao 法宝 | Full | Feat + Progression | 点金/吐火/淬火 + 8 BaoCai materials |
| FaBao 百脉锻宝诀 | Full | Passive List | Slots 1–6 + A1/A2/S tier passives; GongFa.lua logic confirmed |
| GongFa 功法 | Full | Progression Selector | GONGFA_SELECTOR.txt + DADAO selectors + GongFa.lua |
| BenXiang 本相 | Full | Passive List | 10 beast forms; WildShapeYaoXian Rulebook rule |
| ExtraAttack 连击 | Full | Passive/Aura | ExtraAttack_BanXian–9_BanXian + queue statuses; up to 10 attacks |
| DanYao 丹药 | Full | Item + Passive | 35 pills; 35 ItemCombos recipes; drop/brew logic consistent |
| Hardcore 仙人模式 | Full | Script-only | HARDCORE applied to NPCs on combat enter; full cultivation awakening |

### Feature gaps
- **HTBG 后天补根 (WB-06):** 5 sub-spells have empty `SpellProperties` and no Lua handler — currently no-ops. Design intent unclear; possibly a future "replenish linggen" mechanic.
- **FSZMG 梵圣真魔功:** Level9 capstone and DevilForms fixed, but overall system still has incomplete ability descriptions.
- **CaiDao 财道:** Localization stubs exist (lines 365-369 in XML) with empty descriptions but no stat entries, Lua handler, or code references. Planned but unimplemented DaDao path.
- **EGui 饿鬼道 localization:** Text says "(暂未开发！)" but `MODE_BANXIAN_DH_EGUI_TECHNICAL` + passive are implemented. Localization is stale.

## Coverage

### Fully read
- `Mods/XSS_BANXIAN/meta.lsx`
- `Mods/XSS_BANXIAN/ScriptExtender/Config.json`
- `Mods/XSS_BANXIAN/Localization/zhexian_Books.lsx`
- `Mods/XSS_BANXIAN/Localization/English/XSS_BANXIAN.xml` *(promoted: fully read this run)*
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
- `Mods/XSS_BANXIAN/ScriptExtender/Lua/Server/Modules/Systems/ZhenFa.lua`
- `Scripts/thoth/helpers/XSS_BANXIAN.khn`
- `Public/XSS_BANXIAN/Progressions/Progressions.lsx`
- `Public/XSS_BANXIAN/Progressions/ProgressionDescriptions.lsx`
- `Public/XSS_BANXIAN/ActionResourceDefinitions/ActionResourceDefinitions.lsx`
- `Public/XSS_BANXIAN/Lists/SpellLists.lsx`
- `Public/XSS_BANXIAN/Lists/PassiveLists.lsx`
- `Public/XSS_BANXIAN/Lists/SkillLists.lsx` (empty placeholder)
- `Public/XSS_BANXIAN/Feats/Feats.lsx`
- `Public/XSS_BANXIAN/Feats/FeatDescriptions.lsx`
- `Public/XSS_BANXIAN/ErrorDescriptions/ConditionErrors.lsx`
- `Public/XSS_BANXIAN/Hints/Hints.lsx`
- `Public/XSS_BANXIAN/Levelmaps/LevelMapValues.lsx`
- `Public/XSS_BANXIAN/Shapeshift/Rulebook.lsx`
- `Public/XSS_BANXIAN/CharacterCreationPresets/CharacterCreationPresets.lsx`
- `Public/XSS_BANXIAN/GUI/newAtlas.lsx`
- `Public/XSS_BANXIAN/Tags/409e244f-5b8a-48f0-a51f-398b4efb6a01.lsx` (TIANXIAN)
- `Public/XSS_BANXIAN/Tags/409e244f-5b8a-48f0-a51f-398b4efb6b01.lsx` (RENXIAN)
- `Public/XSS_BANXIAN/Tags/b4241b97-8b51-4625-ae77-55dc09391bc0.lsx` (NOSOUL)
- `Public/XSS_BANXIAN/MultiEffectInfos/BANXIAN_ANIMATION_FLY.lsf.lsx`
- `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_BASE.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_YAO.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_TIAN.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/BANXIAN_REN.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/DADAO.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/XIULIAN.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/SHENSHI.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/SHENTONG.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/GONGFA_SELECTOR.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/DIFFICULTY.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/DANYAO.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/BOOK.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/FABAO.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/ZHENFA.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/FIXS.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Data/OVERRIDES.txt`
- `Public/XSS_BANXIAN/Stats/Generated/SpellSet.txt`
- `Public/XSS_BANXIAN/Stats/Generated/Equipment.txt`
- `Public/XSS_BANXIAN/Stats/Generated/ItemCombos.txt`

### Partially read
- `Public/XSS_BANXIAN/Races/Races.lsx` (7069 lines; structure + UUID cross-refs verified, no duplicate race UUIDs, cosmetic UUID sharing is correct)
- `Public/XSS_BANXIAN/CharacterCreation/RENXIAN.lsx` (19934 lines; UUID cross-refs verified)
- `Public/XSS_BANXIAN/CharacterCreation/TIANXIAN.lsx` (19934 lines; UUID cross-refs verified)
- `Public/XSS_BANXIAN/CharacterCreation/YAOXIAN.lsx` (19934 lines; UUID cross-refs verified)
- `Public/XSS_BANXIAN/RootTemplates/_merged.lsf.lsx` (2372 lines; 96 GameObjects, no duplicate MapKeys, race UUID refs verified)

### Not yet read
- `Public/XSS_BANXIAN/CharacterCreation/CharacterCreationAppearanceVisuals.lsx` (59784 lines — visual presets; low priority)
- `Public/XSS_BANXIAN/Content/` — asset/visual LSX files (6 files; low priority)
- `Public/XSS_BANXIAN/MultiEffectInfos/` — remaining VFX info files (~20 files; no logic)
- `Public/XSS_BANXIAN/Assets/Effects/` — effect bank LSX files (~12 files; visual/particle data)
- `Public/Game/GUI/metadata.lsx` / `metadata.lsf.lsx` (texture metadata)
- `Mods/XSS_BANXIAN/Localization/zhexian_Books.lsf.lsx` (compiled copy)
- `.lsf.lsx` duplicates of already-read `.lsx` files (compiled copies)
- `Story/RawFiles/Goals/` (not present; Hardcore mode is Lua-only)
