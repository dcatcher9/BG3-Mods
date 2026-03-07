local Base = {
    YuanYing = {},
    TianXian = {},
    ShenTong = {
        TianXian = {}
    }
}
local Utils = require("Server.Modules.Utils")
local Variables = require("Server.Modules.Variables")
-- 初始化基础系统
function Base.Init()

    -- 注册事件监听基础相关状态
    Ext.Osiris.RegisterListener("StatusApplied", 4, "after", Base.OnStatusApplied_after)

    -- 注册事件监听基础相关施法·前
    Ext.Osiris.RegisterListener("UsingSpell", 5, "before", Base.OnUsingSpell_before)

    -- 注册事件监听基础相关施法·后
    Ext.Osiris.RegisterListener("UsingSpell", 5, "after", Base.OnUsingSpell_after)

    -- 注册事件监听基础相关施法·后
    Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", Base.OnUsingSpellOnTarget_after)

    -- 注册事件监听基础相关施法·前
    Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "before", Base.OnUsingSpellOnTarget_before)

    _P("[Base] 基础系统初始化完成！")


end




--元婴术·更改专注·施法前
function Base.YuanYing.Concentration_Before(ID,Caster)
    local spell = Ext.Stats.Get(ID)
    local flags = spell.SpellFlags
    local removeIdx = nil
    for j, _ in pairs(flags) do
        if flags[j] == "IsConcentration" then
            removeIdx = j
            break
        end
    end
    if removeIdx then
        table.remove(flags, removeIdx)
        Osi.ApplyStatus(Caster,'BANXIAN_YUANYING_SHENSHIDECREASED',6,1,Caster)
        _P('移除专注需求：') --DEBUG
        _D(flags) --DEBUG
    end
    spell.SpellFlags = flags
    spell:Sync()
end

--元婴术·更改专注·施法后
function Base.YuanYing.Concentration_After(ID)
    local spell = Ext.Stats.Get(ID)
    local flags = spell.SpellFlags
    if flags ~= nil then
        local hasConcentration = false
        for _, f in ipairs(flags) do
            if f == "IsConcentration" then hasConcentration = true; break end
        end
        if not hasConcentration then
            table.insert(flags, "IsConcentration")
        end
        spell.SpellFlags = flags
        spell:Sync()
    end
    _P('复原专注需求：'..ID)
    _D(flags) --DEBUG
end





--双持攻击·千机
function Base.TianXian.DualAttack_Before(Caster)
    local entity = Ext.Entity.Get(Caster)
    local BP = math.floor(entity.ActionResources.Resources['420c8df5-45c2-4253-93c2-7ec44e127930'][1].Amount)

    if BP == 0 then
        entity.ActionResources.Resources['420c8df5-45c2-4253-93c2-7ec44e127930'][1].Amount = 1
        entity:Replicate("ActionResources")
    end
end






--变身术应用
function Base.ShenTong.TianXian.Transform_Apply(Caster, Target, rule)

    Osi.Transform(Caster,Target, rule)

end

--变身术取消
function Base.ShenTong.TianXian.Transform_Cancel(Caster, Status)

    Osi.RemoveTransforms(Caster)
    Osi.SetFaction(Caster, PersistentVars['BanXian_Faction'])
    Osi.ClearIndividualRelation(Caster, PersistentVars['BanXian_Target_Faction'])

        --遍历变身被动组，消除被动
        local k = PersistentVars['BanXian_36_CopyPassives_Constant_'..Caster.."Number"] or 0
        _P(k) --DEBUG
        if k >= 1 then
            for i = 1, k, 1 do
                local PassiveID = PersistentVars['BanXian_36_CopyPassives_Constant_'..Caster.."_"..i]
                _P(PassiveID)
                if PassiveID ~= nil then
                    Osi.RemovePassive(Caster, PassiveID)
                    PersistentVars['BanXian_36_CopyPassives_Constant_'..Caster.."_"..i] = nil  --清空变身被动组
                    Ext.Utils.Print("[神通·天罡·三十六变·解除变身]: 移除被动："..PassiveID)  --debug
                end
    
            end
        end

        --遍历变身状态组
        local l = PersistentVars['BanXian_36_CopyStatus_Constant_'..Caster.."Number"] or 0
        _P(l) --DEBUG
        if l >= 1 then
            for j = 1, l, 1 do
                local StatusID = PersistentVars['BanXian_36_CopyStatus_Constant_'..Caster.."_"..j]
                _P(StatusID)
                if StatusID ~= nil then
                    if Osi.HasActiveStatus(Caster,StatusID) == 1 then
                        Osi.RemoveStatus(Caster, StatusID)
                        PersistentVars['BanXian_36_CopyStatus_Constant_'..Caster.."_"..j] = nil  --清空变身被动组
                        Ext.Utils.Print("[神通·天罡·三十六变·解除变身]: 移除状态："..StatusID)  --debug
                    end
                end
    
            end
        end
    Ext.Utils.Print("变身：变回原形")--debug
    
