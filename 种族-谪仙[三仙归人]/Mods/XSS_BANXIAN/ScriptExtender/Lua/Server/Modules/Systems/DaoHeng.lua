local DaoHeng = {
    Daohen = {},
    XiuLuo = {},
    EGUI = {},
    HeHuan ={},
    DiYu = {},
    ShiJian = {},
    Jian = {},
    Tian = {}
}
local Variables = require("Server.Modules.Variables")
local Utils = require("Server.Modules.Utils")

local ShiJian_Record = {}
local Jiandao_Projectile = nil
local Jiandao_Projectile_Stats = {}

-- 初始化道行系统
function DaoHeng.Init()
    _P("[DaoHeng] 初始化道行系统...")

    -- 注册事件监听大道相关状态前
    Ext.Osiris.RegisterListener("StatusApplied", 4, "before", DaoHeng.OnStatusApplied_before)

    -- 注册事件监听大道相关状态
    Ext.Osiris.RegisterListener("StatusApplied", 4, "after", DaoHeng.OnStatusApplied_after)

    -- 注册事件监听大道相关状态
    Ext.Osiris.RegisterListener("StatusRemoved", 4, "after", DaoHeng.OnStatusRemoved_before)

    -- 注册事件监听大道相关施法
    Ext.Osiris.RegisterListener("UsingSpell", 5, "after", DaoHeng.OnUsingSpell_after)

    -- 注册事件监听大道相关施法
    Ext.Osiris.RegisterListener("UsingSpell", 5, "before", DaoHeng.OnUsingSpell_before)

    -- 注册事件监听大道相关施法
    Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", DaoHeng.OnUsingSpellOnTarget_after)

    -- 注册事件监听大道相关施法
    Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "before", DaoHeng.OnUsingSpellOnTarget_before)

    -- 注册事件监听大道相关攻击
    Ext.Osiris.RegisterListener("AttackedBy", 7, "after", DaoHeng.OnAttackedBy_after)

    _P("[DaoHeng] 道行系统初始化完成！")
end



--刷新大道情况
function DaoHeng.Check(Object)
    local DaDAO,DaDao_Name,DH_YEAR,DH_DAY,DaoHen,DaoHen_Name,DaoHen_Year,RESULT_DD = Utils.Get.Dao(Object)

    --没有道痕或道心坚定时，同步道痕
    if (DaoHen == nil or DaoHen == Variables.Constants.DaoHen[DaDAO]) and DaDAO ~= nil and DH_YEAR ~= nil then
        local DaoHen = Variables.Constants.DaoHen[DaDAO]

        if DaoHen_Year ~= nil and DH_YEAR ~= nil then
            if DaoHen_Year < DH_YEAR then
                Osi.ApplyStatus(Object, DaoHen, DH_YEAR*6, 1, Object)
                _P('同步道痕') --DEBUG
            end
        end
        if Osi.HasActiveStatus(Object,'BANXIAN_DH_HEART_UNSTABLE') == 1 then
            Osi.RemoveStatus(Object, 'BANXIAN_DH_HEART_UNSTABLE')
            _P('移除道心动摇') --DEBUG
        end

    --道心不稳时
    elseif DaoHen ~= Variables.Constants.DaoHen[DaDAO] and DaoHen ~= nil and Osi.HasActiveStatus(Object, 'BANXIAN_DH_HEART_UNSTABLE') == 0 then
        Osi.ApplyStatus(Object, 'BANXIAN_DH_HEART_UNSTABLE', -1, 1, Object)
    end

    --亚种判定
    if Osi.IsTagged(Object, '409e244f-5b8a-48f0-a51f-398b4efb6a01') == 1 and Osi.HasActiveStatus(Object, 'BANXIAN_TAG_TIANXIAN') == 0 then
        Osi.ApplyStatus(Object, 'BANXIAN_TAG_TIANXIAN', -1, 1, Object)
    elseif Osi.IsTagged(Object, '409e244f-5b8a-48f0-a51f-398b4efb6b01') == 1 and Osi.HasActiveStatus(Object, 'BANXIAN_TAG_RENXIAN') == 0 then
        Osi.ApplyStatus(Object, 'BANXIAN_TAG_RENXIAN', -1, 1, Object)
    end

end

