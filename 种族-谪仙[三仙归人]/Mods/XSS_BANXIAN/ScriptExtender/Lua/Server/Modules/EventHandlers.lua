local EventHandlers = {}
local Variables = require("Server.Modules.Variables")
local Utils = require("Server.Modules.Utils")
local Systems = {
    DaoHeng = require("Server.Modules.Systems.DaoHeng"),
    DanYao = require("Server.Modules.Systems.DanYao"),
    LingGen = require("Server.Modules.Systems.LingGen"),
    ShenShi = require("Server.Modules.Systems.ShenShi"),
    GongFa = require("Server.Modules.Systems.GongFa"),
    ZhenFa = require("Server.Modules.Systems.ZhenFa"),
    Difficulty = require("Server.Modules.Systems.Difficulty"),
    XiuLian = require("Server.Modules.Systems.XiuLian"),
    FaBao = require("Server.Modules.Systems.FaBao"),
    Base = require("Server.Modules.Systems.Base")
}
PersistentVars.AppearancePresets = PersistentVars.AppearancePresets or {}

-- 初始化事件处理器
function EventHandlers.Init()
    _P("[EventHandlers] 初始化事件处理器...")

    -- 注册加载游戏数据事件
    Ext.Osiris.RegisterListener("SavegameLoaded", 0, "after", EventHandlers.SavegameLoaded)

    -- 注册状态应用事件
    Ext.Osiris.RegisterListener("StatusApplied", 4, "after", EventHandlers.OnStatusApplied_after)

    -- 注册状态移除事件
    Ext.Osiris.RegisterListener("StatusRemoved", 4, "before", EventHandlers.OnStatusRemoved_before)

    -- 注册Timer
    Ext.Osiris.RegisterListener("TimerFinished", 1, "after", EventHandlers.OnTimerFinished_after)

    -- 注册LongRestFinished
    Ext.Osiris.RegisterListener("LongRestFinished", 0, "after", EventHandlers.OnLongRestFinished_after)

    -- 注册LeveledUp（升级时刷新境界增益，确保新选穴位的能力值加成立即生效）
    Ext.Osiris.RegisterListener("LeveledUp", 1, "after", EventHandlers.OnLeveledUp_after)

    _P("[EventHandlers] 事件处理器初始化完成！")
end


--
local function SaveAppearance(player, slot)
    local entity = Ext.Entity.Get(player)
    
    -- 正确获取组件
    local creationComp = entity:GetComponent("CharacterCreationAppearance")
    if not creationComp then
        Ext.Utils.PrintError("[Preset] 角色缺少Creation组件")
        return
    end

    -- 正确保存核心字段
    PersistentVars.AppearancePresets = PersistentVars.AppearancePresets or {}
    PersistentVars.AppearancePresets[slot] = {
        -- 使用正确的字段路径
        BodyType = creationComp.BodyType,
        Race = creationComp.Race,
        SkinColor = Ext.Types.Clone(creationComp.SkinColor),
        -- 其他字段改为小写驼峰 (如Hair -> hair)
        Head = creationComp.Head,
        HairColor = Ext.Types.Clone(creationComp.HairColor)
    }

    -- 处理覆盖组件 (修正名称)
    local overrideComp = entity:GetComponent("AppearanceOverride")
    if overrideComp then
        PersistentVars.AppearancePresets[slot].Override = {
            BodyType = overrideComp.Visual.BodyType,
            Head = overrideComp.Visual.Head,
            Colors = Ext.Types.Clone(overrideComp.Visual.Colors)
        }
    end
    
    Ext.Utils.Print("[Preset] 保存成功")
end