end

--变身术
function Base.ShenTong.TianXian.Transform(Caster, Target, Name)
    if Osi.GetIndividualRelation(Caster, Osi.GetFaction(Target)) ~= nil and Osi.GetRelation(Osi.GetFaction(Caster),Osi.GetFaction(Target))  ~= nil then

        _P("[神通·变身]: 个体关系："..Osi.GetIndividualRelation(Caster, Osi.GetFaction(Target)))
        _P("[神通·变身]: 阵营关系："..Osi.GetRelation(Osi.GetFaction(Caster),Osi.GetFaction(Target)))
        
    end
        
    PersistentVars['BanXian_Faction'] = Osi.GetFaction(Caster)
    _P('[PersistentVars]记录数据BanXian_Faction') --DEBUG
    PersistentVars['BanXian_Target_Faction'] = Osi.GetFaction(Target)
    _P('[PersistentVars]记录数据BanXian_Target_Faction') --DEBUG

    if Name == 'BANXIAN_Polymorph_72' then
        Base.ShenTong.TianXian.Transform_Apply(Caster, Target, '34ad98e7-b7e4-4563-9772-e23f75c7c85f')
        Ext.Utils.Print("神通·地煞·七十二变：变身"..Target)--debug
    elseif Name == 'BANXIAN_Polymorph_36' then
        Base.ShenTong.TianXian.Transform_Apply(Caster, Target, 'b5b23794-f4d1-42e5-97ba-0a0906b00e69')
        Ext.Utils.Print("神通·天罡·三十六变：变身"..Target)--debug
    end
    
    if Osi.IsInCombat(Caster) == 0 then
        Osi.SetFaction(Caster, Osi.GetFaction(Target))
        Osi.SetIndividualRelation(Caster, Osi.GetFaction(Target), 100)
        _P("[神通·变身·战斗外]: 复制阵营")
    end

    --复制被动
    if ( Ext.Entity.Get(Target).PassiveContainer.Passives ~= nil ) then
  
      --遍历被动
      local k = 1
      for _,entry in pairs(Ext.Entity.Get(Target).PassiveContainer.Passives) do
        local ID = entry.Passive.PassiveId
        _P("发现"..ID)

        --判断是否重复,否则添加并记录在组
        if Osi.HasPassive(Caster,ID) == 0 then
            Osi.AddPassive(Caster,ID)
            PersistentVars['BanXian_36_CopyPassives_Constant_'..Caster.."_"..k] = ID
            PersistentVars['BanXian_36_CopyPassives_Constant_'..Caster.."Number"] = k
            --_P('[PersistentVars]记录数据BanXian_36_CopyPassives_Constant：'..k..": "..ID) --DEBUG
            k = k + 1
            _P("[神通·天罡·三十六变]: 复制被动"..ID)
        end

      end
    
    end

    --复制STATUS
    if ( Ext.Entity.Get(Target).StatusContainer.Statuses ~= nil ) then
      --遍历STATUS
        local k = 1
      for _,entry in pairs(Ext.Entity.Get(Target).StatusContainer.Statuses) do
        local ID = entry.StatusID.ID
        _P("发现"..ID)

        --判断是否重复,否则添加并记录在组
        if Osi.HasActiveStatus(Caster,ID) == 0 then
            local Duration = Osi.GetStatusTurns(Target, ID)
            Osi.ApplyStatus(Caster, ID, Duration, 1, Caster)
            PersistentVars['BanXian_36_CopyStatus_Constant_'..Caster.."_"..k] = ID
            PersistentVars['BanXian_36_CopyStatus_Constant_'..Caster.."Number"] = k
            --_P('[PersistentVars]记录数据BanXian_36_CopyStatus_Constant_'..k..": "..ID) --DEBUG
            k = k + 1
            _P("[神通·天罡·三十六变]: 复制状态"..ID)
        end
      end
    
    end
    