--道痕发力
function DaoHeng.Daohen.Functors(Object)
    _P('触发道痕功能') --DEBUG

    --获取当前道行
    local DaDAO,DaDao_Name,DH_YEAR,DH_DAY,DaoHen,DaoHen_Name,DaoHen_Year,RESULT_DD = Utils.Get.Dao(Object)
    if DaoHen_Year ~= nil then

        --先判断是否道心不稳
        if DaoHen ~= Variables.Constants.DaoHen[DaDAO] then --道心不稳

            if Osi.HasPassive(Object,'BanXianDHHeartUnstable') == 1 then --道心动摇，减道痕
                if DaoHen_Year == 1 then
                    Osi.RemoveStatus(Object,DaoHen)
                    Osi.RemoveStatus(Object,'BANXIAN_DH_HEART_UNSTABLE')
                    _P('道心动摇已移除') --DEBUG
                elseif DaoHen_Year > 1 then
                    Osi.RemoveStatus(Object,DaoHen)
                    Osi.ApplyStatus(Object, DaoHen, (DaoHen_Year-1)*6, 1, Object)
                    _P(DaoHen..'道心动摇'..DaoHen_Year) --DEBUG
                end
            end

        elseif DaoHen == Variables.Constants.DaoHen[DaDAO] then
            
            if Osi.HasPassive(Object,'BanXianDHHeartUnstable') == 1 then
                Osi.RemoveStatus(Object,'BANXIAN_DH_HEART_UNSTABLE')
                _P('道心动摇已移除') --DEBUG
            end
            if Osi.HasPassive(Object,'BanXianDHHeartUnstable') == 0 then --道心坚定,加道行
                if DaoHen_Year-DH_YEAR >= 1 then
                    Osi.ApplyStatus(Object, 'BANXIAN_DH_YEAR', (DH_YEAR+1)*6, 1, Object)
                    _P('道心坚定,YEAR+1'..DaoHen..DaoHen_Year)
                end
            end

        end
        
    end
end


--添加修罗道道行
function DaoHeng.XiuLuo.AddDH(Target, BanXian)
    local level = Osi.GetLevel(Target)
    local MaxHP = Osi.GetMaxHitpoints(Target)
    local k = math.max(1, Osi.GetStatusTurns(BanXian, 'BANXIAN_LG_TZ') or 0)
    local DH_Day = Osi.GetStatusTurns(BanXian, 'BANXIAN_DH_DAY') or 0
    local DH_Year = Osi.GetStatusTurns(BanXian, 'BANXIAN_DH_YEAR') or 0
    Ext.Utils.Print("[修罗道/天道][level]="..level.."[k]="..k.."[DH_Day]="..DH_Day.."[DH_Year]="..DH_Year.."[MaxHP]="..MaxHP)--debug

    local DH_Day_new = DH_Day + level*k
    if DH_Day_new >= 365 then
        DH_Year = DH_Year + 1
        Osi.ApplyStatus(BanXian, 'BANXIAN_DH_YEAR', DH_Year*6, 1)
        DH_Day_new = DH_Day_new - 365
        Osi.ApplyStatus(BanXian, 'BANXIAN_DH_DAY', DH_Day_new*6, 1)
    end
    Osi.ApplyStatus(BanXian, 'BANXIAN_DH_DAY', DH_Day_new*6, 1)

    Ext.Utils.Print("[修罗道/天道 现有道行][DH_Day]="..DH_Day.."[DH_Year]="..DH_Year)--debug
end


--添加天道道行
function DaoHeng.Tian.AddDH(Target, BanXian)
    local level = Osi.GetLevel(Target)
    local DH_Day = Osi.GetStatusTurns(BanXian, 'BANXIAN_DH_DAY') or 0
    local DH_Year = Osi.GetStatusTurns(BanXian, 'BANXIAN_DH_YEAR') or 0
    Ext.Utils.Print("[天道奖励][击杀域外天魔奖励道行]："..level.."天")--debug

    local DH_Day_new = DH_Day + level
    if DH_Day_new >= 365 then
        DH_Year = DH_Year + 1
        DH_Day_new = DH_Day_new - 365
        Osi.ApplyStatus(BanXian, 'BANXIAN_DH_YEAR', DH_Year*6, 1)
        Osi.ApplyStatus(BanXian, 'BANXIAN_DH_DAY', DH_Day_new*6, 1)
    else
        Osi.ApplyStatus(BanXian, 'BANXIAN_DH_DAY', DH_Day_new*6, 1)
    end

end