local function LoadAppearance(player, slot)
    local preset = PersistentVars.AppearancePresets[slot]
    if not preset then return end

    local entity = Ext.Entity.Get(player)
    
    -- 确保创建组件存在
    local creationComp = entity:GetComponent("CharacterCreationAppearance")
    if not creationComp then
        entity:CreateComponent("CharacterCreationAppearance")
        creationComp = entity:GetComponent("CharacterCreationAppearance")
    end

    -- 写回基础属性
    creationComp.BodyType = preset.BodyType
    creationComp.Head = preset.Head
    creationComp.HairColor = Ext.Types.Clone(preset.HairColor)

    -- 强制引擎同步组件
    entity:ReplicateComponent("CharacterCreationAppearance")

    -- 处理覆盖组件加载
    if preset.Override then
        local overrideComp = entity:GetComponent("AppearanceOverride")
        if not overrideComp then
            entity:CreateComponent("AppearanceOverride")
            overrideComp = entity:GetComponent("AppearanceOverride")
            overrideComp.Version = 0
            overrideComp.Visual = {}  -- 初始化Visual表
        end

        overrideComp.Visual.BodyType = preset.Override.BodyType
        overrideComp.Visual.Colors = Ext.Types.Clone(preset.Override.Colors)
        overrideComp.Version = (overrideComp.Version or 0) + 1  -- 版本递增

        entity:ReplicateComponent("AppearanceOverride")
    end

    -- 终极模型刷新
    entity.GameObjectVisual.Type = 2
    entity:Replicate("GameObjectVisual")
end




-- 处理事件：加载游戏数据
function EventHandlers.SavegameLoaded()

    -- 打印 PersistentVars 内容
    local function printTable(tbl, indent)
        indent = indent or 0
        for k, v in pairs(tbl) do
            if type(v) == "table" then
                _P(string.rep(" ", indent) .. k .. ":")
                printTable(v, indent + 4)
            else
                _P(string.rep(" ", indent) .. k .. ": ", v, " (Type: ", type(v), ")")
            end
        end
    end

    --_P("PersistentVars 内容:")
    --printTable(PersistentVars)

    --恢复谪仙数据倒计时
    _P("恢复谪仙数据倒计时")
    Osi.TimerLaunch('BanXianList_RecoverStats', 3000)

    --恢复炼器数据倒计时
    --_P("恢复炼器数据倒计时")
    --Osi.TimerLaunch('FaBaoList_RecoverStats', 5000)
end

-- 处理状态应用事件
function EventHandlers.OnStatusApplied_after(Object, Status, Causee, StoryActionID)
    --_P('***********DEBUG**************') --DEBUG
    --_P('[谪仙StatusApplied]'..Status) --DEBUG
    if Status == 'DEBUG_GETENTITY' then
        local entity = Ext.Entity.Get(Object)
        _D(entity:GetAllComponents()) --DEBUG
    end
    if Status == 'DEBUG_APPEARANCE_RECORD' then
        SaveAppearance(Object, 'Slot1')
        _P('SaveAppearance!') --DEBUG
        
    end
    if Status == 'DEBUG_APPEARANCE_RELOAD' then
        LoadAppearance(Object, 'Slot1')
        _P('LoadAppearance!') --DEBUG
        
    end
    if Status == 'DEBUG_GETCLASS' then
        local entity = Ext.Entity.Get(Object)
        --_D('LoadAppearance!') --DEBUG
        
    end
    if Status == 'CUITI_ZHOUTIAN_OWNER' then
        Utils.BanXian.JingjieBoost(Object)
    end
    --_P(Object) --DEBUG
    --_P(Status) --DEBUG

end

-- 处理状态移除事件
function EventHandlers.OnStatusRemoved_before(object, status)

end

