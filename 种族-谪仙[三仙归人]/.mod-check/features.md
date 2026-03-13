# Features — 种族·谪仙「三仙归人」
<!-- Last updated: 2026-03-12 -->

## Feature Table

| Feature / System | Completeness | Player Access | Key Files |
|---|---|---|---|
| LingGen 灵根 | Full | Passive/Aura | BANXIAN_REN.txt, LingGen.lua, Variables.lua |
| ZhouTian 周天淬体 | Full | Spell + Passive | BANXIAN_TIAN.txt, EventHandlers.lua |
| WZPLG 五转培灵功 | Full | Spell | BANXIAN_REN.txt, SpellLists.lsx |
| WZCYG 五藏藏元功 | Full | Passive | BANXIAN_REN.txt |
| HTBG 后天补根 | Stub | Spell | BANXIAN_REN.txt (empty SpellProperties) |
| Shenshi 神识 | Full | Spell | SHENSHI.txt, ShenShi.lua, XSS_BANXIAN.khn |
| DaoHeng 大道境界 | Full | Passive/Aura | DADAO.txt, DaoHeng.lua |
| DaoHeng 合欢道 | Full | Passive/Spell | DADAO.txt, DaoHeng.lua (HeHuan follower) |
| DaoHeng 力道 | Full | Passive | DADAO.txt |
| DaoHeng 地狱道 | Full | Passive/Signal | DADAO.txt, DaoHeng.lua (YEHUO burn → AddDH) |
| DaoHeng 天道 | Full | Passive/Signal | DADAO.txt, DaoHeng.lua (TIANLEI damage) |
| DaoHeng 剑道 | Full | Passive/Interrupt | DADAO.txt (JianYi/JianXin/JianZhen stances + 6 interrupts) |
| DaoHeng 羿道 | Full | Passive/Spell | DADAO.txt, DaoHeng.lua (DuLing/ShuangFei/ZhuFeng + split-arrow) |
| ZhenFa 阵法 | Full | Spell | ZHENFA.txt, ZhenFa.lua |
| JinDan 金丹术 | Full | Spell | BANXIAN_BASE.txt (7 resource types + WarlockSpellSlot) |
| YuanYing 元婴 | Full | Passive/Spell | BANXIAN_BASE.txt, passive toggle + CONCENTRATION |
| FSZMG 梵圣真魔功 | Partial | Passive + Spell | BANXIAN_YAO.txt (Levels 1-9 + DevilForms) |
| XiuLian 修炼 | Full | Spell | XIULIAN.txt, XiuLian.lua |
| SHENTONG 神通 | Full | Spell | SHENTONG.txt, Base.lua (72/36-change polymorphs) |
| RenXian 五脏六腑 | Full | Passive List | BANXIAN_REN.txt (all LingGen tiers) |
| FaBao 法宝 | Full | Feat + Progression | FABAO.txt, FaBao.lua |
| FaBao 百脉锻宝诀 | Full | Passive List | FABAO.txt, GongFa.lua |
| GongFa 功法 | Full | Progression Selector | GONGFA_SELECTOR.txt, GongFa.lua |
| BenXiang 本相 | Full | Passive List | BANXIAN_YAO.txt (10 beast forms) |
| ExtraAttack 连击 | Full | Passive/Aura | BANXIAN_BASE.txt (up to 10 attacks) |
| DanYao 丹药 | Full | Item + Passive | DANYAO.txt, DanYao.lua, ItemCombos.txt |
| Hardcore 仙人模式 | Full | Script-only | Difficulty.lua (NPC cultivation on combat) |

## Feature Details

### LingGen 灵根 (Spiritual Root)
**What**: Assigns elemental spiritual roots determining cultivation affinity.
**Chain**: Character Creation → LingGen.lua assigns random roots → `BANXIAN_LG_*` statuses applied → PassiveData boosts in BANXIAN_REN.txt activate based on root type
**Access**: Automatic on character creation; companions get predefined roots via `Variables.Constants.CompanionLingGen`
**Completeness**: Full — 5 base elements (金木水火土) + 8 composite TianLingGen + Xian/Sheng tiers for all 13 types
**Notes**: `math.random` calls use integer args (fixed from float bug). Root assignment uses weighted probability in XiuLian.lua.

### ZhouTian 周天淬体 (Acupoint Tempering)
**What**: 12-acupoint cultivation cycle that grants progressive boosts.
**Chain**: Spell cast → `CuiTi_ZhouTian_1..12` PassiveData in BANXIAN_TIAN.txt → some with direct Boosts, others use `Utils.BanXian.JingjieBoost()` dynamically → EventHandlers.lua manages long-rest progression
**Access**: Spell (manual activation) + Passive effects
**Completeness**: Full — empty Boosts on acupoints 2,3,7,8,9,10 are intentional (JingjieBoost handles them dynamically)