--减少天道道行
function DaoHeng.Tian.ReduceDH(Target, BanXian)
    local level = Osi.GetLevel(Target)
    local DH_Day = Osi.GetStatusTurns(BanXian, 'BANXIAN_DH_DAY') or 0
    local DH_Year = Osi.GetStatusTurns(BanXian, 'BANXIAN_DH_YEAR') or 0
    Ext.Utils.Print("[天道惩罚][滥杀生灵减少道行]："..level.."天")--debug

    local DH_Day_new = DH_Day - level
    if DH_Day_new < 0 then
        DH_Year = DH_Year - 1
        DH_Day_new = DH_Day_new + 365
        if DH_Year > 0 then
            Osi.ApplyStatus(BanXian, 'BANXIAN_DH_YEAR', DH_Year*6, 1)
        end
        Osi.ApplyStatus(BanXian, 'BANXIAN_DH_DAY', DH_Day_new*6, 1)
        Osi.ApplyStatus(BanXian, 'BANXIAN_STATUS_TIANDAO_XINJI', 6, 1)
    else
        Osi.ApplyStatus(BanXian, 'BANXIAN_DH_DAY', DH_Day_new*6, 1)
        Osi.ApplyStatus(BanXian, 'BANXIAN_STATUS_TIANDAO_XINJI', 6, 1)
    end

end



--饿鬼道偷取状态
function DaoHeng.EGUI.Functors_Steal(Object, BanXian)
  
    if ( Ext.Entity.Get(Object):GetComponent("StatusContainer") ~= nil ) then
	
        for _,entry in pairs(Ext.Entity.Get(Object).StatusContainer.Statuses) do
            local status = Ext.Stats.Get(entry.StatusID.ID, 0)
            if (not Utils.Filter.Status.IsSpecial(entry.StatusID.ID)) and (not Utils.Filter.Status.IsDebuff(entry.StatusID.ID))  then
              _P("饿鬼道发现"..entry.StatusID.ID)
              if ( status.StatusType == "BOOST" ) or ( status.StatusType == "INVISIBLE" ) then
                local Duration = Osi.GetStatusTurns(Object, entry.StatusID.ID)
                if Duration == -1 then
                    Duration = 1
                end
                    Osi.ApplyStatus(BanXian, entry.StatusID.ID, Duration*6)
                    Osi.RemoveStatus(Object, entry.StatusID.ID)
                    Ext.Utils.Print(("触发：饿鬼道·偷取·状态: %s"):format(entry.StatusID.ID))
                    --break
              end
            end
        end
    end
    
end

--饿鬼道吞食状态
function DaoHeng.EGUI.Functors_Eat(EGui,Target)
    local Food = Target
    if ( Ext.Entity.Get(Food):GetComponent("StatusContainer") ~= nil ) then
	
        for entry,_ in pairs(Ext.Entity.Get(Food).StatusContainer.Statuses) do
          -- 排除持续至长休的状态
          if ( Osi.GetStatusTurns(Food, entry.StatusID.ID) ~= -1 ) then
            local Filter = Utils.Filter.Status.IsSpecial(entry.StatusID.ID) or Utils.Filter.Status.IsDebuff(entry.StatusID.ID)
            if EGui == Target then
              Filter = Utils.Filter.Status.IsSpecial(entry.StatusID.ID) or (not Utils.Filter.Status.IsDebuff(entry.StatusID.ID))
            end
            if Filter == false then
                  _P("饿鬼道发现"..entry.StatusID.ID)
                  local Duration = (Osi.GetStatusTurns(Food, entry.StatusID.ID) or 0) + (Osi.GetStatusTurns(EGui, 'BANXIAN_DH_DAY') or 0)
                  Osi.ApplyStatus(EGui, 'BANXIAN_DH_DAY', Duration*6)
                  Osi.RemoveStatus(Food, entry.StatusID.ID)
                  Osi.SetHitpoints(EGui, Osi.GetHitpoints(EGui)+Duration*6)  --恢复生命值
                  Ext.Utils.Print(("触发：饿鬼道·吞食·状态: %s".."道行增加"..Duration):format(entry.StatusID.ID))
                  --break
            end
          end
        end
    end
    
end

