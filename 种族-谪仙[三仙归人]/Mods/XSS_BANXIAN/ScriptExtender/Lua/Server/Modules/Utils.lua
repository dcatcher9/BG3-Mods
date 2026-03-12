
local Utils = {
    Get = {},
    CharacterChange = {},
    CharacterChangeCancel = {},
    Filter = {
        Status = {}
    },
    DaDao = {},
    ShenShi = {},
    LingGen = {},
    ZhenFa = {},
    GongFa = {
        BaiMai = {}
    },
    Difficulty = {},
    BanXian = {}
}
local Variables = require("Server.Modules.Variables")

--错误处理
function Utils.SafeStatSync(stat)
    local success, err = pcall(function()
        if stat and stat.Sync then
            stat:Sync()
        else
            error("无效的stat对象或缺少Sync方法")
        end
    end)

    if not success then
        -- 详细记录错误信息
        local statName = "未知"
        if stat and stat.Name then
            statName = stat.Name
        end
        Ext.Utils.PrintError(string.format(
            "[FaBao] 同步状态失败: %s | 错误: %s",
            statName,
            tostring(err)
        ))
        return false
    end
    return true
end

--属性设置安全包装
function Utils.SafeSetStatProperty(stat, prop, value)
    local success, err = pcall(function()
        stat[prop] = value
    end)

    if not success then
        Ext.Utils.PrintError(string.format(
            "[FaBao] 设置属性失败 [%s.%s]: %s",
            stat.Name or "未知",
            prop,
            tostring(err)
        ))
        return false
    end
    return true
end

-- 检查表中指定范围内是否存在某个值
function Utils.contains(tbl, value, startIndex, endIndex)
    startIndex = startIndex or 1
    endIndex = endIndex or #tbl
    for i = startIndex, endIndex do
        if tbl[i] == value then
            return true
        end
    end
    return false
end

-- Fisher-Yates 洗牌算法
function Utils.shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

--取一位精度
function Utils.TakePoint(num, value)
    local result = num - (num % value)
    return result
end

--获取位置参数
function Utils.GetXZ(object)
    local x, _, z = Osi.GetPosition(object)
    return x,z
end

--计算方位
function Utils.XZGetTowards(x,z)
    -- 处理原点情况
    if x == 0 and z == 0 then
        return "原点"
    end

    -- 处理坐标轴正方向的情况
    if x == 0 then
        return z > 0 and "北" or "南"
    elseif z == 0 then
        return x > 0 and "东" or "西"
    end

    -- 计算斜率（注意处理 x=0 已在上方排除）
    local radian = math.atan(z / x)
    local theta = math.deg(radian)

    -- 根据象限修正角度
    if x < 0 then
        theta = theta + 180  -- 第二、第三象限调整
    elseif z < 0 then
        theta = theta + 360  -- 第四象限调整
    end

    -- 确保角度在 [0, 360) 范围内
    theta = theta % 360

    -- 判断方位
    if theta >= 337.5 or theta < 22.5 then
        return "东"
    elseif theta >= 22.5 and theta < 67.5 then
        return "东北"
    elseif theta >= 67.5 and theta < 112.5 then
        return "北"
    elseif theta >= 112.5 and theta < 157.5 then
        return "西北"
    elseif theta >= 157.5 and theta < 202.5 then
        return "西"
    elseif theta >= 202.5 and theta < 247.5 then
        return "西南"
    elseif theta >= 247.5 and theta < 292.5 then
        return "南"
    else
        return "东南"
    end

end

--获取境界值（基于道行总天数，取共享 BANXIAN_DH_DAY 换算年数）
-- 阈值参考：修罗道 level10 TZ=1 约36杀/年，完整流程约27~55年
function Utils.GetBanxianJingjie(Character)
    local year = math.floor((Osi.GetStatusTurns(Character, 'BANXIAN_DH_DAY') or 0) / 365)

    if     year < 5    then return 1  -- 练气
    elseif year < 20   then return 2  -- 筑基
    elseif year < 60   then return 3  -- 结丹
    elseif year < 150  then return 4  -- 元婴
    elseif year < 400  then return 5  -- 化神
    elseif year < 1000 then return 6  -- 炼虚
    elseif year < 3000 then return 7  -- 合体
    elseif year < 8000 then return 8  -- 大乘
    elseif year < 20000 then return 9 -- 渡劫
    else                return 10     -- 真仙
    end
end

--拆分字符
function Utils.Seprate_Strings(PASSIVES)
    local Strings = {}
    for passive in string.gmatch(PASSIVES, "[^;]+") do
        -- 移除首尾空格
        local cleaned = passive:match("^%s*(.-)%s*$")
        table.insert(Strings, cleaned)
    end

    return Strings
end

-------------------------------------------------------------------------------------------------
--                                                                                             --
--                                         Add                                             --
--                                                                                             --
-------------------------------------------------------------------------------------------------
--添加被动
function Utils.AddPassive_Safe(Entity, PassiveID)
    if Osi.HasPassive(Entity, PassiveID) == 0 then
        Osi.AddPassive(Entity, PassiveID)
    end