-- 处理Timer
function EventHandlers.OnTimerFinished_after(Timer)

    if Timer == "BanXianList_RecoverStats" then
        Utils.BanXianList_RecoverStatsStart()
    elseif Timer == "FaBaoList_RecoverStats" then
        --Systems.FaBao.RestoreStatsForSave()
    elseif Timer == "BanXian_AddLingGen" then
        local Object = PersistentVars['BXAddLingGen_Waiting']
        Systems.LingGen.Add_First(Object)
        Osi.TimerLaunch('BanXian_AddLingGen_2', 2000)
    elseif Timer == "BanXian_AddLingGen_2" then
        local Object = PersistentVars['BXAddLingGen_Waiting']
        Systems.LingGen.ApplyYiLingGen_Check(Object)
        Systems.LingGen.ApplyTopLingGen_Check(Object)
        PersistentVars['BXAddLingGen_Waiting'] = nil
    elseif Timer == 'Banxian_LuoPan_Caculate' then
        local Caster,X,Z = Variables.Constants.ZhenFa.LuoPan.Caster,Variables.Constants.ZhenFa.LuoPan.X,Variables.Constants.ZhenFa.LuoPan.Z
        Systems.ZhenFa.Tool.LuoPanFunctors(Caster,X,Z)
    elseif Timer == "Yuanying_ConcentrationRecover" then
        Systems.Base.YuanYing.Concentration_After(PersistentVars['YYSpellRecover_Waiting'])
        PersistentVars['YYSpellRecover_Waiting'] = nil
        _P('[PersistentVars]QC数据[YYSpellRecover_Waiting] ') --DEBUG
    elseif Timer == "Jiandao_Projectile_Animation_Change" then
        Systems.DaoHeng.Jian.Animation_After(PersistentVars['Jiandao_Projectile'])
        PersistentVars['Jiandao_Projectile'] = nil
        _P('[PersistentVars]QC数据[Jiandao_Projectile] ') --DEBUG
    elseif Timer == "Jiandao_Projectile_Replace" then
        Systems.DaoHeng.Jian.Projectile_Replace_After(PersistentVars['Jiandao_Projectile'])
        PersistentVars['Jiandao_Projectile'] = nil
        _P('[PersistentVars]QC数据[Jiandao_Projectile] ') --DEBUG
    elseif Timer == "Banxian_Difficulty_Choice" then
        Utils.Difficulty.YesNoChoice()
    elseif Timer == "FaBao_Ring_YaoShengJiao_UsingSpellSlot" then
        local Caster = Variables.Constants.Hostile['UsingSpellSlot_Caster']
        local Status = Variables.Constants.Hostile['UsingSpellSlot_Status']
        Variables.Constants.Hostile['UsingSpellSlot_Caster'] = nil
        Variables.Constants.Hostile['UsingSpellSlot_Status'] = nil
        Osi.ApplyStatus(Caster,Status,-1,1,Caster)
    elseif Timer == "SHIJIANDADAO_Record" then
        local BanXian = PersistentVars['ShiJianDao_BANXIAN']
        if BanXian ~= nil then
            Systems.DaoHeng.ShiJian.Record(BanXian)
        end
    end

    if Timer == "TianXian_DualAttackRecover" then
        Systems.Base.TianXian.DualAttack_After()
    end

end

-- 处理长休
function EventHandlers.OnLongRestFinished_after()

    if PersistentVars['GAME_DAYS'] == nil then
        PersistentVars['GAME_DAYS'] = 1
        _P('[PersistentVars]JL数据[GAME_DAYS]: '..1) --DEBUG
    else
        PersistentVars['GAME_DAYS'] = PersistentVars['GAME_DAYS'] + 1
        _P('[PersistentVars]JL数据[GAME_DAYS]: '..PersistentVars['GAME_DAYS']) --DEBUG
    end
    Systems.Difficulty.IncreaseDH.LongRest()
    _P('[EventHandlers]结束一天:总天数 '..PersistentVars['GAME_DAYS'])

    -- 长休后刷新境界增益
    for key, Object in pairs(PersistentVars) do
        if string.find(key, 'BANXIANLIST_NO.') and Object ~= nil then
            Utils.BanXian.JingjieBoost(Object)
        end
    end

end



-- 处理升级：刷新境界增益（确保新选穴位被动的能力值加成立即生效，不需等到长休）
function EventHandlers.OnLeveledUp_after(Object)
    if Osi.HasPassive(Object, 'BanXian_DH_DaoXin') == 1 then
        Utils.BanXian.JingjieBoost(Object)
        _P('[EventHandlers] 升级刷新境界增益: '..Object)
    end
end

return EventHandlers