--合欢道阴阳调和
function DaoHeng.HeHuan.TakeDH(Caster,Target)
    local level = Osi.GetLevel(Target)
    local MaxHP = Osi.GetMaxHitpoints(Target)
    local CASTER_LG_TZ = Osi.GetStatusTurns(Caster, 'BANXIAN_LG_TZ') or 0
    local TAREGET_LG_TZ = Osi.GetStatusTurns(Target, 'BANXIAN_LG_TZ') or 0
    local TAREGET_DH_YEAR = Osi.GetStatusTurns(Target, 'BANXIAN_DH_YEAR') or 0

    local increase_day = level*(1+TAREGET_LG_TZ)

    local P = math.max(0.05,(TAREGET_LG_TZ - CASTER_LG_TZ + 1)/20)
    local increase_year = TAREGET_DH_YEAR*P
    if MaxHP >= 100 and TAREGET_DH_YEAR == 0 then
        for i = 1, 10, 1 do
            MaxHP = MaxHP/10
            if math.floor(MaxHP) >= 1 then
            else
                increase_year = increase_year + i-2
                break
            end
        end
    else
        increase_day = increase_day + MaxHP
    end
    _P('[合欢道采补修为]'..increase_year..'年'..increase_day..'天')
    increase_day = increase_day + Osi.GetStatusTurns(Caster, 'BANXIAN_DH_DAY')
    increase_year = increase_year + Osi.GetStatusTurns(Caster, 'BANXIAN_DH_YEAR')

    if TAREGET_DH_YEAR > Osi.GetStatusTurns(Caster, 'BANXIAN_DH_YEAR') then
        increase_year = Osi.GetStatusTurns(Caster, 'BANXIAN_DH_YEAR')/2

        Osi.ApplyStatus(Caster, 'BANXIAN_DH_YEAR', increase_year*6, 1)
        Osi.ApplyStatus(Target, 'BANXIAN_DH_YEAR',(TAREGET_DH_YEAR+increase_year)*6, 1)
        
        else

            Osi.RemoveStatus(Target, 'BANXIAN_DH_YEAR')
            Osi.RemoveStatus(Target, 'BANXIAN_DH_DAY')
            Osi.ApplyStatus(Caster, 'BANXIAN_DH_YEAR', increase_year*6, 1)
            Osi.ApplyStatus(Caster, 'BANXIAN_DH_DAY', increase_day*6, 1)

    end
end

--合欢道征服随从
function DaoHeng.HeHuan.AddFollower(Object,Causee)

    _P('**************************************') --DEBUG
    _P('[合欢道]开始添加随从：') --DEBUG
    local level = Osi.GetLevel(Object)
    local DH_YEAR = Osi.GetStatusTurns(Causee, 'BANXIAN_DH_YEAR')
    local TARGET_DH_YEAR = Osi.GetStatusTurns(Object, 'BANXIAN_DH_YEAR')
    Osi.ApplyStatus(Causee,'BANXIAN_DH_YEAR', (DH_YEAR-level)*6, 1)
    Osi.ApplyStatus(Object,'BANXIAN_DH_YEAR', (TARGET_DH_YEAR+level)*6, 1)
    Osi.SetFaction(Object, Osi.GetFaction(Causee))
    _P('已更改阵营') --DEBUG
    Osi.AddPartyFollower(Object, Causee)
    _P('已加入队伍') --DEBUG
    --SetIndividualRelation(Causee, GetFaction(Object), 100)
    Osi.AddAttitudeTowardsPlayer(Object, Causee, 100)
    _P('更改好感度') --DEBUG
    Utils.CharacterChange.Equipable(Object)
    _P('更改装备状态') --DEBUG

    --记录
    PersistentVars['[HEHUAN_LEADER]'..Object] = Causee  --记录主人
    for i = 1, 100, 1 do
        if PersistentVars['[HEHUAN_FOLLOWER]'..Causee..'_'..i] == nil then
            PersistentVars['[HEHUAN_FOLLOWER]'..Causee..'_'..i] = Object --记录随从
            _P('[PersistentVars]记录数据[HEHUAN_FOLLOWER]:'..Object) --DEBUG
            _P('记录随从：'..Object) --DEBUG
            _P('记录主人:'..Causee) --DEBUG
            _P('序号:'..i) --DEBUG
            _P('**************************************') --DEBUG
            break
        end
    end
    
end

