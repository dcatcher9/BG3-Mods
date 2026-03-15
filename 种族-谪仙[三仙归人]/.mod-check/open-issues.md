# Open Issues — 种族·谪仙「三仙归人」
<!-- Last updated: 2026-03-15 -->
<!-- Count: 2 open (0 red, 0 orange, 2 yellow, 0 blue, 0 white) -->

### 🔴 Bugs / Errors
— none

### 🟠 Wrong Behavior
— none

### 🟡 Logic / Consistency
- **Y-01** `BANXIAN_BASE.txt` entry `BANXIAN_ShenXingBaiBu` — `MovedDistanceGreaterThan(9)` in BoostConditions: KHN implementation uses `MobileShootingCasterCondition()` as a proxy (checks "has moved this turn" flag), not actual distance. The "9m" threshold is cosmetic — any movement triggers the bonus. Consider implementing actual distance tracking via Lua if precise threshold matters.
- **Y-02** `BANXIAN_BASE.txt` entry `BANXIAN_DaoXinMoLi` — `DamageTakenGreaterThan(MaxHP/10)` in Conditions: `MaxHP/10` is evaluated by the stat engine, not KHN — the KHN function receives the pre-computed integer. This should work but is untested with stat-engine math expressions as KHN arguments. If it doesn't fire at runtime, replace with a Lua-based OnDamaged handler.

### 🔵 Redundancy
— none

### ⚪ Minor / Typos
— none
