# Balance — 种族·谪仙「三仙归人」
<!-- Last updated: 2026-03-14 -->

| Feature | Rating | Concern | Details |
|---|---|---|---|
| ExtraAttack 连击 | ⚠️ Strong | Up to 10 attacks/turn | Scales linearly with realm; no resource cost per extra attack. At high cultivation, dramatically outpaces any vanilla class. |
| DaoHeng accumulation | ℹ️ Note | Exponential NPC scaling in Hardcore | Boss NPC DH growth = `random(1,20) * ZZ * Level + Days` per long rest. High-level bosses can snowball quickly. |
| FABAO SpellProperties | ℹ️ Note | Longest fields at ~2907 chars | Two fields in FABAO.txt (FireBreath Cone/Ray) are at 2907/4000 chars. Safe now but close to hang threshold if expanded. |
| 五行律·五行崩 | ⚠️ Strong | Level×d6 per mark × 5 elements | At level 12, collapse deals up to 60d6 total (12d6 per element × 5) to marked targets + stun. Convex hull AoE catches bystanders for full 5-element burst. Damage scales with level without cap. |
| 生灭律·生 excess→CON | ℹ️ Note | Unbounded permanent CON | CON grows +1 each time excess healing reaches threshold (CON×20). Self-balancing (threshold grows) but no ceiling. Very long fights or farming could yield extreme CON. |
| 渡劫·天劫 | ℹ️ Note | Risk/reward heavily favors reward | 50% max HP self-damage for 1-turn full immunity + 3-turn +Level damage + full Ki/Shenshi restore. With healing items or 生律 active, survival is near-guaranteed. Clone survival doubles damage buff duration. |

## Detailed Notes

### ExtraAttack Scaling
The mod grants extra attacks based on cultivation realm, stacking up to `ExtraAttack_9_BanXian` (10 total attacks). Each attack is a full weapon attack with no additional resource cost. This significantly exceeds vanilla BG3's action economy (Fighter gets max 4 with Action Surge). Whether this is intentional power fantasy or needs balancing depends on design intent — the mod is clearly designed to be high-power.

### NPC DaoHeng Growth
In Hardcore mode, `Difficulty.IncreaseDH.LongRest()` grows NPC cultivation every long rest. The formula includes multiplicative factors (random * LingGen tier * level + game days). Boss NPCs get `random(1,20)` while normal NPCs get `random(1,4)`. Over many long rests, boss NPCs can become extremely powerful. This may be intentional to create escalating challenge.

### FABAO Field Length
The two FireBreath SpellProperties fields are the longest data fields in the mod at ~2907 characters. The BG3 stat parser hangs at ~4000-5000 characters. These have ~1000 chars of headroom but should be monitored if more conditional ApplyStatus calls are added.

### 五行崩 Damage Scaling
WuXingCollapse deals `level` d6 per elemental mark on each marked target. A target with all 5 marks takes 5×(level)d6 damage in 5 different elements. At level 12 that's 60d6 (avg 210). Bystanders in the convex hull take the full 5-element burst regardless. The convex hull targeting is creative but means large battles can see massive AoE damage. Balanced by requiring 5 separate attacks to set up marks on different enemies.

### 生灭律·生 CON Growth
Each CON conversion threshold is `currentCON × 20` hit points of excess healing. Starting at CON 10 → 200 excess needed, CON 11 → 220, etc. The growth is self-limiting (higher CON = higher threshold) but has no hard cap. In extremely long combat encounters or with farming, CON could reach absurd values. In practice, the Shenshi cost (1/turn) limits how long the law can stay active.

### 天劫 Risk/Reward
The tribulation deals 50% max HP as Thunder+Radiant. With full HP and any source of temporary HP, healing, or damage resistance (虚影 all-resist), survival is near-guaranteed. Reward is massive: full immunity for 1 turn, +Level damage for 3 turns (6 if clone survives), full Ki+Shenshi restore. Consider: the player can control timing (only cast when prepared), making it a guaranteed power spike rather than a genuine gamble.