--合欢道移除征服随从
function DaoHeng.HeHuan.RemoveFollower(Object)
    _P('**************************************') --DEBUG
    _P('[合欢道]开始移除随从：')
    local Causee = PersistentVars['[HEHUAN_LEADER]'..Object]
    _P('随从主人'..Causee) --DEBUG
    for i = 1, 100, 1 do
        if PersistentVars['[HEHUAN_FOLLOWER]'..Causee..'_'..i] == Object then
            PersistentVars['[HEHUAN_FOLLOWER]'..Causee..'_'..i] = nil
            _P('[PersistentVars]QC数据[HEHUAN_FOLLOWER]:') --DEBUG
            _P('随从序号'..i) --DEBUG
            break
        end
    end
    --ClearIndividualRelation(Causee, GetFaction(Object))
    --_P('已清除关系') --DEBUG
    Osi.RemovePartyFollower(Object, Causee)
    _P('已移出队伍') --DEBUG
    PersistentVars['[HEHUAN_FOLLOWER]'..Object] = nil
    _P('[PersistentVars]QC数据[HEHUAN_FOLLOWER]:'..Object) --DEBUG
    _P('已清除序号') --DEBUG
    Utils.CharacterChangeCancle.Equipable(Object)
    _P('已还原装备模式') --DEBUG
    _P('**************************************') --DEBUG
end

--合欢道随从承受伤害
function DaoHeng.HeHuan.FollowerProtect(Defender, Attacker, DamageType, DamageAmount)
    local Causee = Osi.GetTemplate(Defender)
    for i = 1, 100, 1 do
        if PersistentVars['[HEHUAN_FOLLOWER]'..Causee..'_'..i] ~= nil then
            _P('[伤害转移至][NO.'..i..']:'..PersistentVars['[HEHUAN_FOLLOWER]'..Causee..'_'..i]) --debug
            Osi.ApplyDamage(PersistentVars['[HEHUAN_FOLLOWER]'..Causee..'_'..i], DamageAmount, DamageType, Attacker)
            Osi.SetHitpoints(Defender, Osi.GetHitpoints(Defender)+DamageAmount)
            break
        end
    end
end

--地狱道获取道行
function DaoHeng.DiYu.AddDH(Object,Causee)
    local DH_Day = Osi.GetStatusTurns(Causee, 'BANXIAN_DH_DAY')
    local DH_Year = Osi.GetStatusTurns(Causee, 'BANXIAN_DH_YEAR')

    local increase_day = Osi.GetStatusTurns(Object, 'BURNING_YEHUO')
    local DH_Day_new = DH_Day + increase_day

    Osi.RemoveStatus(Object, 'BURNING_YEHUO')
    Osi.ApplyStatus(Causee, 'BANXIAN_DH_DAY', DH_Day_new*6, 1)
end

--时间大道：记录时刻状态
function DaoHeng.ShiJian.Record(BanXian)
    local Second = Osi.GetStatusTurns(BanXian, 'BANXIAN_DH_YEAR')
    ShiJian_Record = Ext.Entity.Get(BanXian)
    _P("记录时间:时间间隔："..Second.."秒") --debug
    --_D(Ext.Entity.Get(BanXian):GetAllComponents()) --DEBUG
    if Second >= 1 then
        --PersistentVars['ShiJianDao_BANXIAN'] = BanXian
        --Osi.TimerLaunch('SHIJIANDADAO_Record', Second*1000)
    end
end

--时间大道：回溯时刻状态
function DaoHeng.ShiJian.Reload(BanXian)
    Ext.Entity.Get(BanXian).ActionResources = ShiJian_Record.ActionResources
    Ext.Entity.Get(BanXian).AddedSpells = ShiJian_Record.AddedSpells
    Ext.Entity.Get(BanXian).BaseHp = ShiJian_Record.BaseHp
    Ext.Entity.Get(BanXian).Level = ShiJian_Record.Level
    Ext.Entity.Get(BanXian).LevelUp = ShiJian_Record.LevelUp
    Ext.Entity.Get(BanXian).Loot = ShiJian_Record.Loot
    Ext.Entity.Get(BanXian).Movement = ShiJian_Record.Movement
    Ext.Entity.Get(BanXian).ObjectSize = ShiJian_Record.ObjectSize
    Ext.Entity.Get(BanXian).Stats = ShiJian_Record.Stats
    Ext.Entity.Get(BanXian).StatusContainer = ShiJian_Record.StatusContainer
    Ext.Entity.Get(BanXian).ServerBoostBase = ShiJian_Record.ServerBoostBase
    Ext.Entity.Get(BanXian).BoostsContainer = ShiJian_Record.BoostsContainer
    _P("回溯时间") --debug
end



