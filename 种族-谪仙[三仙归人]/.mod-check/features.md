# Features — 种族·谪仙「三仙归人」
<!-- Last updated: 2026-03-14 (re-audit) -->

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
| JingJie T5 因果律 | Full | Toggle Spell | BANXIAN_JINGJIE.txt, JingJie.lua (chain: weapon→weapon attack, spell→Osi.UseSpell replication) |
| JingJie T5 生灭律 | Full | Toggle Spell | BANXIAN_JINGJIE.txt, JingJie.lua (生: lifesteal→THP→CON, 灭: death mark→HP%-based explode chain) |
| JingJie T5 五行律 | Full | Toggle Spell | BANXIAN_JINGJIE.txt, JingJie.lua (5-element marks→WuXingCollapse AoE+stun) |
| JingJie T6 虚影分身 | Full | Spell | BANXIAN_JINGJIE.txt, JingJie.lua (75% HP clone, all-resist, backlash 3d10) |
| JingJie T6 虚实互换 | Full | Spell | BANXIAN_JINGJIE.txt, JingJie.lua (swap positions, 1-turn blur) |
| JingJie T6 虚空断裂 | Full | Spell | BANXIAN_JINGJIE.txt, JingJie.lua (6d8 Force + push + kill explosion 4d8) |
| JingJie T6 虚空侵蚀 | Full | Passive (clone) | BANXIAN_JINGJIE.txt (clone attacks apply AC-1, Additive stack, 3-turn) |
| JingJie T6 相位游离 | Full | Passive | BANXIAN_JINGJIE.txt (auto-immunity <50% HP, once-per-combat CD) |
| JingJie T7 法相天地 | Full | Toggle Spell | BANXIAN_JINGJIE.txt, JingJie.lua (Huge, +3m, crit-2, stun aura, suppress reactions, quake, dynamic 1d6×enemies Force) |
| JingJie T7 金刚不坏 | Full | Passive | BANXIAN_JINGJIE.txt (DamageReduction(All,Flat,ProficiencyBonus) + immune to crits) |
| JingJie T8 领域 | Full | Spell | BANXIAN_JINGJIE.txt, JingJie.lua (12m, +3att/DC, ExtraAttack, -3/half move/no teleport enemies, +2/concentration/resist allies, 3 Shenshi/turn, 3d10 highest-HP) |
| JingJie T8 领域·绝对 | Full | Spell | BANXIAN_JINGJIE.txt (1-turn ultimate: -5/no reactions enemies, immune allies, +1AP) |
| JingJie T8 大道共鸣 | Full | Auto | BANXIAN_JINGJIE.txt, JingJie.lua (10 Dao paths, all enhanced: 天4d10, 修罗厄运3d8, 地狱3d10, 剑3d8, 羿弹射, 鬼50%吸血, 力击退, 合欢支配, 人间治愈, 畜生全劣势) |
| JingJie T9 劫气 | Full | Passive | BANXIAN_JINGJIE.txt, JingJie.lua (1d6/stack, max 9, PersistentVars) |
| JingJie T9 引劫 | Full | Spell | BANXIAN_JINGJIE.txt, JingJie.lua (18m AoE: stacks×3d10 thunder+radiant, 25% self-damage) |
| JingJie T9 劫雷护体 | Full | Passive | JingJie.lua (counter stacks×2d6 lightning — **Y-01: tooltip passive orphaned**) |
| JingJie T9 劫雷化身 | Full | Spell | BANXIAN_JINGJIE.txt, JingJie.lua (3-turn: immune, 2x speed, +1 jieqi/turn, AoE splash, exhaustion) |
| JingJie T9 逆天改命 | Full | Passive | BANXIAN_JINGJIE.txt, JingJie.lua (代死盟友, 承受50%HP精神伤, 殉爆劫气, 长休CD) |
| JingJie T9 劫气贯体 | Full | Status | BANXIAN_JINGJIE.txt, JingJie.lua (5+层无视Resistant, PersistentVars) |
| JingJie T10 斩仙一剑 | Full | Spell (combat 1×) | BANXIAN_JINGJIE.txt (20d12 Force + 25%HP斩杀=extra 40d12) |
| JingJie T10 袖里乾坤 | Full | Spell (短休 1×) | BANXIAN_JINGJIE.txt (5-turn INCAPACITATED, 8d10/turn, exit→STUNNED 2) |
| JingJie T10 万法归宗 | Full | Passive | BANXIAN_JINGJIE.txt, JingJie.lua (any damage: heal+Ki+Shenshi, 50% reflect, 3-turn CD — **O-02: multi-trigger in same turn**) |
| JingJie T10 天道轮回 | Full | Spell (长休 1×) | BANXIAN_JINGJIE.txt (3-turn: +2AP/+2BA, 18m AoE 5d10/turn, exhaustion) |
| JingJie T10 仙体回复 | Full | Passive | BANXIAN_JINGJIE.txt (Level+CON/turn, full HP→THP=Level) |
| JingJie T10 神足通 | Full | Spell | BANXIAN_JINGJIE.txt (30m teleport, bonus action, no CD) |
| Debug 调试指令 | Full | Console (!bx) | Debug.lua |

