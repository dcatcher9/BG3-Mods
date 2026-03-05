local Utils = {
    Get = {},
    CharacterChange = {},
    CharacterChangeCancle = {},
    Filter = {
        Status = {
        },
        Passives = {},
        Spells = {}
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

-- 工具函数示例
function Utils.GetRandomElement(tbl)
    return tbl[math.random(1, #tbl)]
end

_P("[Utils] Utils 模块加载完成！")



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


--获取境界值
function Utils.GetBnaxianJingjie(Character)
    local Level = Osi.GetLevel(Character)

    if Level >= 1 and Level < 5 then
        return 1
    elseif Level >= 5 and Level < 9 then
        return 2
    elseif Level >= 9 and Level < 13 then
        return 3
    elseif Level >= 13 and Level < 21 then
        return 4
    elseif Level >= 21 and Level < 41 then
        return 5
    elseif Level >= 41 and Level < 61 then
        return 6
    elseif Level >= 61 and Level < 81 then
        return 7
    elseif Level >= 81 and Level < 96 then
        return 8
    elseif Level >= 96 and Level < 100 then
        return 9
    elseif Level >= 100 then
        return 10
    end
end



--拆分字符
function Utils.Seprate_Strings(PASSIVES)
    local Strings = {}
    for passive in string.gmatch(PASSIVES, "[^;]+") do
        -- 移除首尾空格
        local cleaned = passive:match("^%s*(.-)%s*$")
        table.insert(Strings, cleaned)
        _P('[炼器分离词条]'..cleaned) --DEBUG
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
        _P('[PersistentVars]记录数据[HEHUAN_FOLLOWER_DisableEquipping_]') --DEBUG
        PersistentVars['HEHUAN_FOLLOWER_IsEquipmentLootable_'..Object] = Ext.Entity.Get(Object).ServerCharacter.Template.IsEquipmentLootable
        _P('[PersistentVars]记录数据[HEHUAN_FOLLOWER_IsEquipmentLootable_]') --DEBUG
        PersistentVars['HEHUAN_FOLLOWER_IsLootable_'..Object] = Ext.Entity.Get(Object).ServerCharacter.Template.IsLootable
        _P('[PersistentVars]记录数据[HEHUAN_FOLLOWER_IsLootable_]') --DEBUG
        Ext.Entity.Get(Object).ServerCharacter.Template.DisableEquipping = false
        Ext.Entity.Get(Object).ServerCharacter.Template.IsEquipmentLootable = true
        Ext.Entity.Get(Object).ServerCharacter.Template.IsLootable = true
    end
end

--取消角色更改·装备
function Utils.CharacterChangeCancle.Equipable(Object)
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
    local RESULT = "[灵根配比]（满10点觉醒效果，满50点觉醒天灵根）: \n"

    --获取灵根
    for LG, NAME in pairs (Variables.Constants.LingGen) do
        Variables.Constants.LingGenNum[LG] = Osi.GetStatusTurns(Character, LG) or 0
        if Variables.Constants.LingGenNum[LG] >= 1 then
            RESULT = RESULT..NAME..": "..Variables.Constants.LingGenNum[LG].."点  "
        end
    end

    --如果为0，更改输出结果
    if RESULT == "[灵根配比]（满10点觉醒效果，满50点觉醒天灵根）: \n" then
        RESULT = "[缺失灵根]"
    end
    local LG_H,LG_T,LG_J,LG_S,LG_M = Variables.Constants.LingGenNum['BANXIAN_LG_H'],Variables.Constants.LingGenNum['BANXIAN_LG_T'],Variables.Constants.LingGenNum['BANXIAN_LG_J'],Variables.Constants.LingGenNum['BANXIAN_LG_S'],Variables.Constants.LingGenNum['BANXIAN_LG_M']
    
    return LG_H,LG_T,LG_J,LG_S,LG_M,RESULT
end

--  获取大道信息
function Utils.Get.Dao(Character)
    local DaDAO, DaDao_Name, DaoHen, DaoHen_Name, DaoHen_Year
    local RESULT = '[未领悟大道]'

    --获取大道
    for ID, NAME in pairs (Variables.Constants.DaDao) do
        if Osi.HasPassive(Character,ID) == 1 then
            DaDAO,DaDao_Name = ID,NAME
            RESULT = "[大道]: "..DaDao_Name
            break
        else
        end
    end

    --获取修为
    local DH_YEAR,DH_DAY = Osi.GetStatusTurns(Character, 'BANXIAN_DH_YEAR'),Osi.GetStatusTurns(Character, 'BANXIAN_DH_DAY')

    if DH_DAY >= 365 then
        local increase_year = math.floor(DH_DAY/365)
        DH_DAY = DH_DAY-increase_year*365
        DH_YEAR = DH_YEAR+increase_year
        Osi.ApplyStatus(Character,'BANXIAN_DH_DAY', DH_DAY*6)
        Osi.ApplyStatus(Character,'BANXIAN_DH_YEAR', DH_YEAR*6)
        _P('修为精进1年')
    end

    --_P(DH_YEAR)
    if DH_YEAR ~= nil then
        if DH_YEAR ~= 0 then
            RESULT = RESULT.."  修为："..DH_YEAR.."年  "
        end
    end
    --_P(DH_DAY)
    if DH_DAY ~= nil then
        if DH_YEAR ~= 0 then
            RESULT = RESULT..DH_DAY.."日  "
        elseif DH_YEAR == 0 then
            RESULT = RESULT.."  修为："..DH_DAY.."日  "
        end
    end

    --获取道痕
    for DD, DH in pairs (Variables.Constants.DaoHen) do
        if Osi.HasActiveStatus(Character,DH) == 1 then
            DaoHen,DaoHen_Name = DH,Variables.Constants.DaDao[DD]
            if DaoHen ~= nil then
                DaoHen_Year = Osi.GetStatusTurns(Character, DaoHen)
            else
                DaoHen_Year = 0
            end
            break
        end
    end
    --偏离大道时，给予道痕提示
    if DaoHen_Year ~= nil then
        if DaoHen_Name ~= DaDao_Name then
            RESULT = RESULT.."[残留道痕]："..DaoHen_Name..": "..DaoHen_Year.."年"
        elseif DaoHen_Name == DaDao_Name then
            RESULT = RESULT.."[道心坚定]"
        end
    end
    
    return DaDAO,DaDao_Name,DH_YEAR,DH_DAY,DaoHen,DaoHen_Name,DaoHen_Year,RESULT
end

--获取资源点
function Utils.Get.ActionReource(Object,ReourceID)
    local entity = Ext.Entity.Get(Object)
    --_D(entity:GetAllComponents()) --DEBUG
    --_D(entity.ActionResources) --DEBUG
    if entity.ActionResources.Resources[ReourceID] then
        return math.floor(entity.ActionResources.Resources[ReourceID][1].Amount)
    else
        return 0
    end
end

--获取最大资源点
function Utils.Get.ActionReourceMax(Object,ReourceID)
    local entity = Ext.Entity.Get(Object)
    --_D(entity:GetAllComponents()) --DEBUG
    --_D(entity.ActionResources) --DEBUG
    if entity.ActionResources.Resources[ReourceID] then
        return math.floor(entity.ActionResources.Resources[ReourceID][1].MaxAmount)
    else
        return 0
    end
end

--获取资源类型
function Utils.Get.ActionReourceCooldown(Object,ReourceID)
    local entity = Ext.Entity.Get(Object)
    --_D(entity:GetAllComponents()) --DEBUG
    if entity.ActionResources.Resources[ReourceID] then
        return math.floor(entity.ActionResources.Resources[ReourceID][1].ReplenishType)
    else
        return nil
    end
end

--获取最大临时生命值
function Utils.Get.MaxTemporaryHp(Object)
    local entity = Ext.Entity.Get(Object)
    --_D(entity:GetAllComponents())
    _P(entity.Health.MaxTemporaryHp)
    return math.floor(entity.Health.MaxTemporaryHp)
end

--获取临时生命值
function Utils.Get.TemporaryHp(Object)
    local entity = Ext.Entity.Get(Object)
    --_D(entity:GetAllComponents())
    _P(entity.Health.TemporaryHp)
    return math.floor(entity.Health.TemporaryHp)
end

--获取最高法术位
function Utils.Get.MaxSpellSlotPower(Object)
    local entity = Ext.Entity.Get(Object)
    local SpellSlots = entity.ActionResources.Resources['d136c5d9-0ff0-43da-acce-a74a07f8d6bf']
    local MaxPower = 0
    --_D(SpellSlots) --DEBUG
    for _, SPELLSLOT in pairs(SpellSlots) do
        --_D(SPELLSLOT) --DEBUG
        if SPELLSLOT['Level'] > MaxPower and SPELLSLOT['MaxAmount'] >= 1 then
            MaxPower = SPELLSLOT['Level']
        end
    end
    _P('[最高环位]：'..MaxPower) --DEBUG
    return MaxPower
end

--获取法术位信息
function Utils.Get.SpellSlotsTable(Object)
    local entity = Ext.Entity.Get(Object)
    local SpellSlots = entity.ActionResources.Resources['d136c5d9-0ff0-43da-acce-a74a07f8d6bf']
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
    local Statuses = Ext.Entity.Get(Object).ServerCharacter.StatusManager.Statuses
    --_D(Statuses) --DEBUG
    for _, Status in pairs(Statuses) do
        if Status.StatusId == "BURNING_YEHUO" then
            return Status.Cause.Uuid.EntityUuid
        end
    end
    return nil
end

--获取重量
function Utils.GetEntityWeight(Object)
    local entity = Ext.Entity.Get(Object)
    --_D(entity:GetAllComponents()) --DEBUG
    local Weight = entity.Data.Weight

    return Weight
end

-------------------------------------------------------------------------------------------------
--                                                                                             --
--                                         Save                                              --
--                                                                                             --
-------------------------------------------------------------------------------------------------
--备份原始数据
function Utils.FaBao_LianQiSaveOriginalStats()
    for _, ID in ipairs(Ext.Stats.GetStats("Weapon")) do
        local stat = Ext.Stats.Get(ID)

        for TYPE, VALUE in pairs(Variables.Constants.FaBao.Weapon) do
            PersistentVars["[OriginalStatsLianQi]"..ID.."_"..TYPE] = stat[TYPE]
        end
        PersistentVars["[OriginalStatsLianQi]"..ID.."_Rarity"] = stat.Rarity
    end

    for _, ID in ipairs(Ext.Stats.GetStats("Armor")) do
        local stat = Ext.Stats.Get(ID)

        for TYPE, VALUE in pairs(Variables.Constants.FaBao.Base) do
            PersistentVars["[OriginalStatsLianQi]"..ID.."_"..TYPE] = stat[TYPE]
        end
        PersistentVars["[OriginalStatsLianQi]"..ID.."_Rarity"] = stat.Rarity
    end
end

function Utils.FaBao_LianQiSaveOriginalStats_new()
    for _, ID in ipairs(Ext.Stats.GetStats("Weapon")) do
        local stat = Ext.Stats.Get(ID)

        for TYPE, VALUE in pairs(Variables.Constants.FaBao.Weapon) do
            PersistentVars["[SaveStatsLianQi]"..ID.."_"..TYPE] = stat[TYPE]
        end
        PersistentVars["[SaveStatsLianQi]"..ID.."_Rarity"] = stat.Rarity
    end

    for _, ID in ipairs(Ext.Stats.GetStats("Armor")) do
        local stat = Ext.Stats.Get(ID)

        for TYPE, VALUE in pairs(Variables.Constants.FaBao.Base) do
            PersistentVars["[SaveStatsLianQi]"..ID.."_"..TYPE] = stat[TYPE]
        end
        PersistentVars["[SaveStatsLianQi]"..ID.."_Rarity"] = stat.Rarity
    end
end

--保存炼器数据
function Utils.FaBao_LianQiSaveStats(FABAO)
    local stat = Ext.Stats.Get(FABAO)
    local TYPE_TABLE = Variables.Constants.FaBao.Base
    PersistentVars[FABAO.."_IsFABAO"] = true
    _P("炼器完成") --DEBUG
    _P(FABAO.."_IsFABAO") --DEBUG
    _P(PersistentVars[FABAO.."_IsFABAO"]) --DEBUG
    
    if stat['ModifierList'] == 'Weapon' then
        TYPE_TABLE = Variables.Constants.FaBao.Weapon
    end

    for TYPE, VALUE in pairs(TYPE_TABLE) do
        PersistentVars["[SaveStatsLianQi]"..FABAO.."_"..TYPE] = stat[TYPE]
    end
    PersistentVars["[SaveStatsLianQi]"..FABAO.."_Rarity"] = stat.Rarity
end


-------------------------------------------------------------------------------------------------
--                                                                                             --
--                                         Load                                              --
--                                                                                             --
-------------------------------------------------------------------------------------------------

--恢复原始数据
function Utils.FaBao_LianQiLoadOriginalStats(ID,Statstable,Rarity)
    local stat = Ext.Stats.Get(ID)

    for TYPE, VALUE in pairs(Statstable) do
        stat[TYPE] = VALUE
    end
    stat.Rarity = Rarity
    stat:Sync()
    
    if PersistentVars[ID.."_IsFABAO"] == true then
        _P("***********************"..'已恢复原装备数据'..ID) --DEBUG
    else
        _P('已恢复装备数据'..ID) --DEBUG
    end

end

--读取炼器数据
function Utils.FaBao_LianQiLoadStats(FABAO)
    local stat = Ext.Stats.Get(FABAO)
    local TYPE_TABLE = Variables.Constants.FaBao.Base
    
    if stat['ModifierList'] == 'Weapon' then
        TYPE_TABLE = Variables.Constants.FaBao.Weapon
    end

    for TYPE, VALUE in pairs(TYPE_TABLE) do
        stat[TYPE] = PersistentVars["[SaveStatsLianQi]"..FABAO.."_"..TYPE]
    end
    stat.Rarity = PersistentVars["[SaveStatsLianQi]"..FABAO.."_Rarity"]
    stat:Sync()
    _P('已恢复炼器数据'..FABAO) --DEBUG

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

    local X,Y = Utils.ZhenFa.GetInPosition(Flag,Core)
    local TW = Utils.ZhenFa.GetFlagsTowards(Flag,Core)
    local Radius = Utils.ZhenFa.GetCoreDistance(Flag,Core)
    
    return X,Y,TW,Radius
end


-------------------------------------------------------------------------------------------------
--                                                                                             --
--                                         LingGen                                             --
--                                                                                             --
-------------------------------------------------------------------------------------------------
--随机灵根
function Utils.LingGen.Random(k)
    local r, TZ = 100,1
    local z = math.random(1, 1000000)
    if z <= 5000 then         -- 0.5% 先天道体（T0）
        r, TZ = 100, math.random(6,10)
    elseif z <= 30000 then    -- 2.5% 大帝之资（T1）
        r, TZ = 50, math.random(3,5)
    elseif z <= 100000 then   -- 7% 先天慧根（T2）
        r, TZ = 20, 2
    elseif z <= 300000 then   -- 20% 平平无奇（T3）
        r, TZ = 10, 1
    else                      -- 70% 灵根破碎（NIL）
        r, TZ = 5, 1
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

    if Osi.HasPassive(Object, 'BANXAIN_Shenshi') == 1 then
        local k = Utils.Get.ActionReourceMax(Object,'0032115b-77c3-43c8-9385-630e657b2fcc')
        if Ext.Stats.Get('BanXian_SS_BOOST_'..k) ~= nil then
            Osi.ApplyStatus(Object, 'BanXian_SS_BOOST_'..k, -1, 1, Object)
        else
            Stats = Ext.Stats.Create('BanXian_SS_BOOST_'..k, 'StatusData', 'BanXian_SS_BOOST')
            if k ~= 0 then
                Stats.Boosts = "IF(IsDamageTypePsychic()):DamageBonus("..k..",Psychic);DamageReduction(Psychic,Threshold,"..k..");Ability(Wisdom,"..k..")"
            end
            Stats:Sync()
            Osi.ApplyStatus(Object, 'BanXian_SS_BOOST_'..k, -1, 1, Object)
            _P('刷新谪仙数据: 神识') --DEBUG
        end
    end

end


-------------------------------------------------------------------------------------------------
--                                                                                             --
--                                         DaDao                                             --
--                                                                                             --
-------------------------------------------------------------------------------------------------
--刷新大道增益：力道
function Utils.DaDao.Li(Object)
    local DH_YEAR = Osi.GetStatusTurns(Object, 'BANXIAN_DH_YEAR')
    if DH_YEAR ~= nil then
        if DH_YEAR >= 1 and Osi.HasPassive(Object,'BanXian_DH_Li') == 1 and Osi.HasActiveStatus(Object, 'BanXian_DH_STR_'..math.floor(DH_YEAR)) == 0 then
            --local k = math.floor(math.sqrt(DH_YEAR))
            local k = math.floor(DH_YEAR)
            if Ext.Stats.Get('BanXian_DH_STR_'..k) ~= nil then
                Osi.ApplyStatus(Object, 'BanXian_DH_STR_'..k, -1, 1, Object)
            else
                Stats = Ext.Stats.Create('BanXian_DH_STR_'..k, 'StatusData', 'BanXian_DH_STR')
                Stats.Boosts = "Ability(Strength,"..k..")"
                Stats:Sync()
                Osi.ApplyStatus(Object, 'BanXian_DH_STR_'..k, -1, 1, Object)
                _P('刷新谪仙数据: 力道') --DEBUG
            end
        end
    end
end

--刷新大道增益：合欢道
function Utils.DaDao.Hehuan(Object)
    local DH_YEAR = Osi.GetStatusTurns(Object, 'BANXIAN_DH_YEAR')
    if DH_YEAR ~= nil then
        if DH_YEAR >= 1 and Osi.HasPassive(Object,'BanXian_DH_HeHuan') == 1 and Osi.HasActiveStatus(Object, 'BanXian_DH_CHA_'..math.floor(DH_YEAR)) == 0 then
            --local k = math.floor(math.sqrt(DH_YEAR))
            local k = math.floor(DH_YEAR)
            if Ext.Stats.Get('BanXian_DH_CHA_'..k) ~= nil then
                Osi.ApplyStatus(Object, 'BanXian_DH_CHA_'..k, -1, 1, Object)
            else
                Stats = Ext.Stats.Create('BanXian_DH_CHA_'..k, 'StatusData', 'BanXian_DH_CHA')
                Stats.Boosts = "Ability(Charisma,"..k..")"
                Stats:Sync()
                Osi.ApplyStatus(Object, 'BanXian_DH_CHA_'..k, -1, 1, Object)
                _P('刷新谪仙数据: 合欢道') --DEBUG
            end
        end
    end
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
  
      --第1次检测被动
        local k = 1
      for _,entry in pairs(Ext.Entity.Get(Object).PassiveContainer.Passives) do
        local ID = entry.Passive.PassiveId
        Variables.Constants.GongFa.BaiMai.CopyPassives_Constant[k] = ID
        _P("发现"..Variables.Constants.GongFa.BaiMai.CopyPassives_Constant[k])
        k = k + 1
      end

      --脱掉装备
      local n = 1
      for _, slot in ipairs(Itemslot) do
        if Osi.GetEquippedItem(Object, slot) ~= nil then
            Variables.Constants.GongFa.BaiMai.BaiMAI_WNP_Constant[n] = Osi.GetEquippedItem(Object, slot)
            Osi.Unequip(Object, Osi.GetEquippedItem(Object, slot))
        else
        end
      end
    
    end
    
end

--复制装备被动2
function Utils.GongFa.BaiMai.CopyPassives_2(Object)
    local m = 1
    for _,entry in pairs(Ext.Entity.Get(Object).PassiveContainer.Passives) do
      local ID = entry.Passive.PassiveId
      Variables.Constants.GongFa.BaiMai.CopyPassives_Constant_UN[m] = ID
      _P("发现"..Variables.Constants.GongFa.BaiMai.CopyPassives_Constant_UN[m])
      m = m + 1
    end

    --寻找差异 
    for _, entry in ipairs(Variables.Constants.GongFa.BaiMai.CopyPassives_Constant) do
      local Passive_To_Copy = entry
      local IsWNP = true
      _P("判断"..entry)

      for _,Compare in ipairs(Variables.Constants.GongFa.BaiMai.CopyPassives_Constant_UN) do
          --_P("    比较"..Compare)
          --如果相同，则不是武器被动
          if Passive_To_Copy == Compare then
              IsWNP = false
          end
      end

      --没有找到相同，则是武器被动，添加
      if IsWNP == true then
        Osi.AddPassive(Object,Passive_To_Copy)
          _P("触发：百脉锻宝诀·吞宝·被动："..Passive_To_Copy)
      end

    end

    --穿上装备
    for _, slot in ipairs(Variables.Constants.GongFa.BaiMai.BaiMAI_WNP_Constant) do
      Osi.Equip(Object, slot, 1, 1)
    end

    --清空临时储存表
    Variables.Constants.GongFa.BaiMai.BaiMAI_WNP_Constant = {}
    Variables.Constants.GongFa.BaiMai.CopyPassives_Constant_UN = {}
    Variables.Constants.GongFa.BaiMai.CopyPassives_Constant = {}
    
end

--复制装备状态
function Utils.GongFa.BaiMai.CopyStatus(Object)
  
    if ( Ext.Entity.Get(Object):GetComponent("StatusContainer") ~= nil ) then
	
        for _,entry in pairs(Ext.Entity.Get(Object).StatusContainer.Statuses) do
            local stat = Ext.Stats.Get(entry.StatusID.ID, 0)
            if string.find(entry.StatusID.ID, 'TECHNICAL') then
              if ( stat.StatusType == "BOOST" ) then
                if ( string.find(stat.Boosts, "Invulnerable()") == nil ) then
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
    local EAT_STATUS_EGUI_FILTER_consistant = Variables.Constants.Filter.Status.IsSpecialID
    local status = nil
    local flags = nil
    _P(ID) --DEBUG
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
                _P(ID.."饿鬼道检查：隐藏状态[FLAGS]: ")
                --_D(flags)
                return true
            end
        end
    end
    for _,key in pairs(EAT_STATUS_EGUI_FILTER_consistant) do
        if string.find(ID, key) then
            _P(ID.."饿鬼道检查:特定状态")
            return true
        end
    end
    return false
end

--状态过滤器·DEBUFF
function Utils.Filter.Status.IsDebuff(ID)
    local STEAL_STATUS_EGUI_FILTER_consistant = Variables.Constants.Filter.Status.EGuiDebuff
    local STEAL_STATUS_EGUI_FILTER_consistant_SDEBUFF = Variables.Constants.Filter.Status.EGuiDebuff_Special
    local status = Ext.Stats.Get(ID)
    _P(ID) --DEBUG
    for _,key in pairs(STEAL_STATUS_EGUI_FILTER_consistant) do
        if Osi.IsStatusFromGroup(ID, key) == 1 then
            _P(ID.."饿鬼道过滤:负面状态[GROUP]: "..key)
            return true
        end
    end
    for _,key in pairs(STEAL_STATUS_EGUI_FILTER_consistant_SDEBUFF) do
        if string.find(ID, key) then
            _P(ID.."饿鬼道过滤:负面状态[SPECIAL]: "..key)
            return true
        end
    end
    return false
end


--------------------------------------------------------------------------------------------------
---刷新境界增益：炼体周天（力量、体质、智力、敏捷、魅力、感知）
function Utils.BanXian.JingjieBoost(Object)
    local JJ = Utils.GetBnaxianJingjie(Object)
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
            _P('[JingjieBoost] '..entry.id..' 境界'..JJ..' 加值+'..bonus)
        end
    end

    -- 应用精确境界标记（用于周天运气施法消耗）
    local tierStatusName = 'BANXIAN_JJ_TIER_'..JJ
    if Ext.Stats.Get(tierStatusName) == nil then
        local TierStats = Ext.Stats.Create(tierStatusName, 'StatusData', 'BANXIAN_JJ_TIER')
        TierStats:Sync()
    end
    Osi.ApplyStatus(Object, tierStatusName, -1, 1, Object)
    _P('[JingjieBoost] 境界标记 TIER_'..JJ)

    -- 应用累积到达标记（用于灵根技能解锁）
    for i = 1, 6 do
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
    while PersistentVars['BANXIANLIST_NO.'..k] ~= nil do
        if PersistentVars['BANXIANLIST_NO.'..k] == Object then
            _P('已存在谪仙记录[NO.'..k..']: '..Object)
            return
        end
        k = k + 1
    end
    PersistentVars['BANXIANLIST_NO.'..k] = Object
    _P('记录谪仙[NO.'..k..']: '..Object)

end

--恢复谪仙数据
function Utils.BanXianList_RecoverStatsStart()

    local k = 1
    for key, Object in pairs(PersistentVars) do
        --_P(key)
        if string.find(key,'BANXIANLIST_NO.') then
            if Object ~= nil then
                _P('恢复谪仙数据: '..key)
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
            end
            k = k + 1
        end
    end

    --for k = 1, 1000, 1 do
        --local Object = PersistentVars['BANXIANLIST_NO.'..k]
        --if Object then
            --_P('恢复谪仙数据[NO.'..k..']: '..Object)
            --Utils.DaDao.Hehuan(Object)
            --Utils.DaDao.Hehuan(Object)
            --Utils.ShenShi.Check(Object)
        --end
    --end
end

--勾选难度选择
function Utils.Difficulty.YesNoChoice()

    --勾选难度选项
    local Message_Difficulty = Variables.Constants.Difficulty.MessageBox.default
    local Message_Difficulty_AGE = Variables.Constants.Difficulty.MessageBox.Age
    local Message_Difficulty_A1 = Variables.Constants.Difficulty.MessageBox.Age_1
    local Message_Difficulty_A2 = Variables.Constants.Difficulty.MessageBox.Age_2
    if PersistentVars['Difficulty_Result'] ~= 1 then
        --Osi.OpenMessageBoxYesNo(Osi.GetHostCharacter(), Message_Difficulty)
        Osi.OpenMessageBoxChoice(Osi.GetHostCharacter(), Message_Difficulty_AGE, Message_Difficulty_A1, Message_Difficulty_A2)
    end

end

return Utils