--剑道：更改施法动作·施法前
function DaoHeng.Jian.Animation_Before(ID,Animation)
    local spell = Ext.Stats.Get(ID)
    --_D(spell) --DEBUG
    PersistentVars['Jiandao_Projectile_AimationBackup'] = spell.SpellAnimation
    spell.SpellAnimation = Animation
    spell:Sync()

    _P('修改法术动作：'..ID)
end

--剑道：更改施法动作·施法后
function DaoHeng.Jian.Animation_After(ID)
    local spell = Ext.Stats.Get(ID)
    --_D(spell) --DEBUG
    spell.SpellAnimation = PersistentVars['Jiandao_Projectile_AimationBackup']
    spell:Sync()

    _P('复原法术动作：'..ID)
    PersistentVars['Jiandao_Projectile_AimationBackup'] = nil
end

--剑道：更改施法·施法前
function DaoHeng.Jian.Projectile_Replace_Before(ID,Animation)
    local spell = Ext.Stats.Get('Projectile_Deflect_Missiles_JianDao')
    local spell_record = Ext.Stats.Get(ID)

    Jiandao_Projectile_Stats = Ext.Stats.Get('Projectile_Deflect_Missiles_JianDao')
    _D(Jiandao_Projectile_Stats) --DEBUG

    for j, _ in pairs(spell) do
        local OVERRIDE = false
        
        for _, type in pairs(Variables.Constants.SpellModifierList_Change) do
            if j == type then
                OVERRIDE = true
                break
            end
        end

        if OVERRIDE == true then
            if spell_record[j] ~= nil then
                spell[j] = spell_record[j]
            elseif j == 'SpellAnimation' then
                PersistentVars['Jiandao_Projectile_AimationBackup'] = spell.SpellAnimation
                spell.SpellAnimation = Animation
            end
        end
    end

    spell:Sync()

    _P('修改法术：'..ID)
end

--剑道：更改施法·施法后
function DaoHeng.Jian.Projectile_Replace_After(ID)
    local spell = Ext.Stats.Get('Projectile_Deflect_Missiles_JianDao')
    local spell_record = Jiandao_Projectile_Stats
    _D(spell) --DEBUG

    for j, _ in pairs(spell) do
        local OVERRIDE = false
        
        for _, type in pairs(Variables.Constants.SpellModifierList_Change) do
            if j == type then
                OVERRIDE = true
                break
            end
        end

        if OVERRIDE == true then
            if spell_record[j] ~= nil then
                spell[j] = spell_record[j]
            end
        end
    end
    spell:Sync()

    _P('复原法术：'..ID)
    Jiandao_Projectile_Stats = {}
end

--剑道：更改反应（不行）
function DaoHeng.Jian.Interrupt_ProjectileReplace(ID)
    local Interrupt = Ext.Stats.Get('Interrupt_JianDao_Ranged_Return_Parry')
    _D(Interrupt) --DEBUG
    Interrupt.Properties = "UseSpell(SWAP,"..ID..",true,true,true,c4598bdb-fc07-40dd-a62c-90cc138bd76f);UseActionResource(OBSERVER_OBSERVER,DeflectMissiles_Charge,1,0)"
    Interrupt:Sync()

    _P('修改反应：'..Interrupt)
end




-- 事件·大道相关状态前
function DaoHeng.OnStatusApplied_before(Object, Status, Causee)

    if Status == 'DYING' and  Osi.HasActiveStatus(Object, 'BURNING_YEHUO') == 1 then
        _P('[携带业火死亡]： '..Object) --debug
        _P('[击杀者]： '..Causee) --debug
        local Causee = Utils.Get.YeHuoSource(Object)
        DaoHeng.DiYu.AddDH(Object,Causee)
    end

end

-- 事件·大道相关状态移除前
function DaoHeng.OnStatusRemoved_before(Object, Status, Causee)

    if Status == 'DOMINATE_HEHUAN' then
        DaoHeng.HeHuan.RemoveFollower(Object)
    end

end

