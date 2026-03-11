local EventHandlers = {}
local Variables = require("Server.Modules.Variables")
local Utils = require("Server.Modules.Utils")
local Systems

-- 初始化事件处理器
function EventHandlers.Init(systems)
    Systems = systems

    -- 注册加载游戏数据事件
    Ext.Osiris.RegisterListener("SavegameLoaded", 0, "after", EventHandlers.SavegameLoaded)

    -- 注册状态应用事件
    Ext.Osiris.RegisterListener("StatusApplied", 4, "after", EventHandlers.OnStatusApplied_after)

    -- 注册Timer
    Ext.Osiris.RegisterListener("TimerFinished", 1, "after", EventHandlers.OnTimerFinished_after)

    -- 注册LongRestFinished
    Ext.Osiris.RegisterListener("LongRestFinished", 0, "after", EventHandlers.OnLongRestFinished_after)

    -- 注册LeveledUp（升级时刷新境界增益，确保新选穴位的能力值加成立即生效）
    Ext.Osiris.RegisterListener("LeveledUp", 1, "after", EventHandlers.OnLeveledUp_after)

end




-- 处理事件：加载游戏数据
function EventHandlers.SavegameLoaded()

    --恢复谪仙数据倒计时
    Osi.TimerLaunch('BanXianList_RecoverStats', 3000)

    --恢复炼器数据倒计时
    Osi.TimerLaunch('FaBaoList_RecoverStats', 5000)
end

-- 处理状态应用事件
function EventHandlers.OnStatusApplied_after(Object, Status, Causee)
    --_P('***********DEBUG**************') --DEBUG
    --_P('[谪仙StatusApplied]'..Status) --DEBUG
    if Variables.DEBUG_MODE then
        if Status == 'DEBUG_GETENTITY' then
            _D(Ext.Entity.Get(Object):GetAllComponents())
        end
    end

    if Status == 'CUITI_ZHOUTIAN_OWNER' then
        Utils.BanXian.JingjieBoost(Object)
    end

    -- 道行年数变化时刷新境界（UpdateSharedDay 及 DaoHeng 派生此状态，年数不变则不触发）
    if Status == 'BANXIAN_DH_YEAR' then
        if Osi.HasPassive(Object, 'BanXian_DH_DaoXin') == 1 then
            Utils.BanXian.JingjieBoost(Object)
        end
    end
    --_P(Object) --DEBUG
    --_P(Status) --DEBUG

end

-- 处理Timer
function EventHandlers.OnTimerFinished_after(Timer)

    if Timer == "BanXianList_RecoverStats" then
        Utils.BanXianList_RecoverStatsStart()
    elseif Timer == "FaBaoList_RecoverStats" then
        Systems.FaBao.RestoreStatsForSave()
    elseif Timer == "BanXian_AddLingGen" then
        local Object = PersistentVars['BXAddLingGen_Waiting']
        Systems.LingGen.Add_First(Object)
        Osi.TimerLaunch('BanXian_AddLingGen_2', 2000)
    elseif Timer == "BanXian_AddLingGen_2" then
        local Object = PersistentVars['BXAddLingGen_Waiting']
        Systems.LingGen.ApplyAllChecks(Object)
        PersistentVars['BXAddLingGen_Waiting'] = nil
    elseif Timer == 'Banxian_LuoPan_Calculate' then
        local Caster,X,Z = Variables.Constants.ZhenFa.LuoPan.Caster,Variables.Constants.ZhenFa.LuoPan.X,Variables.Constants.ZhenFa.LuoPan.Z
        Systems.ZhenFa.Tool.LuoPanFunctors(Caster,X,Z)
    elseif Timer == "Yuanying_ConcentrationRecover" then
        local spell = PersistentVars['YYSpellRecover_Waiting']
        PersistentVars['YYSpellRecover_Waiting'] = nil
        if spell ~= nil then
            Systems.Base.YuanYing.Concentration_After(spell)
        end
    elseif Timer == "Jiandao_Projectile_Animation_Change" then
        Systems.DaoHeng.Jian.Animation_After(PersistentVars['Jiandao_Projectile'])
        PersistentVars['Jiandao_Projectile'] = nil
    elseif Timer == "Banxian_Difficulty_Choice" then
        Utils.Difficulty.YesNoChoice()
    elseif Timer == "FaBao_Ring_YaoShengJiao_UsingSpellSlot" then
        local Caster = Variables.Constants.Hostile['UsingSpellSlot_Caster']
        local Status = Variables.Constants.Hostile['UsingSpellSlot_Status']
        Variables.Constants.Hostile['UsingSpellSlot_Caster'] = nil
        Variables.Constants.Hostile['UsingSpellSlot_Status'] = nil
        Osi.ApplyStatus(Caster,Status,-1,1,Caster)
    end


end

-- 处理长休
function EventHandlers.OnLongRestFinished_after()

    if PersistentVars['GAME_DAYS'] == nil then
        PersistentVars['GAME_DAYS'] = 1
    else
        PersistentVars['GAME_DAYS'] = PersistentVars['GAME_DAYS'] + 1
    end
    Systems.Difficulty.IncreaseDH.LongRest()

    -- 长休后刷新境界增益 + 周天淬体诀大周天恢复
    local k = 1
    while PersistentVars['BANXIANLIST_NO_'..k] ~= nil do
        local Object = PersistentVars['BANXIANLIST_NO_'..k]
        Utils.BanXian.JingjieBoost(Object)
        if Osi.HasPassive(Object, 'CuiTi_ZhouTian_LongBreak') == 1 then
            Systems.GongFa.Tianxian.ZhouTianCuiTi.LongRest(Object)
        end
        k = k + 1
    end

end



-- 处理升级：刷新境界增益（确保新选穴位被动的能力值加成立即生效，不需等到长休）
function EventHandlers.OnLeveledUp_after(Object)
    if Osi.HasPassive(Object, 'BanXian_DH_DaoXin') == 1 then
        Utils.BanXian.JingjieBoost(Object)
    end
end

return EventHandlers