end

-------------------------------------------------------------------------------------------------
--                                                                                             --
--                                         CharacterChange                                                 --
--                                                                                             --
-------------------------------------------------------------------------------------------------
--角色更改·装备
function Utils.CharacterChange.Equipable(Object)
    if Ext.Entity.Get(Object) ~= nil then
        PersistentVars['HEHUAN_FOLLOWER_DisableEquipping_'..Object] = Ext.Entity.Get(Object).ServerCharacter.Template.DisableEquipping
        PersistentVars['HEHUAN_FOLLOWER_IsEquipmentLootable_'..Object] = Ext.Entity.Get(Object).ServerCharacter.Template.IsEquipmentLootable
        PersistentVars['HEHUAN_FOLLOWER_IsLootable_'..Object] = Ext.Entity.Get(Object).ServerCharacter.Template.IsLootable
        Ext.Entity.Get(Object).ServerCharacter.Template.DisableEquipping = false
        Ext.Entity.Get(Object).ServerCharacter.Template.IsEquipmentLootable = true
        Ext.Entity.Get(Object).ServerCharacter.Template.IsLootable = true
    end
end

--取消角色更改·装备
function Utils.CharacterChangeCancel.Equipable(Object)
    if Ext.Entity.Get(Object) ~= nil then
        Ext.Entity.Get(Object).ServerCharacter.Template.DisableEquipping = PersistentVars['HEHUAN_FOLLOWER_DisableEquipping_'..Object]
        Ext.Entity.Get(Object).ServerCharacter.Template.IsEquipmentLootable = PersistentVars['HEHUAN_FOLLOWER_IsEquipmentLootable_'..Object]
        Ext.Entity.Get(Object).ServerCharacter.Template.IsLootable = PersistentVars['HEHUAN_FOLLOWER_IsLootable_'..Object]
    end
end

-------------------------------------------------------------------------------------------------
--                                                                                             --
--                                         Get                                                 --
--                                                                                             --
-------------------------------------------------------------------------------------------------
--  获取资质信息
function Utils.Get.ZiZhi(Character)
    local RESULT = "[灵根资质]: "

    local ZZ = Osi.GetStatusTurns(Character, 'BANXIAN_LG_TZ')

    --如果为0，更改输出结果
    if ZZ ~= nil then
        RESULT = RESULT..ZZ
    else
        RESULT = "[未开窍]"
    end

    return ZZ,RESULT
end

--  获取灵根信息
function Utils.Get.LingGen(Character)
    local RESULT = "[灵根配比]（满25点觉醒效果，满100点觉醒天灵根）: \n"
    local LingGenNum = {
        ["BANXIAN_LG_H"] = 0,
        ["BANXIAN_LG_T"] = 0,
        ["BANXIAN_LG_J"] = 0,
        ["BANXIAN_LG_S"] = 0,
        ["BANXIAN_LG_M"] = 0
    }

    --获取灵根
    for LG, NAME in pairs (Variables.Constants.LingGen) do
        LingGenNum[LG] = Osi.GetStatusTurns(Character, LG) or 0
        if LingGenNum[LG] >= 1 then
            RESULT = RESULT..NAME..": "..LingGenNum[LG].."点  "
        end
    end

    --如果为0，更改输出结果
    if RESULT == "[灵根配比]（满25点觉醒效果，满100点觉醒天灵根）: \n" then
        RESULT = "[缺失灵根]"
    end
    local LG_H,LG_T,LG_J,LG_S,LG_M = LingGenNum['BANXIAN_LG_H'],LingGenNum['BANXIAN_LG_T'],LingGenNum['BANXIAN_LG_J'],LingGenNum['BANXIAN_LG_S'],LingGenNum['BANXIAN_LG_M']

    return LG_H,LG_T,LG_J,LG_S,LG_M,RESULT
end

