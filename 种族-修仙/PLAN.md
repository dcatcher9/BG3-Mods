# 种族-修仙 Implementation Plan

## Overview

This mod adds a Wu Xing (五行) cultivation system to BG3. All characters receive the system automatically (no subrace restriction). The system uses 6 nodes (5 organs + DanTian), 30 directed edges (meridians), and "walks" through the graph as skills. All mechanics emerge from the same distance formula: `(to_index - from_index + 5) % 5`.

境界 (realm) is derived from 丹田/识海 capacity — no manual breakthroughs.
被动 cost the same as 主动 per the unified cost formula, consumed per turn.

The plan is split into 8 phases, each producing a playable/testable state.

---

## Architecture

```
Server/
├── Main.lua                    -- Module loader
├── Modules/
│   ├── Variables.lua           -- Constants, tables, config
│   ├── Utils.lua               -- Shared utilities (GrantXiuXian, etc.)
│   ├── EventHandlers.lua       -- Osiris event routing
│   └── Systems/
│       ├── LingGen.lua         -- Spiritual root values & tiers       [Phase 0]
│       ├── DanTian.lua         -- 丹田/识海 resource pools             [Phase 1]
│       ├── JingMai.lua         -- Graph: nodes, edges, open/close     [Phase 1]
│       ├── WalkEngine.lua      -- Walk calculation (L1/L2/L3)         [Phase 2]
│       ├── EdgeEffects.lua     -- 20 edge effects x 4 tiers           [Phase 2/5]
│       ├── GongMing.lua        -- Self-loop (共鸣) passives            [Phase 2]
│       ├── WalkBuilder.lua     -- Dynamic spell/passive generation    [Phase 3]
│       ├── ImGuiPanel.lua      -- ImGui meridian graph UI             [Phase 3]
│       ├── JingJie.lua         -- Realm progression (derived)         [Phase 4]
│       ├── PassiveCycle.lua    -- Passive walk turn-start execution   [Phase 5]
│       ├── GongFa.lua          -- Cultivation methods                 [Phase 6]
│       ├── TianRanJingHua.lua  -- Natural essences                   [Phase 6]
│       ├── FaBao.lua           -- Magical artifacts                   [Phase 8a]
│       ├── ZhenFa.lua          -- Formation system                    [Phase 8b]
│       └── Debug.lua           -- Debug commands (!xx)                [Phase 0]
```

---

## Phase 0: Foundation ✅

**Goal:** Lua module architecture, custom resources, auto-grant to all characters.

### What was built
- Module loader + event routing skeleton
- `XIUXIAN_Racial_Passive` auto-granted via Lua to all characters (party + enemies)
- `QiPoint` + `ShenshiPoint` ActionResourceDefinitions (Qi = LongRest, ShenShi = ShortRest)
- `LingGen.Awake()` — random initial values using pool-cut algorithm
- Debug commands: `!xx info`, `!xx linggen`, `!xx scan`, `!xx setlg`
- PersistentVars initialization
- Config.json with ModuleUUID

### Verified
- [x] Mod loads, passive granted to all characters
- [x] Qi and ShenShi bars visible in UI
- [x] LingGen values initialize on first encounter
- [x] Debug commands work
- [x] PersistentVars persists across saves

---

## Phase 1: Data Model — LingGen, DanTian, JingMai ✅

**Goal:** Complete data model. No walk execution yet — just storage, queries, and debug inspection.

### Step 1a — LingGen ✅
- 5 status turns: `XIUXIAN_LG_MU/HUO/TU/JIN/SHUI` with `FreezeDuration`
- `LingGen.Get/Set/Add/GetTier/GetTotal`
- Awake guard prevents double-init
- Debug: `!xx linggen`, `!xx setlg <elem> <value>`

### Step 1b — DanTian/ShiHai ✅
- Status turns: `XIUXIAN_DANTIAN`, `XIUXIAN_SHIHAI`
- Init: 丹田=2, 识海=1
- `DanTian.SyncResources()` — sync actual Qi/ShenShi max via `Osi.AddBoosts`
- Debug: `!xx resources`

### Step 1c — JingMai (Meridian Graph) ✅
- `PersistentVars['JINGMAI_<guid>']` — 15 boolean meridian states
- Pure data model: `IsOpen/CanOpen/Open/GetOpenEdges/GetReachableFrom`
- Init: all closed on first encounter
- Debug: `!xx jingmai`, `!xx open <elemA> <elemB>`

### Verified
- [x] LingGen values persist across saves
- [x] DanTian/ShiHai values persist and sync to resource bars
- [x] Meridians stored per-character in PersistentVars
- [x] Debug commands for all three subsystems

