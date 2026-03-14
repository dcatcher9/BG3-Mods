# Features — 种族·谪仙「三仙归人」
<!-- Last updated: 2026-03-14 -->

## Feature Table

| Feature / System | Completeness | Player Access | Key Files |
|---|---|---|---|
| LingGen 灵根 | Full | Passive/Aura | BANXIAN_REN.txt, LingGen.lua, Variables.lua (auto-activates on party join) |
| ZhouTian 周天淬体 | Full | Spell + Passive | BANXIAN_TIAN.txt, EventHandlers.lua |
| WZPLG 五转培灵功 | Full | Spell | BANXIAN_REN.txt, SpellLists.lsx |
| WZCYG 五藏藏元功 | Full | Passive | BANXIAN_REN.txt |
| HTBG 后天补根 | Stub | Spell | BANXIAN_REN.txt (empty SpellProperties) |
| Shenshi 神识 | Full | Spell | SHENSHI.txt, ShenShi.lua, XSS_BANXIAN.khn (recovers 1/turn in combat) |
| Shenshi 掌日 Control | Full | Spell | SHENSHI.txt, ShenShi.lua (permanent mind control, dismiss by re-cast) |
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
| JingJie T5 化神·因果律 | Full | Toggle Spell | BANXIAN_JINGJIE.txt, JingJie.lua (chain attacks on hit, weapon→weapon/spell→mirror) |
| JingJie T5 化神·生灭律 | Full | Toggle Spell | BANXIAN_JINGJIE.txt, JingJie.lua (生: lifesteal→THP→CON, 灭: death mark→explode chain) |
| JingJie T5 化神·五行律 | Full | Toggle Spell | BANXIAN_JINGJIE.txt, JingJie.lua (5-element marks→WuXingCollapse AoE+stun) |
| JingJie T6 炼虚·虚影分身 | Full | Spell | BANXIAN_JINGJIE.txt, JingJie.lua (summon clone, share passives, all-resist, backlash on death) |
| JingJie T7 合体·法相天地 | Full | Toggle Spell | BANXIAN_JINGJIE.txt (Huge size, +3m melee, 2d8 Force, 6m fear aura, 4 Ki/turn) |
| JingJie T8 大乘·领域 | Partial | Spell | BANXIAN_JINGJIE.txt, JingJie.lua (12m domain, debuff/buff aura, DAO_RESONANCE — **3 resonance effects broken: R-01**) |
| JingJie T9 渡劫·天劫 | Full | Passive + Spell | BANXIAN_JINGJIE.txt, JingJie.lua (JIEQI stacking, tribulation gamble) |
| JingJie T10 真仙·仙法 | Full | Passive + Spells | BANXIAN_JINGJIE.txt, JingJie.lua (condition immunity, +3 stats, auto-revive, 斩仙/袖里/万法/神足) |
| Debug 调试指令 | Full | Console (!bx) | Debug.lua (info/linggen/daoheng/jingjie/dadao/shenshi/gongfa/fabao/refresh commands) |

## Feature Details

### JingJie T5 化神·因果律 (Causality Law)
**What**: Chain attacks on hit — weapon hits trigger weapon attacks on nearby enemies, spell hits mirror damage with original save.
**Chain**: `Shout_BANXIAN_JJ5_YINGUO` → `BANXIAN_JJ5_YINGUO_STATUS` (using FAZE_BASE) → JingJie.lua `YinGuoChain()` on AttackedBy → recursive with halving probability, depth 5 cap. Weapon uses `YINGUO_CHAIN_HIT` (ExecuteWeaponAttack), spell uses dynamically created status with parsed SpellRoll save. Kill restores 50% Ki via `YINGUO_KILL` passive.
**Access**: Toggle spell (BonusAction, activates law stance)
**Completeness**: Full

### JingJie T5 化神·生灭律 (Life/Death Law)
**What**: 生 mode — lifesteal + overflow THP → permanent CON. 灭 mode — death marks + kill explosion chain.
**Chain**: `Shout_BANXIAN_JJ5_SHENGMIE` → `SHENGMIE_STATUS` (using FAZE_BASE) → 生: stat passive `SHENGMIE_SHENG` (OnAttack: Necrotic + heal) + Lua `ShengMieLifeExcess` (THP accumulation, CON conversion at CON×20 threshold). 灭: toggle `SHENGMIE_TOGGLE` → `MIE_MODE` → Lua `ShengMieDeathMark` (OnAttacked) + `ShengMieExplode` (OnDying, AoE + infect).
**Access**: Toggle spell + sub-toggle (生↔灭)
**Completeness**: Full