-- 事件·大道相关状态后
function DaoHeng.OnStatusApplied_after(Object, Status, Causee)

    if Status == 'BANXIAN_DH_DAY' or Status == 'BANXIAN_DH_YEAR' or Status == 'SIGNAL_DAOXINCHECK' then
        DaoHeng.Check(Object)
        Utils.DaDao.Hehuan(Object)
        Utils.DaDao.Li(Object)
        Utils.ShenShi.Check(Object)
    elseif Status == 'SIGNAL_DHMARK_FUNCTORS' then
        DaoHeng.Daohen.Functors(Object)
    elseif Status == 'SIGNAL_DH_XIULUO' then --修罗道、天道获取道行
        DaoHeng.XiuLuo.AddDH(Object, Causee)
    elseif Status == 'DOMINATE_HEHUAN' then
        DaoHeng.HeHuan.AddFollower(Object,Causee)
    elseif Status == 'SIGNAL_BanXian_HEHUAN_REMOVEPARTYFOLLOWER' then
        DaoHeng.HeHuan.RemoveFollower(Object, Causee)
        Osi.ClearIndividualRelation(Causee, Osi.GetFaction(Object))
        _P('[合欢道]强制移除') --DEBUG
    elseif Status == 'SIGNAL_DH_EGui' and Object ~= Causee then --饿鬼道偷取状态
        --DaoHeng.EGUI.Functors_Steal(Object, Causee)
    end

    if Status == 'JIANDAO_PROJECTILE_RETURN' then
        if Jiandao_Projectile ~= nil then
            Osi.UseSpell(Causee, Jiandao_Projectile, Object)
        else
            _P('Jiandao_Projectile is nil') --DEBUG
        end
    end

    --天道
    if Status == "SIGNAL_BANXIAN_TIANKAO_KILLED_LOCALBORN" then
        DaoHeng.Tian.ReduceDH(Object, Causee)
    end
    if Status == "SIGNAL_BANXIAN_TIANKAO_KILLED_ABANDON" then
        DaoHeng.Tian.AddDH(Object, Causee)
    end
    if Status == "TIANDAO_EYES" then
        if Osi.HasActiveStatus(Object,'BANXIAN_DH_MARK_TIAN') == 0 then
            Osi.ApplyStatus(Object,'SIGNAL_TIANDAO_EYES_APPLY',0,1,Object)
        end
    end
    if Status == "SIGNAL_TIANLEI_EXTRADAMAGE" then
        local TIMES = Osi.GetStatusTurns(Causee, 'BANXIAN_DH_YEAR')
        _P('[天道：天罚降临，祓除异端]'..TIMES)
        if TIMES >= 1 then
            _P('[天道：天罚降临，祓除异端]')
            for i = 1, TIMES, 1 do
                Osi.ApplyStatus(Object,'TIANDAO_TIANLEI_KILLTHEDEMON_3D10',0,1,Causee)
            end
        end
    end
end

-- 事件·大道相关施法后
function DaoHeng.OnUsingSpellOnTarget_after(Caster, Target, Name)

    if (Name == 'Succubus_TakingHeart' or Name == 'Succubus_SpiderKiss' or Name == 'Succubus_SpiderKiss_Extra' or Name == 'Target_DrainingKiss_HEHUAN') and Osi.HasActiveStatus(Target, 'BanXian_DH_HEHUAN_ALREADYTAKE') == 0 then
        if Osi.HasActiveStatus(Caster, 'BANXIAN_DH_HEART_UNSTABLE') == 0 and Osi.HasPassive(Caster, 'BanXian_DH_HeHuan') == 1 then
            _P('阴阳调和')
            DaoHeng.HeHuan.TakeDH(Caster,Target)
            local HP = Osi.GetHitpoints(Caster)
            Osi.ApplyStatus(Target, 'BanXian_DH_HEHUAN_EXHOUSTED', HP*6, 1, Caster)
            Osi.ApplyStatus(Target, 'BanXian_DH_HEHUAN_ALREADYTAKE', -1, 1, Caster)
        end
    end

    if Name == 'BanXian_DH_EGui_EATSTATUS' or Name == 'BanXian_DH_EGui_EATSTATUS_YAO' then
        DaoHeng.EGUI.Functors_Eat(Caster,Target)
    end

    --记录弹反投掷物
    if Osi.HasActiveStatus(Target, 'JIANDAO_DODGE_MODE') == 1 or Osi.HasActiveStatus(Target, 'JIANDAO_PARRY_MODE') == 1 then
        Jiandao_Projectile = Name
        --DaoHeng.Jian.Interrupt_ProjectileReplace(Name)
    end
end

