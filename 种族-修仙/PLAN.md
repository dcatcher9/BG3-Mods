# 种族-修仙 Implementation Plan

## Overview

This mod adds a Human subrace "修仙" to BG3, implementing a Wu Xing (五行) cultivation system based on graph theory. The system uses 6 nodes (5 organs + DanTian), 30 directed edges (meridians), and "walks" through the graph as skills. All mechanics emerge from the same distance formula: `(to_index - from_index + 5) % 5`.

The plan is split into 8 phases, each producing a playable/testable state.

---

## Architecture

```
Server/
├── Main.lua                    -- Module loader
├── Modules/
│   ├── Variables.lua           -- Constants, tables, config
│   ├── Utils.lua               -- Shared utilities
│   ├── EventHandlers.lua       -- Osiris event routing
│   └── Systems/
│       ├── JingMai.lua         -- Graph: nodes, edges, open/close     [Phase 1]
│       ├── LingGen.lua         -- Spiritual root values & tiers       [Phase 1]
│       ├── XingWei.lua         -- Behavioral experience tracking      [Phase 1]
│       ├── WalkEngine.lua      -- Walk calculation (L1/L2/L3)         [Phase 2]
│       ├── EdgeEffects.lua     -- 20 edge effects x 4 tiers           [Phase 2/5]
│       ├── WalkBuilder.lua     -- Dynamic spell/passive generation    [Phase 3]
│       ├── ImGuiPanel.lua      -- ImGui meridian graph UI             [Phase 3]
│       ├── JingJie.lua         -- Realm progression                   [Phase 4/7]
│       ├── Breakthrough.lua    -- Realm breakthrough events           [Phase 4]
│       ├── PassiveCycle.lua    -- Passive walk round-start execution  [Phase 5]
│       ├── GongFa.lua          -- Cultivation methods                 [Phase 6]
│       ├── TianRanJingHua.lua  -- Natural essences                   [Phase 6]
│       ├── FaBao.lua           -- Magical artifacts                   [Phase 8a]
│       ├── ZhenFa.lua          -- Formation system                    [Phase 8b]
│       └── Debug.lua           -- Debug commands                      [Phase 0]
```

---

## Phase 0: Foundation & Data Model

**Goal:** Lua module architecture, custom resources, auto-grant to all characters. Qi/ShenShi bars visible.

### Files to create/modify

1. **`Mods/XIUXIAN/ScriptExtender/Lua/BootstrapServer.lua`**
   - Initialize PersistentVars, require `Server/Main.lua`

2. **`Server/Main.lua`**
   - Module loader: create `XiuXian` table, require each system module, call `.Init()`, load EventHandlers

3. **`Server/Modules/Variables.lua`**
   - `ELEM_INDEX = { ["木"]=0, ["火"]=1, ["土"]=2, ["金"]=3, ["水"]=4 }`
   - `ELEM_NAMES`, `ORGAN_NAMES` (肝/心/脾/肺/肾), `ORGAN_ELEM` mapping
   - Tier thresholds: `{T0=25, T1=100, T2=300, T3=1000}`
   - Distance-to-reaction: `{[0]="共鸣", [1]="生", [2]="克", [3]="侮", [4]="泄"}`
   - Edge effect name table (20 entries): `{["木火"]="燃", ["火土"]="锻", ...}`

4. **`Server/Modules/Utils.lua`**
   - `EdgeDistance(from, to)`, `SafeStatSync`, `AddPassive_Safe`, `contains`

5. **`Server/Modules/EventHandlers.lua`**
   - Skeleton: register `SavegameLoaded`, `StatusApplied`, `TimerFinished`, `LongRestFinished`, `LeveledUp`

6. **`Server/Modules/Systems/Debug.lua`**
   - Console commands to inspect/modify state

7. **`Public/XIUXIAN/ActionResourceDefinitions/ActionResourceDefinitions.lsx`**
   - `QiPoint` (气) — ReplenishType: LongRest
   - `ShenshiPoint` (神识) — ReplenishType: ShortRest

8. **`Public/XIUXIAN/Stats/Generated/Data/XIUXIAN_BASE.txt`**
   - Racial passive granting initial Qi/ShenShi

9. **`Public/XIUXIAN/Progressions/Progressions.lsx`**
   - Update L1 to grant racial passive(s)

10. **`Public/XIUXIAN/Lists/PassiveLists.lsx`** + **`SpellLists.lsx`**
    - L1 passive list, empty spell list

### Verification
- [x] Create character with XiuXian subrace
- [x] Qi and ShenShi resource bars appear
- [x] Tag applied
- [x] PersistentVars initializes on first load

---

## Phase 1: Meridian Graph & LingGen