--  获取大道信息（纯读取，不修改任何状态）
function Utils.Get.Dao(Character)
    local DaDAO, DaDao_Name
    local DaoList = {}
    local RESULT = '[未领悟大道]'

    local DaoDaySuffix = {
        ['BanXian_DH_Tian']     = 'TIAN',
        ['BanXian_DH_XiuLuo']   = 'XIULUO',
        ['BanXian_DH_RenJian']  = 'RENJIAN',
        ['BanXian_DH_ChuSheng'] = 'CHUSHENG',
        ['BanXian_DH_EGui']     = 'EGUI',
        ['BanXian_DH_DiYu']     = 'DIYU',
        ['BanXian_DH_Jian']     = 'JIAN',
        ['BanXian_DH_Li']       = 'LI',
        ['BanXian_DH_HeHuan']   = 'HEHUAN',
        ['BanXian_DH_Yi']       = 'YI',
    }

    --获取大道（遍历全部，不提前退出）
    for ID, NAME in pairs (Variables.Constants.DaDao) do
        if Osi.HasPassive(Character,ID) == 1 then
            DaDAO,DaDao_Name = ID,NAME
            local entry = NAME
            local suffix = DaoDaySuffix[ID]
            if suffix then
                local days  = Osi.GetStatusTurns(Character, 'BANXIAN_DH_DAY_'..suffix) or 0
                local years = math.floor(days / 365)
                local rem   = days - years * 365
                if years > 0 and rem > 0 then
                    entry = NAME.."("..years.."年"..rem.."日)"
                elseif years > 0 then
                    entry = NAME.."("..years.."年)"
                elseif rem > 0 then
                    entry = NAME.."("..rem.."日)"
                end
            end
            table.insert(DaoList, entry)
        end
    end

    if #DaoList > 0 then
        RESULT = "[大道]: "..table.concat(DaoList, "、")
    end

    --获取修为（总天数转换为年+天显示）
    local DH_TOTAL = Osi.GetStatusTurns(Character, 'BANXIAN_DH_DAY') or 0
    local DH_YEAR  = math.floor(DH_TOTAL / 365)
    local DH_DAY   = DH_TOTAL - DH_YEAR * 365

    if DH_YEAR ~= 0 then
        RESULT = RESULT.."  修为："..DH_YEAR.."年  "
    end
    if DH_DAY ~= 0 then
        if DH_YEAR ~= 0 then
            RESULT = RESULT..DH_DAY.."日  "
        else
            RESULT = RESULT.."  修为："..DH_DAY.."日  "
        end
    end

    return DaDAO,DaDao_Name,DH_YEAR,DH_DAY,RESULT
end

--获取资源点
function Utils.Get.ActionResource(Object,ResourceID)
    local entity = Ext.Entity.Get(Object)
    if not entity then return 0 end
    --_D(entity:GetAllComponents()) --DEBUG
    --_D(entity.ActionResources) --DEBUG
    if entity.ActionResources.Resources[ResourceID] then
        return math.floor(entity.ActionResources.Resources[ResourceID][1].Amount)
    else
        return 0
    end
end

--获取最大资源点
function Utils.Get.ActionResourceMax(Object,ResourceID)
    local entity = Ext.Entity.Get(Object)
    if not entity then return 0 end
    --_D(entity:GetAllComponents()) --DEBUG
    --_D(entity.ActionResources) --DEBUG
    if entity.ActionResources.Resources[ResourceID] then
        return math.floor(entity.ActionResources.Resources[ResourceID][1].MaxAmount)
    else
        return 0
    end
end

--获取资源类型
function Utils.Get.ActionResourceCooldown(Object,ResourceID)
    local entity = Ext.Entity.Get(Object)
    if not entity then return nil end
    --_D(entity:GetAllComponents()) --DEBUG
    if entity.ActionResources.Resources[ResourceID] then
        return math.floor(entity.ActionResources.Resources[ResourceID][1].ReplenishType)
    else
        return nil
    end
end

--获取最大临时生命值
function Utils.Get.MaxTemporaryHp(Object)
    local entity = Ext.Entity.Get(Object)
    if not entity then return 0 end
    --_D(entity:GetAllComponents())
    return math.floor(entity.Health.MaxTemporaryHp)
end

--获取临时生命值
function Utils.Get.TemporaryHp(Object)
    local entity = Ext.Entity.Get(Object)
    if not entity then return 0 end
    --_D(entity:GetAllComponents())
    return math.floor(entity.Health.TemporaryHp)
end

--获取最高法术位
function Utils.Get.MaxSpellSlotPower(Object)
    local entity = Ext.Entity.Get(Object)
    if not entity then return 0 end
    local SpellSlots = entity.ActionResources.Resources['d136c5d9-0ff0-43da-acce-a74a07f8d6bf']
    if not SpellSlots then return 0 end
    local MaxPower = 0
    --_D(SpellSlots) --DEBUG
    for _, SPELLSLOT in pairs(SpellSlots) do
        --_D(SPELLSLOT) --DEBUG
        if SPELLSLOT['Level'] > MaxPower and SPELLSLOT['MaxAmount'] >= 1 then
            MaxPower = SPELLSLOT['Level']
        end
    end
    return MaxPower
end

--获取法术位信息
function Utils.Get.SpellSlotsTable(Object)
    local entity = Ext.Entity.Get(Object)
    if not entity then return {}, 0 end
    local SpellSlots = entity.ActionResources.Resources['d136c5d9-0ff0-43da-acce-a74a07f8d6bf']
    if not SpellSlots then return {}, 0 end
    local SpellSlotsTable = {}
    local MaxPower = 0
    --_D(SpellSlots) --DEBUG
    for _, SPELLSLOT in pairs(SpellSlots) do
        if SPELLSLOT['MaxAmount'] >= 1 then
            SpellSlotsTable[SPELLSLOT['Level']] = SPELLSLOT
            if SPELLSLOT['Level'] > MaxPower then
                MaxPower = SPELLSLOT['Level']
            end
        end
    end
    return SpellSlotsTable, MaxPower
