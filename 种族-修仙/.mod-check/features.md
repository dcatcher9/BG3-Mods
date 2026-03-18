# Features — 种族-修仙
<!-- Last updated: 2026-03-17 -->

## Feature Table

| Feature / System | Completeness | Player Access | Key Files |
|---|---|---|---|
| Auto-grant system | Full | Automatic (all chars) | Utils.lua, EventHandlers.lua |
| Qi Resource | Full | Action Bar | ActionResourceDefinitions.lsx, DanTian.lua |
| ShenShi Resource | Full | Action Bar | ActionResourceDefinitions.lsx, DanTian.lua |
| Racial Passive | Full | Passive | XIUXIAN_BASE.txt |
| LingGen (灵根) | Full | Console (!xx linggen) | LingGen.lua, XIUXIAN_LINGGEN.txt |
| DanTian/ShiHai (丹田/识海) | Full | Console (!xx dantian) | DanTian.lua, XIUXIAN_DANTIAN.txt |
| JingMai (经脉) | Full | Console (!xx jingmai/open/close) | JingMai.lua, Variables.lua |
| Debug Console | Full | Console (!xx) | Debug.lua |

## Feature Details

### DanTian/ShiHai (丹田/识海)
**What**: Qi max = 丹田 size, ShenShi max = 识海 size, stored as frozen status turns
**Chain**: GrantXiuXian → DanTian.InitCharacter → SetQiMax/SetShenshiMax (ApplyStatus) → SyncResources (dynamic BOOST with ActionResource)
**Access**: Auto on init; debug via `!xx dantian`, `!xx setdt qi|ss <val>`
**Completeness**: Full
**Notes**: Dynamic status `XIUXIAN_RSYNC_<qi>_<ss>` created at runtime, overwrites via shared StackId. Initial: 丹田=2, 识海=1.

### JingMai (经脉图)
**What**: 10 undirected meridian pairs (organ-to-organ), each producing 2 directed edges. Binary open/closed per character.
**Chain**: PersistentVars[`JINGMAI_<guid>`] → JingMai.Open/Close/IsOpen/CanOpen/GetOpenEdges/GetReachableFrom
**Access**: Debug via `!xx jingmai`, `!xx open <A> <B>`, `!xx close <A> <B>`
**Completeness**: Full (data model only; no combat effects yet — Phase 2)
**Notes**: Open condition: both endpoint LingGen ≥ 50. Edge weight derived at runtime from min(tier_A, tier_B). 丹田 meridians commented out for Phase 4.