---

## Phase 2: Walk Engine & Combat Effects

**Goal:** Walk calculation engine + self-loop (共鸣) passives + first batch of edge effects as real BG3 spells.

### Step 2a — WalkEngine.lua
Core calculator, no BG3 stat integration yet:
- `CalcWalkEffects(walk)` → `{edge_effects, node_effects, final_dist}`
- Layer 1: per-edge distance + effect lookup
- Layer 2: node compound `(d_in + d_out) % 5`
- Layer 3: `final_distance = (Σ all d) % 5`
- `CalcCost(walk)` — ShenShi = Σ(distance), Qi = Σ(min(tier)+1)
- `ClassifyWalk(walk)` — self-loop / chain / cycle
- Self-loop support (A→A, distance=0)

### Step 2b — Walk Growth System
Called after every walk execution (active use or passive tick):
- **灵根 growth:** `pool = BASE_LG × qi_cost`, distributed by `contribution(N) = (max(0,tier(N))+1) × visits(N)`
- **丹田 growth:** `BASE_DT × qi_cost`
- **识海 growth:** `BASE_SS × shenshi_cost`
- Fractional accumulators in PersistentVars (party only):
  - `LGACC_<guid>` = {木=float, ...}, `DTACC_<guid>` = float, `SSACC_<guid>` = float
- Auto-open meridians when both endpoints ≥ 50
- Constants: `BASE_LG=0.05`, `BASE_DT=0.02`, `BASE_SS=0.02`

### Step 2c — GongMing.lua (Self-Loop Passives)
5 elements × 5 tiers (<T0, T0, T1, T2, T3) = 25 passive stat entries:
- Each activates when LingGen > 0 for that element
- Auto-upgrade with tier change (shared StackId per element)
- **Consumes qi per turn** (tier+1), shenshi = 0
- Also applies walk growth each turn (self-loop walk execution)
- See idea.md "共鸣被动" section for per-element effects

### Step 2d — EdgeEffects.lua (T0 only)
- `EDGE_EFFECTS[edge_name][tier]` = function(caster, target, tier)
- T0 implementations for all 20 edges
- Status entries: `XIUXIAN_EDGE_RAN_T0`, etc.

### Step 2e — Starter Walk Spells
5-10 hand-crafted walk spells as real BG3 spells:
- 2-node (Bonus Action): 灭式(水→火), 燃式(木→火), 斩式(金→木)
- 3-node (Action): 灭熔式(水→火→金), 滋侵式(水→木→土)
- `UseCosts` with QiPoint and ShenshiPoint
- Validate against open meridians on cast

### Verification
- [ ] Self-loop passives activate when LingGen > 0
- [ ] Passives auto-upgrade when tier changes
- [ ] Self-loop passives consume qi per turn, stop when qi = 0
- [ ] 2-node walks work as Bonus Actions
- [ ] 3-node walks work as Actions
- [ ] Edge effects apply correct statuses/damage
- [ ] Walk growth: LingGen, 丹田, 识海 all increment
- [ ] Walks fail if required meridian not open

---

## Phase 3: Dynamic Walk Builder & ImGui UI

**Goal:** ImGui panel for constructing custom walks. Runtime spell generation.

### Files to create

1. **WalkBuilder.lua** — Walk management
   - `PersistentVars['WALKS_<guid>']` — saved walk definitions
   - `PersistentVars['ACTIVE_PASSIVES_<guid>']` — active passive walks
   - `RegisterAsSkill(character, walk)` — `Ext.Stats.Create()` + `Ext.Stats.Sync()` + `Osi.AddSpell()`
   - `RegisterAsPassive(character, walk)` — create passive, start consuming resources
   - Auto-naming: edge names + suffix (式/诀/律)

2. **ImGuiPanel.lua** — ImGui UI
   - Pentagon + center node layout via `DrawList`
   - Colored arrows by distance type
   - Click-to-add-node walk construction
   - Real-time cost/effect preview
   - Active passives list with per-turn cost display
   - Resource display (ShenShi/Qi remaining)

### Verification
- [ ] ImGui panel opens via hotkey/spell
- [ ] Click nodes to build walk path
- [ ] Walk validated against open meridians
- [ ] [确认为技能] creates real spell in spellbook
- [ ] Passive walks consume resources per turn
- [ ] Walks survive save/load

---

## Phase 4: Realm System — 境界

**Goal:** Realm derived from 丹田/识海 thresholds. Auto-advances. 金丹 element choice.

### Files to create