### JingJie T5 化神·五行律 (Five-Element Law)
**What**: Attacks cycle through 5 elements, applying marks. Gathering all 5 across battlefield triggers WuXingCollapse (massive AoE + stun).
**Chain**: `Shout_BANXIAN_JJ5_WUXING` → `WUXING_STATUS` (using FAZE_BASE) → Lua `WuXingOnHit` (cycle stage 1-5, apply WUXING_MARK_N, LingGen affinity bonus) → `WuXingScanMarks` checks all enemies → `WuXingCollapse` uses convex hull of marked positions to include bystanders → level×d6 per mark + STUNNED + mark consumption.
**Access**: Toggle spell
**Completeness**: Full
**Notes**: Convex hull algorithm (Graham Scan) for AoE targeting is elegant. Marks persist permanently (Y-01).

### JingJie T6 炼虚·虚影分身 (Shadow Clone)
**What**: Summon a clone that inherits passives/statuses, shares Ki pool. Owner gets all-resist while clone lives.
**Chain**: `Shout_BANXIAN_JJ6_SUMMON` (8 Shenshi) → `XUYING_ACTIVE` status → Lua `SummonShadowClone` (CreateAt from template) → 500ms timer → `SetupShadowClone` (copy passives/statuses, set half HP). Recall: `Shout_BANXIAN_JJ6_RECALL` → RemoveStatus → Lua `RecallShadowClone` (transfer remaining HP). Death: Lua `OnShadowCloneDeath` → `XUYING_BACKLASH` (5d10 Psychic + 2 Shenshi). Long rest cleanup included.
**Access**: Spell (Action + 8 Shenshi)
**Completeness**: Full
**Notes**: Single pending clone setup (XUYING_PENDING_SETUP) means only one clone can initialize at a time — acceptable since each character casts manually.

### JingJie T8 大乘·领域 (Domain)
**What**: 12m aura domain with enemy debuff, ally buff, and Dao resonance effects.
**Chain**: `Shout_BANXIAN_JJ8_LINGYU_ON` (16 Shenshi) → `LINGYU_STATUS` (12m AuraStatuses: DEBUFF on enemies, ALLYBUFF on allies; 4 Shenshi/turn) → Lua `ApplyDaoResonance` finds highest-DH Dao path → applies resonance status (e.g., LINGYU_DAO_TIAN for lightning ticks).
**Access**: Spell (Action + 16 Shenshi)
**Completeness**: **Partial** — 3 of 10 resonance effects broken (XIULUO_P, HEHUAN_P, CHUSHENG_P have wrong context.Target in conditions; JIAN_P has wrong mechanic). Offensive resonances (TIAN, DIYU, EGUI, YI, LI, RENJIAN) work correctly.

### Debug 调试指令 (Debug Console)
**What**: Console commands for testing cultivation mechanics via `!bx` prefix.
**Chain**: Debug.lua registers `Ext.RegisterConsoleCommand('bx', ...)` → dispatches to subcommands: info/linggen/daoheng/jingjie/dadao/shenshi/gongfa/fabao/refresh.
**Access**: Console only (`!bx help`)
**Completeness**: Full — covers all major systems (LingGen set/clear, DaoHeng set/add, JingJie shortcut, DaDao add/remove/days, Shenshi set/max, GongFa add/remove, FaBao add/remove/clear, refresh all)

## Feature Gaps
- **HTBG 后天补根**: Stub — 5 sub-spells with empty SpellProperties, no Lua handler. Design intent unknown.
- **FSZMG 梵圣真魔功**: Partial — Levels 1-9 implemented, Level9 capstone fixed, DevilForms ObjectSize capped. Incomplete ability descriptions.
- **CaiDao 财道**: Localization stubs exist (XML lines 365-369) with empty descriptions but no stat entries or Lua handler. Planned but unimplemented DaDao path.
- **EGui 饿鬼道**: Localization text says "(暂未开发！)" but `MODE_BANXIAN_DH_EGUI_TECHNICAL` + passive are implemented. Stale localization.
- **领域共鸣 XIULUO/HEHUAN/CHUSHENG/JIAN**: Four resonance effects non-functional due to bugs R-01/O-01.