**Goal:** 6-node graph, 15 meridians, LingGen values, behavioral experience. No walk execution yet.

### Files to create

1. **`Server/Modules/Systems/JingMai.lua`** — Core graph module
   - `PersistentVars['JINGMAI']` — 15 boolean meridian states
   - `JingMai.GetTier(element)` — LingGen value → T0/T1/T2/T3
   - `JingMai.EdgeDistance(from, to)` — distance formula
   - `JingMai.CanOpenMeridian(a, b)` — both LingGen ≥ 50
   - `JingMai.OpenMeridian(character, a, b)` — set state
   - `JingMai.GetOpenEdges()`, `JingMai.GetReachableFrom(node)`

2. **`Server/Modules/Systems/LingGen.lua`** — Spiritual root system
   - Stored as status turns: `XIUXIAN_LG_MU`, `XIUXIAN_LG_HUO`, `XIUXIAN_LG_TU`, `XIUXIAN_LG_JIN`, `XIUXIAN_LG_SHUI`
   - `LingGen.Awake(character)` — roll initial values
   - `LingGen.AddExperience(character, element, amount)`
   - `LingGen.GetAll(character)` — read all 5 values from status turns

3. **`Server/Modules/Systems/DanTian.lua`** — 丹田 & 识海 (Qi/ShenShi max pools)
   - Stored as status turns: `XIUXIAN_DANTIAN` (Qi max), `XIUXIAN_SHIHAI` (ShenShi max)
   - Base values set by realm breakthroughs
   - Special expansion: 大周天运转(+1/day), 丹药(+N), 吞噬精元(+1 on kill), 灵脉长休(+2)
   - 识海 expansion: 冥想(accumulate→+1), 精神淬炼(survive psychic→+1), 玉简(+1), 洞观历练(accumulate→+1)
   - `DanTian.SyncResources(character)` — sync actual Qi/ShenShi max to 丹田/识海 values via Osi.AddBoosts

3. **`Server/Modules/Systems/XingWei.lua`** — Behavioral experience
   - 5 counters: `PersistentVars['XINGWEI']`
   - Combat event listeners:
     - `OnHeal` → 木之行
     - `OnDamage` / `IsKillingBlow` → 火之行
     - `OnAttacked` + no movement → 土之行
     - `IsCritical` / reaction used → 金之行
     - Status steal / polymorph → 水之行

4. **`Public/XIUXIAN/Stats/Generated/Data/XIUXIAN_JINGMAI.txt`**
   - 30 passives for directed edges (display-only initially)

### Verification
- [ ] LingGen values initialize on character creation
- [ ] Debug command shows 5 LingGen values and tiers
- [ ] Meridians open when conditions met
- [ ] Behavioral experience accumulates in combat

---

## Phase 2: Walk Engine & Edge Effects (T0)

**Goal:** Walk calculation engine + first batch of edge effects. Hand-crafted starter walks as real BG3 spells.

### Files to create

1. **`Server/Modules/Systems/WalkEngine.lua`** — Core calculator
   - `CalcWalkEffects(walk)` → `{edge_effects, node_effects, final_dist, final_effect}`
   - Layer 1: per-edge distance + effect lookup, `reaction_tier = min(tier_A, tier_B)`
   - Layer 2: intermediate node compound `(d_in + d_out) % 5`
   - Layer 3: `final_distance = (Σ all d) % 5`
   - `CalcCost(walk)` — ShenShi = Σ(distance), Qi = Σ(reaction_tier)
   - `ClassifyWalk(walk)` — chain vs cycle, bonus/action/ultimate

2. **`Server/Modules/Systems/EdgeEffects.lua`** — Effect table
   - `EDGE_EFFECTS[edge_name][tier]` = function(caster, target, tier)
   - T0 only for all 20 edges:
     - 燃 T0: 1d4 fire damage
     - 侵 T0: target AC-1
     - 灰 T0: lifesteal 15%
     - etc. (see idea.md edge effect table)

3. **`Public/XIUXIAN/Stats/Generated/Data/XIUXIAN_EFFECTS.txt`**
   - 20 status entries: `XIUXIAN_EDGE_RAN_T0`, `XIUXIAN_EDGE_DUAN_T0`, etc.

4. **`Public/XIUXIAN/Stats/Generated/Data/XIUXIAN_WALKS.txt`**
   - 5-10 starter walk spells:
     - `XIUXIAN_Walk_Ran` (木→火, Bonus Action)
     - `XIUXIAN_Walk_Duan` (金→木, Bonus Action)
     - `XIUXIAN_Walk_MieRong` (水→火→金, Action)
     - `XIUXIAN_Walk_ZiQin` (水→木→土, Action)
   - Use `UseCosts` with QiPoint and ShenshiPoint

