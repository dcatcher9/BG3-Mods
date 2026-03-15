# Balance — 种族·谪仙「三仙归人」
<!-- Last updated: 2026-03-14 -->

| Feature | Rating | Concern | Details |
|---|---|---|---|
| ExtraAttack 连击 | ⚠️ Strong | Up to 10 attacks/turn | Scales linearly with realm; no resource cost per extra attack. At high cultivation, dramatically outpaces any vanilla class. |
| DaoHeng accumulation | ℹ️ Note | Exponential NPC scaling in Hardcore | Boss NPC DH growth = `random(1,20) * ZZ * Level + Days` per long rest. High-level bosses can snowball quickly. |
| FABAO SpellProperties | ℹ️ Note | Longest fields at ~2907 chars | Two fields in FABAO.txt (FireBreath Cone/Ray) are at 2907/4000 chars. Safe now but close to hang threshold if expanded. |
| 五行律·五行崩 | ⚠️ Strong | Level×d6 per mark × 5 elements | At level 12, collapse deals up to 60d6 total (12d6 per element × 5) + stun. Convex hull AoE catches bystanders. |
| 生灭律·生 excess→CON | ℹ️ Note | Unbounded permanent CON | CON grows +1 each time excess healing reaches threshold (CON×20). Self-balancing but no ceiling. |
| 天劫九重·引劫 | ⚠️ Strong | Massive AoE at high jieqi | 9 stacks × 3d10 = 27d10 per enemy (avg 148.5) + stun, to ALL enemies within 18m. Self-damage only 25% of estimated total. Near-guaranteed benefit with pre-buffs. |
| 劫雷化身 | ⚠️ Strong | 3 turns full immunity + AoE | All damage immune, 2× movement, +3d8 Lightning +3d8 Radiant per hit (intended AoE), gains jieqi while active. Only trade-off is 1-turn exhaustion afterward. |
| 天道轮回 | 🔴 Very Strong | +2 AP +2 BA for 3 turns + 5d10 AoE | 3 turns of effectively quadruple actions (3 AP + 3 BA per turn with base) + passive 5d10/turn to all enemies within 18m. With 10 attacks per round, this is ~30 attacks across 3 turns + massive AoE. Exhaustion is 1 turn disadvantage — trivial trade-off. |
| 斩仙一剑 | ⚠️ Strong | 20d12 + execute | 20d12 (avg 130) Force, with 25% HP execute dealing additional 40d12 (avg 260). Total 60d12 on low-HP targets. One-shots nearly anything below 25% HP. |
| 金刚不坏 | ℹ️ Note | Permanent DamageReduction + crit immunity | DamageReduction(All,Flat,ProficiencyBonus) = -2 to -6 damage on every hit + immune to crits. Very strong defensive passive with no resource cost. |
| 领域·绝对 | ⚠️ Strong | 1-turn godmode for party | All allies immune to ALL damage + enemies -5/-5/no reactions. Once per long rest but with 天道轮回 active, that 1 turn has 3+ action points. |
| 万法归宗 反射 | ℹ️ Note | 50% damage reflect, 3-turn CD | Every 3 turns, reflects 50% of one (or more, O-02) hits as Force damage. Combined with heal + Ki/Shenshi restore, creates consistent sustain cycle. |

## Detailed Notes

### 天道轮回 — Most Powerful Ability
The combination of +2 AP and +2 BA for 3 turns with the mod's existing ExtraAttack stacking creates extraordinary action economy. A true immortal (T10) with 10 attacks per attack action gets:
- Turn 1: 3 attack actions (30 attacks) + 3 bonus actions + movement
- Turn 2-3: same
- Plus 5d10 Force AoE to all enemies within 18m each turn (avg 27.5 per enemy per turn)

Total: ~90 weapon attacks + 82.5 AoE damage per enemy over 3 turns. The 1-turn exhaustion (disadvantage on attack/saves) is easily mitigated by timing or party support. Cost: 20 Shenshi + 1 long rest charge. This is by far the strongest ability in the mod and likely makes most encounters trivial at T10.

### 引劫 Rework
Changed from self-damaging gamble to offensive AoE. 9-stack ceiling means max damage per enemy is 18d10 Lightning + 9d10 Radiant = 27d10 (avg 148.5) + STUNNED. Self-damage is estimated at 25% of average total (stacks×16 per enemy × enemy count / 4). With 5 enemies: total estimated 80×5=400 → self-damage=100 (50 Lightning + 50 Radiant). Survivable with 生律 or any healing. Risk/reward now heavily favors reward since damage is externalized.

### ExtraAttack Scaling (unchanged)
Still up to 10 attacks per action. Now with 天道轮回 giving 3 actions per turn, the effective ceiling is 30 attacks/turn for 3 turns.
