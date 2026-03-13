# Architecture — 种族·谪仙「三仙归人」
<!-- Last updated: 2026-03-13 -->

## Mod Identity
- **Mod folder**: `XSS_BANXIAN`
- **ModuleUUID**: (defined in `Mods/XSS_BANXIAN/meta.lsx`)
- **Display name**: 种族·谪仙「三仙归人」 (Race: Exiled Immortal [Three Immortals])
- **Type**: Race mod — adds 3 immortal race variants (天仙 TianXian, 妖仙 YaoXian, 人仙 RenXian) with deep cultivation mechanics

## File Tree

### Stats (`.txt` under `Public/XSS_BANXIAN/Stats/Generated/`)
| File | Lines | Purpose |
|---|---|---|
| `Data/BANXIAN_BASE.txt` | ~1000 | Base stats shared across all 3 races |
| `Data/BANXIAN_TIAN.txt` | 765 | TianXian-specific stats (ZhouTian, GongFa base) |
| `Data/BANXIAN_YAO.txt` | 683 | YaoXian-specific stats (BenXiang, DevilForms) |
| `Data/BANXIAN_REN.txt` | 2226 | RenXian-specific stats (LingGen boosts, WZPLG, WZCYG) |
| `Data/DADAO.txt` | 1676 | DaDao paths (DaoHeng, JianDao, YiDao, HeHuan, etc.) |
| `Data/DANYAO.txt` | 1005 | Alchemy pills and recipes |
| `Data/FABAO.txt` | 916 | Magic weapons/artifacts (FaBao system) |
| `Data/XIULIAN.txt` | 183 | Cultivation training spells |
| `Data/SHENSHI.txt` | 252 | Divine sense (Shenshi) system |
| `Data/SHENTONG.txt` | 203 | Supernatural abilities (72/36-change polymorphs) |
| `Data/ZHENFA.txt` | 636 | Formation arrays (ZhenFa) |
| `Data/GONGFA_SELECTOR.txt` | — | GongFa progression selectors |
| `Data/DIFFICULTY.txt` | — | Hardcore/difficulty mode stats |
| `Data/BOOK.txt` | — | Book items |
| `Data/FIXS.txt` | 332 | Vanilla stat overrides/fixes |
| `Data/OVERRIDES.txt` | 113 | Additional vanilla overrides |
| `SpellSet.txt` | — | Spell set definitions |
| `Equipment.txt` | — | Equipment templates |
| `ItemCombos.txt` | — | Item combination recipes (alchemy) |

### Lua (under `Mods/XSS_BANXIAN/ScriptExtender/Lua/`)
| File | Purpose |
|---|---|
| `BootstrapServer.lua` | Entry point; initializes PersistentVars |
| `BootstrapClient.lua` | Client-side: receives net messages for dynamic overhead text |
| `Server/Main.lua` | Requires all modules, calls Init() |
| `Server/Modules/Variables.lua` | Constants, tables, config data |
| `Server/Modules/EventHandlers.lua` | Osiris event registrations and dispatchers |
| `Server/Modules/Utils.lua` | Shared utility functions (Get, BanXian, DaDao helpers) |
| `Server/Modules/Systems/Base.lua` | Core mechanics (DualAttack, Transform/polymorph) |
| `Server/Modules/Systems/LingGen.lua` | Spiritual root assignment and effects |
| `Server/Modules/Systems/DaoHeng.lua` | DaDao path mechanics (DiYu, HeHuan, Jian, Yi, TianLei) |
| `Server/Modules/Systems/FaBao.lua` | Magic weapon refinement and passives |
| `Server/Modules/Systems/GongFa.lua` | Cultivation technique selection |
| `Server/Modules/Systems/DanYao.lua` | Alchemy pill crafting and effects |
| `Server/Modules/Systems/XiuLian.lua` | Cultivation training resource allocation |
| `Server/Modules/Systems/ShenShi.lua` | Divine sense level calculation |
| `Server/Modules/Systems/ZhenFa.lua` | Formation array management |
| `Server/Modules/Systems/Difficulty.lua` | Hardcore mode NPC cultivation |