### Verification
- [ ] 2-node walks work as Bonus Actions
- [ ] 3-node walks work as Actions
- [ ] Edge effects apply correct statuses/damage
- [ ] Qi and ShenShi consumed
- [ ] Walks fail if required meridian not open

---

## Phase 3: Dynamic Walk Builder & ImGui UI

**Goal:** ImGui panel for constructing custom walks. Runtime spell generation from walk definitions.

### Files to create

1. **`Server/Modules/Systems/WalkBuilder.lua`** — Walk management
   - `PersistentVars['WALKS']` — saved walk definitions
   - `PersistentVars['ACTIVE_PASSIVES']` — active passive walks with reserved ShenShi
   - `RegisterAsSkill(character, walk)` — `Ext.Stats.Create()` + `Ext.Loca.UpdateTranslatedString()` + `Ext.Stats.Sync()` + `Osi.AddSpell()`
   - `RegisterAsPassive(character, walk)` — create passive, reserve ShenShi
   - Auto-naming: edge names + suffix (式/诀/律)

2. **`Server/Modules/Systems/ImGuiPanel.lua`** — ImGui UI
   - Pentagon + center node layout via `DrawList:AddCircleFilled`
   - Colored arrows: green=生, red=克, purple=侮, gray=泄, gold=共鸣
   - Solid (open) vs dashed (closed) meridians
   - Click-to-add-node walk construction
   - Real-time cost/effect preview
   - Buttons: [确认为技能] [成环为被动] [清除]
   - Active passives list with toggle
   - Resource display (ShenShi/Qi)

3. **`Public/XIUXIAN/Stats/Generated/Data/XIUXIAN_TEMPLATES.txt`** — Template stats
   - `XIUXIAN_WalkTemplate_BonusAction` — base for 2-node
   - `XIUXIAN_WalkTemplate_Action` — base for 3-node
   - `XIUXIAN_WalkTemplate_Ultimate` — base for 4+
   - `XIUXIAN_WalkTemplate_Passive` — base for cycles

### Verification
- [ ] ImGui panel opens via hotkey/spell
- [ ] Click nodes to build walk path
- [ ] Walk validated against open meridians
- [ ] [确认为技能] creates real spell in spellbook
- [ ] Passive walks reserve ShenShi
- [ ] Walks survive save/load

---

## Phase 4: Cultivation Realms — 炼气/筑基/金丹

**Goal:** First three realms with breakthrough mechanics and real progression.

### Files to create

1. **`Server/Modules/Systems/JingJie.lua`** — Realm system
   - `PersistentVars['JINGJIE']` — current realm per character
   - **炼气期:** 5 nodes, walk depth ≤ 3, no ShenShi
   - **筑基期:** +丹田 as neutral hub, 5 DanTian meridians, depth ≤ 5
     - Breakthrough: all LingGen ≥ T0 (25) + behavioral XP threshold
   - **金丹期:** 丹田 crystallizes with chosen element (irreversible), full distance formula, depth ≤ 8, ShenShi = JinDan tier
     - Breakthrough: one LingGen ≥ T1 (100) + total behavioral XP

2. **`Server/Modules/Systems/Breakthrough.lua`** — Breakthrough events
   - Condition checking
   - Choice UI (金丹 element selection)
   - Permanent changes

3. **`Public/XIUXIAN/Stats/Generated/Data/XIUXIAN_JINGJIE.txt`**
   - `XIUXIAN_JingJie_LianQi` — basic racial passive
   - `XIUXIAN_JingJie_ZhuJi` — DanTian unlock
   - `XIUXIAN_JingJie_JinDan` — full distance unification

4. **Update `Progressions.lsx`** — L5 (筑基), L9 (金丹) entries

### Verification
- [ ] Start in 炼气 with limited walks
- [ ] 筑基 unlocks DanTian + more paths
- [ ] 金丹 breakthrough prompts element choice
- [ ] DanTian edges use real distance after 金丹
- [ ] ShenShi appears after 金丹

---

## Phase 5: T1/T2/T3 Edge Effects & Passive Cycles

**Goal:** Full edge effect tiers. Passive cycle execution.

### Files to modify

1. **`Server/Modules/Systems/EdgeEffects.lua`** — Expand to all tiers
   - T1: moderate effects (see idea.md tables)
   - T2: strong with qualitative changes
   - T3: extreme with cooldowns
   - Total: ~80 implementations (20 edges × 4 tiers)

2. **`Public/XIUXIAN/Stats/Generated/Data/XIUXIAN_EFFECTS_T1.txt`**, **`T2.txt`**, **`T3.txt`**
   - Split across files to respect 4000-char stat field limit