end

--获取大道被动（名称）
function Utils.Get.DaDaoPassive(Name)
    for DaDao, DaDaoName in pairs(Variables.Constants.DaDao) do
        if Name == DaDaoName then
            return DaDao
        end
    end
end

--获取大道名称（被动）
function Utils.Get.DaDaoName(Passive)
    for DaDao, DaDaoName in pairs(Variables.Constants.DaDao) do
        if Passive == DaDao then
            return DaDaoName
        end
    end
end

--获取业火来源
function Utils.Get.YeHuoSource(Object)
    local entity = Ext.Entity.Get(Object)
    if not entity then return nil end
    local Statuses = entity.ServerCharacter.StatusManager.Statuses
    --_D(Statuses) --DEBUG
    for _, Status in pairs(Statuses) do
        if Status.StatusId == "BURNING_YEHUO" then
            return Status.Cause.Uuid.EntityUuid
        end
    end
    return nil
end

--获取异火信息（支持多个）
function Utils.Get.YiHuo(Character)
    local FireNames = {
        ['BANXIAN_Fire_of_Gold']     = '黄金火',
        ['BANXIAN_Fire_of_Ghost']    = '鬼魂火',
        ['BANXIAN_Fire_of_ThreeMei'] = '三昧真火',
        ['BANXIAN_Fire_of_Purple']   = '紫色火',
        ['BANXIAN_Fire_of_SixDing']  = '六丁神火',
    }
    local found = {}
    for _, entry in pairs(Variables.Constants.Difficulty.YiHuo) do
        if Osi.HasActiveStatus(Character, entry.Fire) == 1 then
            table.insert(found, FireNames[entry.Fire] or entry.Fire)
        end
    end
    if #found == 0 then return nil, nil end
    return found, "[携带异火]: "..table.concat(found, "、")
end