### KHN (thoth condition scripts)
| File | Purpose |
|---|---|
| `Scripts/thoth/helpers/XSS_BANXIAN.khn` | All condition functions for stat Conditions/BoostConditions fields |

### LSX (structure/data)
| File | Purpose |
|---|---|
| `Mods/XSS_BANXIAN/meta.lsx` | Mod metadata |
| `Public/XSS_BANXIAN/Races/Races.lsx` | 7069 lines; race definitions |
| `Public/XSS_BANXIAN/CharacterCreation/RENXIAN.lsx` | 19934 lines; RenXian CC |
| `Public/XSS_BANXIAN/CharacterCreation/TIANXIAN.lsx` | 19934 lines; TianXian CC |
| `Public/XSS_BANXIAN/CharacterCreation/YAOXIAN.lsx` | 19934 lines; YaoXian CC |
| `Public/XSS_BANXIAN/CharacterCreation/CharacterCreationAppearanceVisuals.lsx` | 59784 lines; visual presets |
| `Public/XSS_BANXIAN/Progressions/Progressions.lsx` | Level-up progressions |
| `Public/XSS_BANXIAN/Progressions/ProgressionDescriptions.lsx` | Progression descriptions |
| `Public/XSS_BANXIAN/Lists/SpellLists.lsx` | Spell list definitions |
| `Public/XSS_BANXIAN/Lists/PassiveLists.lsx` | Passive list definitions |
| `Public/XSS_BANXIAN/Feats/Feats.lsx` | Feat definitions |
| `Public/XSS_BANXIAN/Feats/FeatDescriptions.lsx` | Feat descriptions |
| `Public/XSS_BANXIAN/ActionResourceDefinitions/ActionResourceDefinitions.lsx` | ShenshiPoint resource |
| `Public/XSS_BANXIAN/Levelmaps/LevelMapValues.lsx` | BanXianDice, BanXianHP, etc. |
| `Public/XSS_BANXIAN/Shapeshift/Rulebook.lsx` | Polymorph rules |
| `Public/XSS_BANXIAN/RootTemplates/_merged.lsf.lsx` | 2372 lines; 96 GameObjects |
| `Public/XSS_BANXIAN/Tags/*.lsx` | Custom tags (TIANXIAN, RENXIAN, NOSOUL) |
| `Public/XSS_BANXIAN/Hints/Hints.lsx` | Tooltip hints |
| `Public/XSS_BANXIAN/ErrorDescriptions/ConditionErrors.lsx` | Custom error messages |
| `Public/XSS_BANXIAN/GUI/newAtlas.lsx` | Icon atlas |
| `Public/XSS_BANXIAN/CharacterCreationPresets/CharacterCreationPresets.lsx` | CC presets |

### Localization
| File | Purpose |
|---|---|
| `Mods/XSS_BANXIAN/Localization/English/XSS_BANXIAN.xml` | ~993 entries; all display strings |
| `Mods/XSS_BANXIAN/Localization/zhexian_Books.lsx` | Book content |

### Config
| File | Purpose |
|---|---|
| `Mods/XSS_BANXIAN/ScriptExtender/Config.json` | SE config |

### Visual/Asset files (low priority for logic audit)
- `Public/XSS_BANXIAN/MultiEffectInfos/` — ~20 VFX info files
- `Public/XSS_BANXIAN/Assets/Effects/` — ~12 effect bank LSX files
- `Public/XSS_BANXIAN/Content/` — 6 asset/visual LSX files
- `Public/Game/GUI/metadata.lsx` — texture metadata

## Naming Conventions
- **Stat prefixes**: `BANXIAN_` for shared, `BANXIAN_TIAN_`/`BANXIAN_YAO_`/`BANXIAN_REN_` for race-specific
- **DaDao paths**: `MODE_BANXIAN_DH_<PATH>_TECHNICAL` for toggle passives
- **Signals**: `SIGNAL_DH_*` for Lua event triggers
- **LevelMapValues**: `BanXianDice`, `BanXianHP`, `BanXianAbilityBonus`, `BanXianCantrip`, `CriticalBanXianDice`
- **PersistentVars keys**: UUID-keyed for per-character data, `FABAO_*` for weapon state, `BANXIANLIST_NO_*` for NPC tracking