-- 事件·大道相关施法前
function DaoHeng.OnUsingSpellOnTarget_before(Caster, Target, Name)

    --更改弹反施法动作
    if Jiandao_Projectile ~= nil then
        local Animation = "None"

        if Osi.HasActiveStatus(Target, 'JIANDAO_PROJECTILE_RETURN') == 1 and Name == Jiandao_Projectile then
            _P('监听弹反 施法前修改弹反动作') --DEBUG
            if Osi.HasActiveStatus(Caster, 'JIANDAO_DODGE_MODE') == 1 then
                Animation = "8b8bb757-21ce-4e02-a2f3-97d55cf2f90b,,;,,;c3340bf4-833e-4c4d-b679-8ccdb26c30e7,,;6c5e8729-472f-4aab-acc4-a51d6657a50d,,;7bb52cd4-0b1c-4926-9165-fa92b75876a3,,;,,;0b07883a-08b8-43b6-ac18-84dc9e84ff50,,;,,;,,"
                --Osi.RemoveStatus(Caster, 'JIANDAO_DODGE_MODE')
            elseif Osi.HasActiveStatus(Caster, 'JIANDAO_PARRY_MODE') == 1 then
                Animation = "3ff87abf-1ea1-4c32-aadf-c822d74c7dc0,,;,,;39daf365-ec06-49a8-81f3-9032640699d7,,;5c400e93-0266-499c-a2e1-75d53358460f,,;d8925ce4-d6d9-400c-92f5-ad772ef7f178,,;,,;eadedcce-d01b-4fbb-a1ae-d218f13aa5d6,,;,,;,,"
                --Osi.RemoveStatus(Caster, 'JIANDAO_PARRY_MODE')
            end

            if Animation ~= "None" then
                DaoHeng.Jian.Animation_Before(Jiandao_Projectile,Animation)
                PersistentVars['Jiandao_Projectile'] = Jiandao_Projectile
                Osi.TimerLaunch('Jiandao_Projectile_Animation_Change', 2000)
                Osi.RemoveStatus(Target, 'JIANDAO_PROJECTILE_RETURN')
                Jiandao_Projectile = nil
            end
        end
    end
end

-- 事件·大道相关施法后
function DaoHeng.OnUsingSpell_after(Caster, Spell)
    --if Spell == 'Target_MainHandAttack' then
        --DaoHeng.ShiJian.Record(Caster)
    --elseif Spell == 'Projectile_MainHandAttack' then
        --DaoHeng.ShiJian.Reload(Caster)
    --end
end

-- 事件·大道相关施法前
function DaoHeng.OnUsingSpell_before(Caster, Spell)

    --更改弹反法术（方案2）
    if Spell == 'Projectile_Deflect_Missiles_JianDao' and Jiandao_Projectile ~= nil then
        local Animation = "None"
        if Osi.HasActiveStatus(Caster, 'JIANDAO_DODGE_MODE') == 1 then
            Animation = "8b8bb757-21ce-4e02-a2f3-97d55cf2f90b,,;,,;c3340bf4-833e-4c4d-b679-8ccdb26c30e7,,;6c5e8729-472f-4aab-acc4-a51d6657a50d,,;7bb52cd4-0b1c-4926-9165-fa92b75876a3,,;,,;0b07883a-08b8-43b6-ac18-84dc9e84ff50,,;,,;,,"
        elseif Osi.HasActiveStatus(Caster, 'JIANDAO_PARRY_MODE') == 1 then
            Animation = "71369b20-18f1-4d33-89ad-a99b10f0444c,,;c12054bc-4d96-47c5-8483-989afde03bd4,,;20aaabc2-067d-4355-86a0-40901d3938d8,,;2a3d2709-24d3-4c6d-ae25-546d1fd4ccb2,,;3b9da8d4-3eff-43bd-9eaa-1c13fba0045e,,;4c38bf59-cfbd-4389-954f-81290ca30476,,;0b07883a-08b8-43b6-ac18-84dc9e84ff50,,;,,;,,"
        end
        
        if Animation ~= "None" then
            DaoHeng.Jian.Projectile_Replace_Before(Jiandao_Projectile,Animation)
            PersistentVars['Jiandao_Projectile'] = Jiandao_Projectile
            Osi.TimerLaunch('Jiandao_Projectile_Replace', 2000)
            Jiandao_Projectile = nil
        end

    end
end
-- 事件·大道相关攻击后
function DaoHeng.OnAttackedBy_after(Defender, AttackerOwner, Attacker, DamageType, DamageAmount, DamageCause, StoryActionID)

    if Osi.HasActiveStatus(Defender, 'MODE_BANXIAN_DH_HEHUAN_TECHNICAL') == 1 and DamageAmount >= 1 then
        DaoHeng.HeHuan.FollowerProtect(Defender, Attacker, DamageType, DamageAmount)
    end

end

return DaoHeng