## Feature Details

### JingJie T5 化神·因果律 (Causality Law)
**What**: Chain attacks on hit — weapon hits trigger weapon attacks on nearby enemies, spell hits use `Osi.UseSpell` for full engine replication.
**Chain**: `Shout_BANXIAN_JJ5_YINGUO` → `YINGUO_STATUS` (using FAZE_BASE) → JingJie.lua `YinGuoChain()` on AttackedBy → recursive with halving probability, depth 5 cap. Weapon uses `YINGUO_CHAIN_HIT` (ExecuteWeaponAttack). Spell uses `Osi.UseSpell(attacker, spell, target)`.
**Access**: Toggle spell (BonusAction)
**Completeness**: Full

### JingJie T5 化神·生灭律 (Life/Death Law)
**What**: 生 mode — lifesteal + overflow THP → permanent CON. 灭 mode — death marks + kill explosion chain (HP%-based damage).
**Chain**: Shout → SHENGMIE_STATUS → 生: stat passive + Lua ShengMieLifeExcess. 灭: toggle → MIE_MODE → Lua ShengMieDeathMark + ShengMieExplode (now uses deadTarget maxHP/4 via ApplyDamage, mark doubles).
**Access**: Toggle spell + sub-toggle
**Completeness**: Full

### JingJie T6 炼虚·虚实之道 (Void Path)
**What**: Expanded T6 with 5 sub-features: shadow clone (75% HP), position swap, void sunder, void erosion, phase shift.
**Chain**: BANXIAN_JJ6_XUYING → unlocks Summon/Recall/Swap/VoidSunder spells + Evasion. Clone gets XUYING_MARK (includes EROSION_P passive for AC-1 on hit). SwapWithClone Lua swaps positions. VoidSunder does 6d8 Force + push + kill explosion. PHASE_SHIFT auto-immunity at <50% HP (OnDamaged, once-per-combat CD).
**Access**: Spells + Passive
**Completeness**: Full

### JingJie T7 合体·天人合一 (Celestial Unity)
**What**: Expanded T7 with 金刚不坏 + enhanced 法相 (stun aura, suppress reactions, dynamic force damage).
**Chain**: BANXIAN_JJ7_FAXIANG + JINGANG passives. Faxiang: Huge size, crit-2, stun aura (WIS save), SUPPRESS (remove reactions), QUAKE (grease on move), PASSIVE (2d8 Force melee), FaxiangDynamicDamage Lua (enemy count × 1d6 Force). Jingang: DamageReduction + CriticalHit(Never).
**Access**: Toggle spell + Passive
**Completeness**: Full

### JingJie T8 大乘·法域降世 (Domain Descent)
**What**: Enhanced domain + new ABSOLUTE mode. Domain: +3 att/DC, ExtraAttack, 12m aura, 3d10/turn to highest-HP enemy. Absolute: 1-turn ultimate (-5/-5/no reactions enemies, immune allies, +1AP).
**Chain**: LINGYU_STATUS (enhanced stats, 3 Shenshi/turn) + DomainHighestHPDamage Lua + ApplyDaoResonance. ABSOLUTE_STATUS (1-turn AuraStatuses).
**Access**: Spells
**Completeness**: Full (RemoveConditions + RemoveEvents added)

### JingJie T9 渡劫·天劫九重 (Nine Tribulations)
**What**: Completely reworked T9 — offensive focus. Jieqi 1d6/stack, 5+ ignore resistance, counter-damage, avatar form, sacrifice mechanic.
**Chain**: DUJIE passive → 引劫 (AoE stacks×3d10), 劫雷护体 (Lua counter), 劫雷化身 (3-turn immune + AoE), 逆天改命 (Dying handler), 劫气贯体 (IgnoreResistance at 5+).
**Access**: Spells + Passives
**Completeness**: Full (jieqiCount persistent via PersistentVars, Avatar AoE via AvatarAoEDamage)

### JingJie T10 真仙·超脱轮回 (Transcendence)
**What**: Enhanced T10 with stronger abilities + new 天道轮回 ultimate.
**Chain**: 斩仙 (20d12 + 25% execute 40d12), 袖里 (5-turn 8d10 + stun), 万法 (any damage, heal+reflect+restore, 3-turn CD), 天道轮回 (3-turn: +2AP/+2BA, 18m 5d10 AoE, exhaustion), 仙体回复 (Level+CON/turn + THP).
**Access**: Spells + Passives
**Completeness**: Full (O-02: WanfaReflect multi-trigger is minor)

## Feature Gaps
- **HTBG 后天补根**: Stub — empty SpellProperties, no handler.
- **FSZMG 梵圣真魔功**: Partial — incomplete ability descriptions.
- **CaiDao 财道**: Localization stubs, no implementation.
- **EGui 饿鬼道**: Stale localization says "(暂未开发！)" but implementation exists.
- **相位游离**: FIXED — now granted via TIER_PASSIVES[6].