1. **JingJie.lua** — Realm system
   - `GetRealm(character)` — compute from DanTian/ShiHai values
   - `CheckAdvancement(character)` — called after growth
   - Realm thresholds: `{炼气={0,0}, 筑基={6,1}, 金丹={15,3}, 元婴={30,8}, ...}`
   - On realm change: unlock graph features (丹田 node activation, etc.)
   - 金丹: prompt element choice (irreversible, stored in PersistentVars)

2. **XIUXIAN_JINGJIE.txt** — Display statuses per realm

### Verification
- [ ] Realm auto-advances when thresholds crossed
- [ ] 筑基 unlocks DanTian node + 5 meridians
- [ ] 金丹 prompts element choice
- [ ] Debug: `!xx jingjie` shows realm + progress

---

## Phase 5: T1/T2/T3 Edge Effects & Passive Cycles

**Goal:** Full edge effect tiers. Passive cycle execution.

### Files to modify

1. **EdgeEffects.lua** — Expand all 20 edges × T1/T2/T3
   - Total: ~80 effect implementations
   - T3 effects have cooldowns

2. **PassiveCycle.lua** — Passive walk execution
   - On `ObjectTurnStarted`, execute active passive walks
   - Consume qi + shenshi per turn
   - Stop when resources depleted
   - T3 edges fire every N rounds
   - Apply walk growth each tick

### Verification
- [ ] Effects scale noticeably with tier
- [ ] T3 effects have cooldowns
- [ ] Passive cycles fire at turn start
- [ ] Multiple passives limited by qi + shenshi pools
- [ ] Passive stops when resources run out

---

## Phase 6: GongFa & Natural Essences

**Goal:** Cultivation methods and organ-modifying essences.

### Files to create

1. **GongFa.lua** — Cultivation methods
   - Modifiers: `{node_modifiers, edge_modifiers, fold_rule, unlock}`
   - Internal crystallization: walk repetition → auto-crystallize
   - External: jade slip items
   - Element matching: GongFa vs JinDan = bonus/penalty

2. **TianRanJingHua.lua** — Natural essences
   - 25 essences (5 per element: T1/T1/T2/T2/T3)
   - One slot per organ, replaceable
   - Modify walk engine when walk passes enhanced node

### Verification
- [ ] GongFa visibly changes walk effects
- [ ] Essences permanently boost organ tier
- [ ] Crystallization triggers after repeated walk usage
- [ ] Full loop: walk → grow → open meridian → new walks → crystallize

---

## Phase 7: Advanced Realms — 元婴/化神

**Goal:** Parallel walks and dual-layer graph.

### Files to modify

1. **JingJie.lua** — Add realms:
   - 元婴: 7th node, parallel walk, element choice
   - 化神: 12 nodes (physical + spiritual mirror), cross-layer walk

2. **WalkEngine.lua** — Parallel walk execution, cross-layer edges

3. **JingMai.lua** — Expand graph to 7/12 nodes

4. **ImGuiPanel.lua** — 7th node, dual-layer visualization

### Verification
- [ ] 元婴 adds 7th node + parallel walk slot
- [ ] Two walks execute simultaneously
- [ ] 化神 doubles graph to 12 nodes
- [ ] Cross-layer walks use correct distance rules

---

## Phase 8: FaBao, ZhenFa & Late-Game Realms

**Goal:** Complete the design vision. Sub-phases are independent.

### 8a: FaBao (Magical Artifacts)
- External nodes attaching to organs
- Refinement (open artifact-organ meridians)
- Simple (single node) → complex (internal sub-graph)

### 8b: ZhenFa (Formations)
- Multi-character spatial graph (8 trigram positions)
- Party-wide walk execution
- Formation types: line/ring/star/full

### 8c: Late Realms
- **炼虚:** walk through enemy nodes (target routing)
- **合体:** environment nodes, fold_rule min→max
- **大乘:** FaXiang (graph clone as summon)
- **渡劫:** adversarial walk collision `(your_d + tiandao_d) % 5`
- **真仙:** void node (player-chosen distance 0-4)

---

## Technical Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Stat field length limit (~4000 chars) | Split passives across multiple stat entries |
| `Ext.Stats.Create` + `Sync` performance | Cache in PersistentVars; recreate on load only |
| Save/Load persistence | All state in PersistentVars + status turns; restore on timer |
| ImGui feature gaps | Keep default view simple; detail on demand |
| Combat event timing | Use `ObjectTurnStarted` for passives, not `CombatRoundStarted` |
| Walk validation | Always validate against open meridians before execution |
| New init inside idempotency guard | Keep new subsystem init OUTSIDE `HasPassive` checks |
| Double-fire in same Osiris batch | Use local guards for same-tick dedup |