end





-- 事件·灵根状态
function Base.OnStatusApplied_after(Object, Status, Causee)

    if Status == 'Polymorph_BANXIAN_72_REMOVED' or Status == 'Polymorph_BANXIAN_36_REMOVED' then
        Base.ShenTong.TianXian.Transform_Cancel(Object, Status)
    elseif Status == 'BANXIAN_CREATUREBAG' then  --袖里乾坤
        Osi.ToInventory(Object, Causee, 1, 1, 1)
    end

end

-- 事件·基础施法前
function Base.OnUsingSpell_before(Caster, Spell, SpellType, SpellElement, StoryActionID)

    if Osi.HasActiveStatus(Caster, 'BANXIAN_YUANYING_CONCENTRATION') == 1 and Spell ~= 'BANXIAN_YYNoMoreConcentration'  and not string.find(Spell,'_YaoXian') then
        _P('施法前监听') --DEBUG
        Base.YuanYing.Concentration_Before(Spell,Caster)
        PersistentVars['YYSpellRecover_Waiting'] = Spell
        _P('[PersistentVars]记录数据YYSpellRecover_Waiting：'..Spell) --DEBUG
        --Osi.TimerLaunch('Yuanying_ConcentrationRecover', 1000)
    end

    -- 千机·双持攻击：副手攻击前补充资源
    if (Spell == 'Target_OffhandAttack' or Spell == 'Projectile_OffhandAttack') and Osi.HasPassive(Caster, 'FABAO_BAIMAI_3') == 1 then
        Base.TianXian.DualAttack_Before(Caster)
    end

end

-- 事件·基础施法后
function Base.OnUsingSpell_after(Caster, Spell, SpellType, SpellElement, StoryActionID)

    if string.find(Spell,'Projectile_Fly') and Osi.HasActiveStatus(Caster, 'BANXIAN_DAOXIN') == 1 and Osi.HasActiveStatus(Caster, 'BANXIAN_ANIMATION_FLY') == 0 then
        Osi.ApplyStatus(Caster, 'BANXIAN_ANIMATION_FLY', -1, 1)
    elseif string.find(Spell,'Projectile_Jump') and Osi.HasActiveStatus(Caster, 'BANXIAN_DAOXIN') == 1 then
        Osi.RemoveStatus(Caster, 'BANXIAN_ANIMATION_FLY')
    end

    if Osi.HasActiveStatus(Caster, 'BANXIAN_YUANYING_CONCENTRATION') == 1 and Spell ~= 'BANXIAN_YYNoMoreConcentration' then
        _P('施法后监听') --DEBUG
        if PersistentVars['YYSpellRecover_Waiting'] ~= nil then
            if PersistentVars['YYSpellRecover_Waiting'] == Spell then
                Osi.TimerLaunch('Yuanying_ConcentrationRecover', 1500)
                
            end
        end
    end

end

-- 事件·基础目标施法后
function Base.OnUsingSpellOnTarget_after(Caster, Target, Name)

    if Name == 'BANXIAN_Polymorph_72' or Name == 'BANXIAN_Polymorph_36' then
        Base.ShenTong.TianXian.Transform(Caster, Target, Name)
    end

end

-- 事件·基础目标施法前
function Base.OnUsingSpellOnTarget_before(Caster, Target, Name)
    
    if Name == "Target_MainHandAttack" and Osi.HasPassive(Caster,"FABAO_BAIMAI_3") == 1 then
        --检查副手装备 是否留有附赠动作
        if Osi.GetEquippedItem(Caster, "Melee Offhand Weapon") ~= nil and Utils.Get.ActionResource(Caster,"420c8df5-45c2-4253-93c2-7ec44e127930") < 1 then
            Osi.UseSpell(Caster, "Target_OffhandAttack", Target)
        end
    end

    if Name == "Projectile_MainHandAttack" and Osi.HasPassive(Caster,"FABAO_BAIMAI_3") == 1 then
        if Osi.GetEquippedItem(Caster, "Ranged Offhand Weapon") ~= nil and Utils.Get.ActionResource(Caster,"420c8df5-45c2-4253-93c2-7ec44e127930") < 1 then
            Osi.UseSpell(Caster, "Projectile_OffhandAttack", Target)
        end
    end

end

return Base