### WZPLG 五转培灵功 (Five-Turn Spirit Cultivation)
**What**: 5-element + ice/wind/thunder spell variants with 生/克 (creation/destruction) elemental chains.
**Chain**: SpellLists.lsx → Spells in BANXIAN_REN.txt → status effects with elemental interactions
**Access**: Spell
**Completeness**: Full

### WZCYG 五藏藏元功 (Five-Organ Yuan Storage)
**What**: 5-organ passive system linked to WZPLG elemental relationships.
**Chain**: PassiveData in BANXIAN_REN.txt → boosts linked to WZPLG 生 relationships
**Access**: Passive
**Completeness**: Full

### HTBG 后天补根 (Postnatal Root Replenishment)
**What**: Intended to let players replenish spiritual roots.
**Chain**: Container spell + 5 sub-spells defined in BANXIAN_REN.txt, but all SpellProperties are empty and no Lua handler exists
**Access**: Spell (non-functional)
**Completeness**: Stub — design intent unclear, possibly future mechanic

### DaoHeng 大道境界 (Great Dao Realm System)
**What**: Core progression system tracking cultivation level via DH_YEAR/MONTH/DAY status stacks.
**Chain**: Various triggers → DaoHeng.lua manages DH_DAY accumulation → day→month→year conversion → realm thresholds in Variables.lua → JingjieBoost applies ability bonuses
**Access**: Passive/Aura (automatic accumulation)
**Completeness**: Full
**Notes**: DaoXinStable/DaoXinUnStable conditions check `BANXIAN_DH_HEART_UNSTABLE` which is never applied — intentional placeholder for future "道心不稳" mechanic.

### DaoHeng 地狱道 (Hell Path)
**What**: Killing BURNING_YEHUO targets grants DaoHeng to the fire source.
**Chain**: DYING status on YEHUO-burning target → DaoHeng.OnStatusApplied_before → Utils.Get.YeHuoSource finds source → DiYu.AddDH transfers burn duration as DH days
**Access**: Passive/Signal
**Completeness**: Full

### DaoHeng 剑道 (Sword Path)
**What**: 3 sword stances (JianYi/JianXin/JianZhen) with 6 interrupts + ZhenJian Blast.
**Chain**: MODE_BANXIAN_DH_JIAN_TECHNICAL toggle → stance passives in DADAO.txt → interrupt conditions in XSS_BANXIAN.khn → animation overrides in DaoHeng.lua
**Access**: Passive/Interrupt
**Completeness**: Full

### DaoHeng 羿道 (Archer Path)
**What**: DuLing, ShuangFei, ZhuFeng spells + recursive split-arrow chaining.
**Chain**: SIGNAL_DH_YI_SPLIT on ranged hit → DaoHeng.Yi.SplitArrow in Lua → deals DaoHeng-scaled Force damage → chains recursively with halving damage/probability, capped at depth=5
**Access**: Passive/Spell
**Completeness**: Full

### FaBao 法宝 (Magic Weapons)
**What**: Weapon refinement system with material choices and progressive enhancement.
**Chain**: Feat selection → FABAO.txt passives → FaBao.lua manages stat modification + LianHua refinement process → PersistentVars tracks per-weapon state → OnEquipped restores stats
**Access**: Feat + Progression
**Completeness**: Full — 点金/吐火/淬火 abilities + 8 BaoCai materials

### DanYao 丹药 (Alchemy)
**What**: 35 pills with crafting recipes, probability-based brewing, and realm-gated effects.
**Chain**: ItemCombos.txt recipes → DANYAO.txt status effects → DanYao.lua handles WuYunDan upgrade logic and probability gates
**Access**: Item + Passive
**Completeness**: Full — 35 pills, 35 recipes

### ExtraAttack 连击 (Multi-Attack)
**What**: Extra attack scaling system up to 10 attacks per turn.
**Chain**: ExtraAttack_BanXian through 9_BanXian PassiveData → queue statuses → KHN priority checking (HasHigherPriorityExtraAttackQueued)
**Access**: Passive/Aura (scales with realm)
**Completeness**: Full

### Hardcore 仙人模式 (Immortal Mode)
**What**: NPCs get cultivation awakening on combat start; DaoHeng increases on long rest.
**Chain**: BANXIAN_HARDCORE status applied → Difficulty.lua awakens NPC with random LingGen → IncreaseDH.LongRest grows NPC cultivation over time
**Access**: Script-only (toggled by mode)
**Completeness**: Full

## Feature Gaps
- **HTBG 后天补根**: Stub — 5 sub-spells with empty SpellProperties, no Lua handler. Design intent unknown.
- **FSZMG 梵圣真魔功**: Partial — Levels 1-9 implemented, Level9 capstone fixed, DevilForms ObjectSize capped. Incomplete ability descriptions.
- **CaiDao 财道**: Localization stubs exist (XML lines 365-369) with empty descriptions but no stat entries or Lua handler. Planned but unimplemented DaDao path.
- **EGui 饿鬼道**: Localization text says "(暂未开发！)" but `MODE_BANXIAN_DH_EGUI_TECHNICAL` + passive are implemented. Stale localization.
