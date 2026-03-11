local Difficulty = {
    HardCore = {},
    IncreaseDH = {}
}
local LingGen = require("Server.Modules.Systems.LingGen")
local Variables = require("Server.Modules.Variables")
local Utils = require("Server.Modules.Utils")



-- 初始化难度系统
function Difficulty.Init()

    -- 注册事件监听难度相关状态
    Ext.Osiris.RegisterListener("StatusApplied", 4, "after", Difficulty.OnStatusApplied_after)

    -- 注册事件监听创建角色
    Ext.Osiris.RegisterListener("CharacterCreationStarted", 0, "after", Difficulty.OnCharacterCreationStarted_after)

    -- 注册MessageBoxYesNoClosed
    Ext.Osiris.RegisterListener("MessageBoxYesNoClosed", 3, "after", Difficulty.OnMessageBoxYesNoClosed_after)

    -- 注册MessageBoxChoiceClosed
    Ext.Osiris.RegisterListener("MessageBoxChoiceClosed", 3, "after", Difficulty.OnMessageBoxChoiceClosed_after)

    -- 注册进入战斗：洪荒时代模式下为敌方NPC施加BANXIAN_HARDCORE触发全员修仙
    Ext.Osiris.RegisterListener("EnteredCombat", 2, "after", Difficulty.OnEnteredCombat_after)

end


--全员修仙·道行计算器（返回总天数）
function Difficulty.HardCore.Calculate_DaoHeng(k,Level,IsBoss,Days)
    local years = 0
    local extra_day = math.random(1,364)
    local max = Level*k
    if IsBoss == 1 then
        years = max + Days
    elseif math.random(1,4) < Level then
        local Days_increase = math.random(1,Days)  --游戏天数加成
        years = math.random(0,max) + Days_increase  --25%概率获得min~max年道行
    end
    return years * 365 + extra_day
end