--获取掉落预报
function Utils.Get.DropHint(Character)
    local BaoCai_Names = {
        [1]  = '大力铁角',
        [2]  = '妖生角',
        [3]  = '黑色眼眸',
        [4]  = '金色眼眸',
        [7]  = '龙珠',
        [8]  = '铁中血',
        [9]  = '玉锤牙',
        [10] = '震雷骨',
    }
    local drops = {}
    local Level = Osi.GetLevel(Character)

    -- 宝材（按 tag 判断）
    for _, item in ipairs(Variables.Constants.DanYao.DropProbabilities.BaoCai) do
        local name = BaoCai_Names[item.id]
        if name and item.tag and (not item.minlevel or Level >= item.minlevel) then
            local tagged = false
            for _, t in ipairs(item.tag) do
                if Osi.IsTagged(Character, t) == 1 then
                    tagged = true
                    break
                end
            end
            if tagged then
                drops[#drops+1] = name
            end
        end
    end

    -- 修士精元（有道行才可能掉）
    if Osi.HasActiveStatus(Character, 'BANXIAN_DH_YEAR') == 1 then
        if Osi.IsTagged(Character, '7fbed0d4-cabc-4a9d-804e-12ca6088a0a8') == 1 then
            drops[#drops+1] = '修士精元（类人）'
        else
            drops[#drops+1] = '修士精元（非类人）'
        end
    end

    if #drops == 0 then return nil end
    return "[可能掉落]: "..table.concat(drops, '、')
end

--获取重量
function Utils.GetEntityWeight(Object)
    local entity = Ext.Entity.Get(Object)
    if not entity then return 0 end
    --_D(entity:GetAllComponents()) --DEBUG
    local Weight = entity.Data.Weight

    return Weight
end

-------------------------------------------------------------------------------------------------
--                                                                                             --
--                                         Save                                              --
--                                                                                             --
-------------------------------------------------------------------------------------------------
-- WeaponFunctors无法从stat对象读回字符串（bg3se不提供GetRawAttribute）
-- 需传入FABAO名称以从PersistentVars读取已保存的值；未提供时返回""
function Utils.GetStatField(stat, TYPE, FABAO)
    if TYPE == "WeaponFunctors" then
        if FABAO then
            return PersistentVars['FABAO_Stats_WeaponFunctors_'..FABAO] or ""
        end
        return ""
    end
    return stat[TYPE]
end

function Utils.SetStatField(stat, TYPE, value)
    if TYPE == "WeaponFunctors" then
        stat:SetRawAttribute("WeaponFunctors", value)
    else
        stat[TYPE] = value
    end
end

--备份/保存所有炼器数据
function Utils.FaBao_LianQiSaveAllStats(prefix)
    for _, ID in ipairs(Ext.Stats.GetStats("Weapon")) do
        local stat = Ext.Stats.Get(ID)

        for TYPE, _ in pairs(Variables.Constants.FaBao.Weapon) do
            PersistentVars[prefix..ID.."_"..TYPE] = Utils.GetStatField(stat, TYPE)
        end
        PersistentVars[prefix..ID.."_Rarity"] = stat.Rarity
    end

    for _, ID in ipairs(Ext.Stats.GetStats("Armor")) do
        local stat = Ext.Stats.Get(ID)

        for TYPE, _ in pairs(Variables.Constants.FaBao.Base) do
            PersistentVars[prefix..ID.."_"..TYPE] = Utils.GetStatField(stat, TYPE)
        end
        PersistentVars[prefix..ID.."_Rarity"] = stat.Rarity
    end
end

--保存炼器数据
function Utils.FaBao_LianQiSaveStats(FABAO)
    local stat = Ext.Stats.Get(FABAO)
    local TYPE_TABLE = Variables.Constants.FaBao.Base
    -- 维护炼器列表索引，用于游戏加载时精准恢复（避免全量扫描所有武器/防具）
    if not PersistentVars[FABAO.."_IsFABAO"] then
        local k = 1
        while PersistentVars['FABAOLIST_NO_'..k] ~= nil do k = k + 1 end
        PersistentVars['FABAOLIST_NO_'..k] = FABAO
    end
    PersistentVars[FABAO.."_IsFABAO"] = true

    if stat['ModifierList'] == 'Weapon' then
        TYPE_TABLE = Variables.Constants.FaBao.Weapon
    end

    for TYPE, _ in pairs(TYPE_TABLE) do
        PersistentVars["[SaveStatsLianQi]"..FABAO.."_"..TYPE] = Utils.GetStatField(stat, TYPE, FABAO)
    end
    PersistentVars["[SaveStatsLianQi]"..FABAO.."_Rarity"] = stat.Rarity
end

-------------------------------------------------------------------------------------------------
--                                                                                             --
--                                         Load                                              --
--                                                                                             --
-------------------------------------------------------------------------------------------------

--读取炼器数据
function Utils.FaBao_LianQiLoadStats(FABAO)
    local stat = Ext.Stats.Get(FABAO)
    local TYPE_TABLE = Variables.Constants.FaBao.Base

    if stat['ModifierList'] == 'Weapon' then
        TYPE_TABLE = Variables.Constants.FaBao.Weapon
    end

    for TYPE, _ in pairs(TYPE_TABLE) do
        local value = PersistentVars["[SaveStatsLianQi]"..FABAO.."_"..TYPE]
        if value ~= nil then
            Utils.SetStatField(stat, TYPE, value)
        end
    end
    stat.Rarity = PersistentVars["[SaveStatsLianQi]"..FABAO.."_Rarity"]
    stat:Sync()

end

-------------------------------------------------------------------------------------------------
--                                                                                             --
--                                         ZhenFa                                              --
--                                                                                             --
-------------------------------------------------------------------------------------------------
--获取相对位置
function Utils.ZhenFa.GetInPosition(Flag,Core)
    local FX,FZ = Utils.GetXZ(Flag)
    local CX,CZ = Utils.GetXZ(Core)
    local dX,dZ = FX-CX,FZ-CZ
    return dX,dZ
end

--获取阵眼距离
function Utils.ZhenFa.GetCoreDistance(Flag,Core)
    local X,Z = Utils.ZhenFa.GetInPosition(Flag,Core)
    local Radius = Utils.TakePoint(math.sqrt(X*X + Z*Z),0.1)
    return Radius
end

--获取方位参数
function Utils.ZhenFa.GetFlagsTowards(Flag,Core)
    local X,Z = Utils.ZhenFa.GetInPosition(Flag,Core)
    local TW = Utils.XZGetTowards(X,Z)
    return TW
end

--计算阵旗参数
function Utils.ZhenFa.GetFlagsParams(Flag,Core)

    local X,Z = Utils.ZhenFa.GetInPosition(Flag,Core)
    local TW = Utils.ZhenFa.GetFlagsTowards(Flag,Core)
    local Radius = Utils.ZhenFa.GetCoreDistance(Flag,Core)

    return X,Z,TW,Radius
end

-------------------------------------------------------------------------------------------------
--                                                                                             --
--                                         LingGen                                             --
--                                                                                             --
-------------------------------------------------------------------------------------------------
--随机灵根
function Utils.LingGen.Random(_)
    local r, TZ = 100,1
    local z = math.random(1, 1000000)
    if z <= 5000 then         -- 0.5% 先天道体（T0）
        r, TZ = 200, math.random(6,10)
    elseif z <= 30000 then    -- 2.5% 大帝之资（T1）
        r, TZ = 100, math.random(3,5)
    elseif z <= 100000 then   -- 7% 先天慧根（T2）
        r, TZ = 40, 2
    elseif z <= 300000 then   -- 20% 平平无奇（T3）
        r, TZ = 20, 1
    else                      -- 70% 灵根破碎（NIL）
        r, TZ = 10, 1
    end
    return r, TZ
end

-------------------------------------------------------------------------------------------------
--                                                                                             --
--                                         ShenShi                                             --
--                                                                                             --
-------------------------------------------------------------------------------------------------
--刷新神识状态
function Utils.ShenShi.Check(Object)

    if Osi.HasPassive(Object, 'BANXIAN_Shenshi') == 1 then
        local k = Utils.Get.ActionResourceMax(Object,'0032115b-77c3-43c8-9385-630e657b2fcc')
        if Ext.Stats.Get('BanXian_SS_BOOST_'..k) ~= nil then
            Osi.ApplyStatus(Object, 'BanXian_SS_BOOST_'..k, -1, 1, Object)
        else
            local Stats = Ext.Stats.Create('BanXian_SS_BOOST_'..k, 'StatusData', 'BanXian_SS_BOOST')
            if k ~= 0 then
                Stats.Boosts = "IF(IsDamageTypePsychic()):DamageBonus("..k..",Psychic);DamageReduction(Psychic,Threshold,"..k..");Ability(Wisdom,"..k..")"
            end
            Stats:Sync()
            Osi.ApplyStatus(Object, 'BanXian_SS_BOOST_'..k, -1, 1, Object)
        end
    end

end

-------------------------------------------------------------------------------------------------
--                                                                                             --
--                                         DaDao                                             --
--                                                                                             --
-------------------------------------------------------------------------------------------------
--将共享DAY/YEAR同步为所有大道的最大值，并派生各大道YEAR供统计引擎使用
function Utils.DaDao.UpdateSharedDay(Character)
    local SUFFIXES = {'XIULUO','TIAN','RENJIAN','CHUSHENG','EGUI','DIYU','JIAN','LI','HEHUAN','YI'}
    local max_day  = 0
    local max_year = 0
    for _, suffix in ipairs(SUFFIXES) do
        local d = Osi.GetStatusTurns(Character, 'BANXIAN_DH_DAY_'  .. suffix) or 0
        local y = math.floor(d / 365)
        -- 保持各大道YEAR状态同步（统计引擎 .Duration 引用需要）
        local cur_y = Osi.GetStatusTurns(Character, 'BANXIAN_DH_YEAR_' .. suffix) or 0
        if y ~= cur_y then
            Osi.ApplyStatus(Character, 'BANXIAN_DH_YEAR_' .. suffix, y * 6, 1)
        end
        if d > max_day  then max_day  = d end
        if y > max_year then max_year = y end
    end
    local shared_day = Osi.GetStatusTurns(Character, 'BANXIAN_DH_DAY') or 0
    if max_day ~= shared_day then
        Osi.ApplyStatus(Character, 'BANXIAN_DH_DAY', max_day * 6, 1)
    end
    -- 保持共享YEAR同步（统计引擎HP加成、伤害加成、条件检测需要）
    local shared_year = Osi.GetStatusTurns(Character, 'BANXIAN_DH_YEAR') or 0
    if max_year ~= shared_year then
        Osi.ApplyStatus(Character, 'BANXIAN_DH_YEAR', max_year * 6, 1)
    end
end

--刷新大道增益（通用）：按年数动态创建并应用一个 Ability 加值状态
local function ApplyDaoDaoAbilityBoost(Object, daySuffix, passiveId, statusPrefix, abilityName)
    local DH_DAY = Osi.GetStatusTurns(Object, 'BANXIAN_DH_DAY_'..daySuffix)
    if DH_DAY == nil then return end
    local DH_YEAR = math.floor(DH_DAY / 365)
    if DH_YEAR >= 1 and Osi.HasPassive(Object, passiveId) == 1 and Osi.HasActiveStatus(Object, statusPrefix..'_'..DH_YEAR) == 0 then
        local statusName = statusPrefix..'_'..DH_YEAR
        if Ext.Stats.Get(statusName) == nil then
            local Stats = Ext.Stats.Create(statusName, 'StatusData', statusPrefix)
            Stats.Boosts = "Ability("..abilityName..","..DH_YEAR..")"
            Stats:Sync()
        end
        Osi.ApplyStatus(Object, statusName, -1, 1, Object)
    end
end

--刷新大道增益：力道
function Utils.DaDao.Li(Object)
    ApplyDaoDaoAbilityBoost(Object, 'LI', 'BanXian_DH_Li', 'BanXian_DH_STR', 'Strength')
end

--刷新大道增益：合欢道
function Utils.DaDao.Hehuan(Object)
    ApplyDaoDaoAbilityBoost(Object, 'HEHUAN', 'BanXian_DH_HeHuan', 'BanXian_DH_CHA', 'Charisma')
end

-------------------------------------------------------------------------------------------------
--                                                                                             --
--                                         GongFa                                             --
--                                                                                             --
-------------------------------------------------------------------------------------------------
--复制装备被动1
function Utils.GongFa.BaiMai.CopyPassives(Object)
    local Itemslot = Variables.Constants.Base.Itemslot

    if ( Ext.Entity.Get(Object).PassiveContainer.Passives ~= nil ) then

      --第1次检测被动（按对象UUID存储，避免多人同时触发时互相覆盖）
        local passives = {}
        local k = 1
      for _,entry in pairs(Ext.Entity.Get(Object).PassiveContainer.Passives) do
        local ID = entry.Passive.PassiveId
        passives[k] = ID
        k = k + 1
      end
      PersistentVars['BaiMai_Passives_'..Object] = passives

      --脱掉装备
      local items = {}
      local n = 1
      for _, slot in ipairs(Itemslot) do
        if Osi.GetEquippedItem(Object, slot) ~= nil then
            items[n] = Osi.GetEquippedItem(Object, slot)
            Osi.Unequip(Object, Osi.GetEquippedItem(Object, slot))
            n = n + 1
        end
      end
      PersistentVars['BaiMai_WNP_'..Object] = items

    end

end

--复制装备被动2
function Utils.GongFa.BaiMai.CopyPassives_2(Object)
    local passivesBefore = PersistentVars['BaiMai_Passives_'..Object] or {}
    local items = PersistentVars['BaiMai_WNP_'..Object] or {}

    local passivesAfter = {}
    local m = 1
    for _,entry in pairs(Ext.Entity.Get(Object).PassiveContainer.Passives) do
      local ID = entry.Passive.PassiveId
      passivesAfter[m] = ID
      m = m + 1
    end

    --寻找差异
    for _, entry in ipairs(passivesBefore) do
      local Passive_To_Copy = entry
      local IsWNP = true

      for _,Compare in ipairs(passivesAfter) do
          --_P("    比较"..Compare)
          --如果相同，则不是武器被动
          if Passive_To_Copy == Compare then
              IsWNP = false
          end
      end

      --没有找到相同，则是武器被动，添加
      if IsWNP == true then
        Osi.AddPassive(Object,Passive_To_Copy)
      end

    end

    --穿上装备
    for _, item_guid in ipairs(items) do
      Osi.Equip(Object, item_guid, 1, 1)
    end

    --清空临时储存表
    PersistentVars['BaiMai_Passives_'..Object] = nil
    PersistentVars['BaiMai_WNP_'..Object] = nil

end

--复制装备状态
function Utils.GongFa.BaiMai.CopyStatus(Object)

    if ( Ext.Entity.Get(Object):GetComponent("StatusContainer") ~= nil ) then

        for _,entry in pairs(Ext.Entity.Get(Object).StatusContainer.Statuses) do
            local stat = Ext.Stats.Get(entry.StatusID.ID, 0)
            if string.find(entry.StatusID.ID, 'TECHNICAL') then
              if ( stat.StatusType == "BOOST" ) then
                if ( string.find(stat.Boosts, "Invulnerable%(%)") == nil ) then
                    Osi.ApplyStatus(Object, entry.StatusID.ID, -1)
                    Ext.Utils.Print(("触发：百脉锻宝诀·吞宝·状态: %s"):format(entry.StatusID.ID))
                end
              end
            end
        end
    end

end

-------------------------------------------------------------------------------------------------
--                                                                                             --
--                                         DaoHeng                                             --
--                                                                                             --
-------------------------------------------------------------------------------------------------

--状态过滤器·特殊状态
function Utils.Filter.Status.IsSpecial(ID)
    local specialStatusPrefixes = Variables.Constants.Filter.Status.IsSpecialID
    local status = nil
    local flags = nil
    if Ext.Stats.Get(ID) ~= nil then
        status = Ext.Stats.Get(ID)
    end
    if status ~= nil and status.StatusPropertyFlags ~= nil then
        flags = status.StatusPropertyFlags
    end
    if flags ~= nil then
        for j, _ in pairs(flags) do
            --print(j, flags[j])
            if flags[j] == "DisablePortraitIndicator" then
                --_D(flags)
                return true
            end
        end
    end
    for _,key in pairs(specialStatusPrefixes) do
        if string.find(ID, key) then
            return true
        end
    end
    return false
end

--状态过滤器·DEBUFF
function Utils.Filter.Status.IsDebuff(ID)
    local debuffGroups = Variables.Constants.Filter.Status.EGuiDebuff
    local specialDebuffPrefixes = Variables.Constants.Filter.Status.EGuiDebuff_Special
    for _,key in pairs(debuffGroups) do
        if Osi.IsStatusFromGroup(ID, key) == 1 then
            return true
        end
    end
    for _,key in pairs(specialDebuffPrefixes) do
        if string.find(ID, key) then
            return true
        end
    end
    return false
end

--------------------------------------------------------------------------------------------------
---刷新境界增益：炼体周天（力量、体质、智力、敏捷、魅力、感知）
function Utils.BanXian.JingjieBoost(Object)
    local JJ = Utils.GetBanxianJingjie(Object)
    if not JJ then return end

    -- 累积加值：境界N获得前N级之和，即 2^N - 1
    local bonus = math.floor(2^JJ) - 1

    local abilityMap = {
        {passive = 'CuiTi_ZhouTian_2',  ability = 'Constitution', id = 'CON'},
        {passive = 'CuiTi_ZhouTian_3',  ability = 'Strength',     id = 'STR'},
        {passive = 'CuiTi_ZhouTian_7',  ability = 'Intelligence', id = 'INT'},
        {passive = 'CuiTi_ZhouTian_8',  ability = 'Dexterity',    id = 'DEX'},
        {passive = 'CuiTi_ZhouTian_9',  ability = 'Charisma',     id = 'CHA'},
        {passive = 'CuiTi_ZhouTian_10', ability = 'Wisdom',       id = 'WIS'},
    }

    for _, entry in ipairs(abilityMap) do
        if Osi.HasPassive(Object, entry.passive) == 1 then
            local statusName = 'BANXIAN_JJ_'..entry.id..'_'..JJ
            if Ext.Stats.Get(statusName) == nil then
                local Stats = Ext.Stats.Create(statusName, 'StatusData', 'BANXIAN_JJ_BOOST')
                Stats.Boosts = 'Ability('..entry.ability..','..bonus..')'
                Stats.StackId = 'BANXIAN_JJ_'..entry.id
                Stats:Sync()
            end
            Osi.ApplyStatus(Object, statusName, -1, 1, Object)
        end
    end

    -- 应用精确境界标记（用于周天运气施法消耗）
    local tierStatusName = 'BANXIAN_JJ_TIER_'..JJ
    if Ext.Stats.Get(tierStatusName) == nil then
        local TierStats = Ext.Stats.Create(tierStatusName, 'StatusData', 'BANXIAN_JJ_TIER')
        TierStats:Sync()
    end
    Osi.ApplyStatus(Object, tierStatusName, -1, 1, Object)

    -- 应用可见境界显示状态（UI图标）
    Osi.ApplyStatus(Object, 'BANXIAN_JJ_DISPLAY_'..JJ, -1, 1, Object)

    -- 应用累积到达标记（用于灵根技能解锁）
    for i = 1, 10 do
        if JJ >= i then
            local arriveStatusName = 'BANXIAN_JJ_ARRIVE_'..i
            if Ext.Stats.Get(arriveStatusName) == nil then
                local ArriveStats = Ext.Stats.Create(arriveStatusName, 'StatusData', 'BANXIAN_JJ_ARRIVE')
                ArriveStats.StackId = 'BANXIAN_JJ_ARRIVE_'..i
                ArriveStats:Sync()
            end
            Osi.ApplyStatus(Object, arriveStatusName, -1, 1, Object)
        end
    end
end

--记录谪仙名单
function Utils.BanXianList_AddtoList(Object)

    local k = 1
    while PersistentVars['BANXIANLIST_NO_'..k] ~= nil do
        if PersistentVars['BANXIANLIST_NO_'..k] == Object then
            return
        end
        k = k + 1
    end
    PersistentVars['BANXIANLIST_NO_'..k] = Object

end

--恢复谪仙数据
function Utils.BanXianList_RecoverStatsStart()

    local k = 1
    while PersistentVars['BANXIANLIST_NO_'..k] ~= nil do
        local Object = PersistentVars['BANXIANLIST_NO_'..k]
        Utils.DaDao.UpdateSharedDay(Object)
        Utils.DaDao.Hehuan(Object)
        Utils.DaDao.Li(Object)
        Utils.ShenShi.Check(Object)
        Utils.BanXian.JingjieBoost(Object)
        Osi.ApplyStatus(Object, 'SIGNAL_YLG_CHECK', 100, 0)
        --修正资质点（修复旧存档因NIL判断错误导致TZ=1的bug）
        local TZ = Osi.GetStatusTurns(Object, 'BANXIAN_LG_TZ') or 0
        if Osi.HasPassive(Object, 'BanXian_LingGen_T0') == 1 and TZ < 6 then
            Osi.ApplyStatus(Object, 'BANXIAN_LG_TZ', math.random(6,10) * 6)
        elseif Osi.HasPassive(Object, 'BanXian_LingGen_T1') == 1 and TZ < 3 then
            Osi.ApplyStatus(Object, 'BANXIAN_LG_TZ', math.random(3,5) * 6)
        elseif Osi.HasPassive(Object, 'BanXian_LingGen_T2') == 1 and TZ ~= 2 then
            Osi.ApplyStatus(Object, 'BANXIAN_LG_TZ', 12)
        end
        k = k + 1
    end

end

--勾选难度选择
function Utils.Difficulty.YesNoChoice()

    --勾选难度选项
    local Message_Difficulty_AGE = Variables.Constants.Difficulty.MessageBox.Age
    local Message_Difficulty_A1 = Variables.Constants.Difficulty.MessageBox.Age_1
    local Message_Difficulty_A2 = Variables.Constants.Difficulty.MessageBox.Age_2
    if PersistentVars['Difficulty_Result'] ~= 1 then
        Osi.OpenMessageBoxChoice(Osi.GetHostCharacter(), Message_Difficulty_AGE, Message_Difficulty_A1, Message_Difficulty_A2)
    end

end

return Utils