3. **`Server/Modules/Systems/PassiveCycle.lua`** — Passive walk execution
   - On `ObjectTurnStarted`, iterate active passive walks
   - Execute edge effects in sequence
   - T3 edges fire every N rounds
   - Track ShenShi reservation

### Verification
- [ ] Effects scale noticeably with tier
- [ ] T3 effects have cooldowns
- [ ] Passive cycles fire at round start
- [ ] Multiple passives limited by ShenShi pool
- [ ] Deactivating passive returns ShenShi

---

## Phase 6: GongFa & Natural Essences

**Goal:** Complete the core gameplay loop with cultivation methods and organ-modifying essences.

### Files to create

1. **`Server/Modules/Systems/GongFa.lua`** — Cultivation methods
   - Data: `{node_modifiers, edge_modifiers, fold_rule, unlock}`
   - `PersistentVars['GONGFA']` — equipped per character
   - Internal crystallization: track walk counts → auto-crystallize
   - External: jade slip items
   - Modify `WalkEngine.CalcWalkEffects` to apply GongFa modifiers
   - Element matching: GongFa vs JinDan = bonus/penalty

2. **`Server/Modules/Systems/TianRanJingHua.lua`** — Natural essences
   - 25 essences (5 per element: T1/T1/T2/T2/T3)
   - `PersistentVars['JINGHUA']` — one slot per organ
   - Modify walk engine when walk passes through enhanced node
   - Acquisition via quest/combat/exploration triggers

3. **`Public/XIUXIAN/Stats/Generated/Data/XIUXIAN_GONGFA.txt`** — Starter GongFa items
4. **`Public/XIUXIAN/Stats/Generated/Data/XIUXIAN_JINGHUA.txt`** — 25 essence statuses

5. **Update ImGui panel** — Show GongFa modifiers on graph, essence icons on nodes, crystallization progress

### Verification
- [ ] GongFa changes walk calculation visibly
- [ ] Same path → different effects with/without GongFa
- [ ] Essences boost organ tier permanently
- [ ] Crystallization triggers after repeated walk usage
- [ ] Full loop: fight → XP → meridians → walks → crystallize → stronger walks

---

## Phase 7: Advanced Realms — 元婴/化神

**Goal:** Parallel walks and dual-layer graph.

### Files to modify

1. **`Server/Modules/Systems/JingJie.lua`** — Add realms:
   - **元婴期:** 7th node, parallel walk, ShenShi = YuanYing tier
   - **化神期:** 12 nodes (physical + spiritual mirror), cross-layer walk

2. **`Server/Modules/Systems/WalkEngine.lua`** — Extend:
   - Parallel walk execution (two independent walks)
   - Cross-layer edges: same-organ = d=0, different-organ = normal

3. **`Server/Modules/Systems/JingMai.lua`** — Expand graph to 7/12 nodes

4. **Update ImGui panel** — 7th node, dual-layer visualization, parallel walk UI

### Verification
- [ ] 元婴 adds 7th node + parallel walk slot
- [ ] Two walks execute simultaneously
- [ ] 化神 doubles graph to 12 nodes
- [ ] Cross-layer walks follow correct distance rules

---

## Phase 8: FaBao, ZhenFa & Late-Game Realms

**Goal:** Complete the design vision. Sub-phases are independent.

### 8a: FaBao (Magical Artifacts)
- External nodes attaching to organs
- Refinement process (open artifact-organ meridians)
- Simple (single node) → complex (internal sub-graph)
- Walk extension through artifact nodes

### 8b: ZhenFa (Formations)
- Multi-character spatial graph (8 trigram positions)
- Party-wide walk execution
- Formation types: line/ring/star/full

### 8c: Late Realms
- **炼虚:** walk through enemy nodes (target routing: self/enemy/ally)
- **合体:** environment nodes (天/地), fold_rule min→max
- **大乘:** FaXiang (graph clone as summon entity)
- **渡劫:** adversarial walk collision `(your_d + tiandao_d) % 5`
- **真仙:** void node (player-chosen distance 0-4)

---

## Technical Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Stat field length limit (~4000 chars) | Split passives across multiple stat entries per tier |
| `Ext.Stats.Create` + `Sync` performance | Cache in PersistentVars; only recreate on load/change |
| Save/Load persistence | All state in PersistentVars; restore on `SavegameLoaded` timer |
| ImGui feature gaps | Keep default view simple; detail on demand |
| Combat event timing | Use `ObjectTurnStarted` not `CombatRoundStarted` for passives |
| Walk validation | Always validate against open meridians before execution |
