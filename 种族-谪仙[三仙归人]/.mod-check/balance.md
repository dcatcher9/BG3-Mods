# Balance — 种族·谪仙「三仙归人」
<!-- Last updated: 2026-03-12 -->

| Feature | Rating | Concern | Details |
|---|---|---|---|
| ExtraAttack 连击 | ⚠️ Strong | Up to 10 attacks/turn | Scales linearly with realm; no resource cost per extra attack. At high cultivation, dramatically outpaces any vanilla class. |
| DaoHeng accumulation | ℹ️ Note | Exponential NPC scaling in Hardcore | Boss NPC DH growth = `random(1,20) * ZZ * Level + Days` per long rest. High-level bosses can snowball quickly. |
| FABAO SpellProperties | ℹ️ Note | Longest fields at ~2907 chars | Two fields in FABAO.txt (FireBreath Cone/Ray) are at 2907/4000 chars. Safe now but close to hang threshold if expanded. |

## Detailed Notes

### ExtraAttack Scaling
The mod grants extra attacks based on cultivation realm, stacking up to `ExtraAttack_9_BanXian` (10 total attacks). Each attack is a full weapon attack with no additional resource cost. This significantly exceeds vanilla BG3's action economy (Fighter gets max 4 with Action Surge). Whether this is intentional power fantasy or needs balancing depends on design intent — the mod is clearly designed to be high-power.

### NPC DaoHeng Growth
In Hardcore mode, `Difficulty.IncreaseDH.LongRest()` grows NPC cultivation every long rest. The formula includes multiplicative factors (random * LingGen tier * level + game days). Boss NPCs get `random(1,20)` while normal NPCs get `random(1,4)`. Over many long rests, boss NPCs can become extremely powerful. This may be intentional to create escalating challenge.

### FABAO Field Length
The two FireBreath SpellProperties fields are the longest data fields in the mod at ~2907 characters. The BG3 stat parser hangs at ~4000-5000 characters. These have ~1000 chars of headroom but should be monitored if more conditional ApplyStatus calls are added.