--启动敌人修仙
function Difficulty.HardCore.Start(Object)
    local k = 1 --难度系数
    local Race_DaDao = Variables.Constants.Difficulty.Race_DaDao

    --觉醒灵根
    LingGen.Add_First(Object)

    --根据种族偏向获取大道表
    local DaDao_table = {}
    for _, DDtable in ipairs(Race_DaDao) do
        local tag = DDtable.tag
        if Osi.IsTagged(Object, tag) == 1 then
            for i, entry in pairs(DDtable.DaDao_table) do
                table.insert(DaDao_table,entry)
            end
        end
    end

    --开始分配大道
    if #DaDao_table > 0 then
        local Name = DaDao_table[math.random(#DaDao_table)]
        local DaDao = Utils.Get.DaDaoPassive(Name)
        Utils.AddPassive_Safe(Object, DaDao) --添加大道
    end

    --添加道行
    local Level = Osi.GetLevel(Object) or 1
    local IsBoss = Osi.IsBoss(Object)
    local Days = PersistentVars['GAME_DAYS'] or 1
    local DH_DAY = Difficulty.HardCore.Calculate_DaoHeng(k,Level,IsBoss,Days)
    Osi.ApplyStatus(Object, 'BANXIAN_DH_DAY', DH_DAY*6, 1, Object)

    --刷新大道增益
    Utils.DaDao.Li(Object)
    Utils.DaDao.Hehuan(Object)

    --添加境界增益
    if Level >= 5 and Level < 9 then --筑基
        Utils.AddPassive_Safe(Object,'ExtraAttack_BanXian')
    elseif Level >= 9 and Level < 13 then --结丹
        Utils.AddPassive_Safe(Object,'ExtraAttack_2_BanXian')
        Utils.AddPassive_Safe(Object,'BANXIAN_JinDan')
        Utils.AddPassive_Safe(Object,'BANXIAN_JinDanBoosts')
    elseif Level >= 13 and Level < 21 then --元婴
        Utils.AddPassive_Safe(Object,'ExtraAttack_3_BanXian')
        Utils.AddPassive_Safe(Object,'BANXIAN_YuanYing')
        Utils.AddPassive_Safe(Object,'BANXIAN_YuanYingBoosts')
    elseif Level >= 21 and Level < 41 then --化神
        Utils.AddPassive_Safe(Object,'ExtraAttack_4_BanXian')
    elseif Level >= 41 and Level < 61 then --炼虚
        Utils.AddPassive_Safe(Object,'ExtraAttack_5_BanXian')
    elseif Level >= 61 and Level < 81 then --合体
        Utils.AddPassive_Safe(Object,'ExtraAttack_6_BanXian')
    elseif Level >= 81 and Level < 99 then --大乘
        Utils.AddPassive_Safe(Object,'ExtraAttack_7_BanXian')
    elseif Level == 99 then --渡劫
        Utils.AddPassive_Safe(Object,'ExtraAttack_8_BanXian')
    elseif Level >= 100 then --真仙
        Utils.AddPassive_Safe(Object,'ExtraAttack_9_BanXian')
    end

end

--敌人修为增加：长休
function Difficulty.IncreaseDH.LongRest()
    for key, Object in pairs(PersistentVars) do
        if string.find(key,'BANXIANLIST_NO_') and Osi.IsPlayer(Object) == 0 then
            if Object ~= nil and Osi.IsDead(Object) == 1 then
                PersistentVars[key] = nil  -- 清除已死亡的NPC记录，防止列表无限增长
            elseif Object ~= nil and Osi.IsDead(Object) == 0 then
                local Level = Osi.GetLevel(Object)
                local IsBoss = Osi.IsBoss(Object)
                local Days = PersistentVars['GAME_DAYS'] or 1 --获取当前天数
                local DH_DAY = Osi.GetStatusTurns(Object,'BANXIAN_DH_DAY') or 0
                local ZZ = math.max(1, Osi.GetStatusTurns(Object, 'BANXIAN_LG_TZ') or 1)

                local IncreaseDays = 1
                if Level ~= nil and Days ~= nil then
                    if IsBoss == 1 then
                        IncreaseDays = IncreaseDays*math.random(1,20)*ZZ*Level + Days
                    else
                        IncreaseDays = IncreaseDays*math.random(1,4)*ZZ*Level + Days
                    end
                end

                DH_DAY = DH_DAY + IncreaseDays

                Osi.ApplyStatus(Object, 'BANXIAN_DH_DAY', DH_DAY*6, 1, Object)
                Utils.DaDao.Hehuan(Object)
                Utils.ShenShi.Check(Object)

                --神火判定
                local DisplayName = Osi.GetDisplayName(Object)
                --_P(DisplayName) --DEBUG
                for _, entry in pairs(Variables.Constants.Difficulty.YiHuo) do
                    if DisplayName == entry.DisplayName then
                        Utils.AddPassive_Safe(Object, entry.Fire)
                    end
                end

            end
        end
    end
end







-- 事件·难度状态监听
function Difficulty.OnStatusApplied_after(Object, Status)

    if Status == 'BANXIAN_HARDCORE' then  --硬核难度检测

        if PersistentVars['Difficulty_Result'] == 1 then
            if Osi.HasPassive(Object, 'BanXian_LingGen') == 0
            and Osi.HasPassive(Object, 'BanXian_LingGen_Blank') == 0
            and Osi.HasPassive(Object, 'BanXian_LingGen_NIL') == 0
            and not PersistentVars['Difficulty_Awakened_' .. Object] then
                --_P('[Difficulty]检测难度状态：'..Status..' 角色：'..Object)
                PersistentVars['Difficulty_Awakened_' .. Object] = true
                Difficulty.HardCore.Start(Object)
            end
            
        end

        --神火判定
        --_P('[神火判定]') --DEBUG
        local DisplayName = Osi.GetDisplayName(Object)
        --_P(DisplayName) --DEBUG
        for _, entry in pairs(Variables.Constants.Difficulty.YiHuo) do
            if DisplayName == entry.DisplayName then
                Utils.AddPassive_Safe(Object, entry.Fire)
            end
        end

    end

end

-- 处理难度选择1
function Difficulty.OnMessageBoxYesNoClosed_after(Character, Message, Result)
    local Message_Difficulty = Variables.Constants.Difficulty.MessageBox.default
    if Message == Message_Difficulty then
        PersistentVars['Difficulty_Result'] = Result
        --_P('[PersistentVars]记录数据[Difficulty_Result]:'..Result) --DEBUG
    end
end

-- 处理难度选择2
function Difficulty.OnMessageBoxChoiceClosed_after(Character, Message, ResultChoice)
    local Message_Difficulty_AGE = Variables.Constants.Difficulty.MessageBox.Age
    local Message_Difficulty_A1 = Variables.Constants.Difficulty.MessageBox.Age_1
    local Message_Difficulty_A2 = Variables.Constants.Difficulty.MessageBox.Age_2
    if Message == Message_Difficulty_AGE then
        if ResultChoice == Message_Difficulty_A1 then
            PersistentVars['Difficulty_Result'] = 0
        elseif ResultChoice == Message_Difficulty_A2 then
            PersistentVars['Difficulty_Result'] = 1
        end
    end
end

-- 事件·难度状态监听
function Difficulty.OnCharacterCreationStarted_after()
    --难度选择倒计时
    Osi.TimerLaunch('Banxian_Difficulty_Choice', 6000)

end

-- 事件·进入战斗（洪荒时代：为敌方NPC触发全员修仙）
function Difficulty.OnEnteredCombat_after(Object, CombatGuid)
    if PersistentVars['Difficulty_Result'] ~= 1 then return end
    if Osi.IsPlayer(Object) == 1 then return end
    if Osi.IsDead(Object) == 1 then return end

    if Osi.HasPassive(Object, 'BanXian_LingGen') == 0
    and Osi.HasPassive(Object, 'BanXian_LingGen_Blank') == 0
    and Osi.HasPassive(Object, 'BanXian_LingGen_NIL') == 0
    and not PersistentVars['Difficulty_Awakened_' .. Object] then
        Osi.ApplyStatus(Object, 'BANXIAN_HARDCORE', 100, -1, Object)
        Utils.BanXianList_AddtoList(Object)
    end
end

return Difficulty