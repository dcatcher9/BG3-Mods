local DaoHeng = {
    XiuLuo = {},
    EGUI = {},
    HeHuan ={},
    DiYu = {},
    Jian = {},
    Tian = {}
}
local Variables = require("Server.Modules.Variables")
local Utils = require("Server.Modules.Utils")

local Jiandao_Projectile = nil

-- 初始化道行系统
function DaoHeng.Init()

    -- 注册事件监听大道相关状态前
    Ext.Osiris.RegisterListener("StatusApplied", 4, "before", DaoHeng.OnStatusApplied_before)

    -- 注册事件监听大道相关状态
    Ext.Osiris.RegisterListener("StatusApplied", 4, "after", DaoHeng.OnStatusApplied_after)

    -- 注册事件监听大道相关状态
    Ext.Osiris.RegisterListener("StatusRemoved", 4, "before", DaoHeng.OnStatusRemoved_before)

    -- 注册事件监听大道相关施法
    Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", DaoHeng.OnUsingSpellOnTarget_after)

    -- 注册事件监听大道相关施法
    Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "before", DaoHeng.OnUsingSpellOnTarget_before)

    -- 注册事件监听大道相关攻击
    Ext.Osiris.RegisterListener("AttackedBy", 7, "after", DaoHeng.OnAttackedBy_after)

end



--刷新大道情况
function DaoHeng.Check(Object)
    --亚种判定
    if Osi.IsTagged(Object, '409e244f-5b8a-48f0-a51f-398b4efb6a01') == 1 and Osi.HasActiveStatus(Object, 'BANXIAN_TAG_TIANXIAN') == 0 then
        Osi.ApplyStatus(Object, 'BANXIAN_TAG_TIANXIAN', -1, 1, Object)
    elseif Osi.IsTagged(Object, '409e244f-5b8a-48f0-a51f-398b4efb6b01') == 1 and Osi.HasActiveStatus(Object, 'BANXIAN_TAG_RENXIAN') == 0 then
        Osi.ApplyStatus(Object, 'BANXIAN_TAG_RENXIAN', -1, 1, Object)
    end

end


--添加修罗道道行
function DaoHeng.XiuLuo.AddDH(Target, BanXian)
    local level = Osi.GetLevel(Target)
    local MaxHP = Osi.GetMaxHitpoints(Target)
    local k = math.max(1, Osi.GetStatusTurns(BanXian, 'BANXIAN_LG_TZ') or 0)
    local DH_Day = Osi.GetStatusTurns(BanXian, 'BANXIAN_DH_DAY_XIULUO') or 0
    local DH_Year = Osi.GetStatusTurns(BanXian, 'BANXIAN_DH_YEAR_XIULUO') or 0

    local DH_Day_new = DH_Day + level*k
    while DH_Day_new >= 365 do
        DH_Year = DH_Year + 1
        DH_Day_new = DH_Day_new - 365
    end
    Osi.ApplyStatus(BanXian, 'BANXIAN_DH_YEAR_XIULUO', DH_Year*6, 1)
    Osi.ApplyStatus(BanXian, 'BANXIAN_DH_DAY_XIULUO', DH_Day_new*6, 1)
end


--添加天道道行
function DaoHeng.Tian.AddDH(Target, BanXian)
    local level = Osi.GetLevel(Target)
    local DH_Day = Osi.GetStatusTurns(BanXian, 'BANXIAN_DH_DAY_TIAN') or 0
    local DH_Year = Osi.GetStatusTurns(BanXian, 'BANXIAN_DH_YEAR_TIAN') or 0

    local DH_Day_new = DH_Day + level
    while DH_Day_new >= 365 do
        DH_Year = DH_Year + 1
        DH_Day_new = DH_Day_new - 365
    end
    Osi.ApplyStatus(BanXian, 'BANXIAN_DH_YEAR_TIAN', DH_Year*6, 1)
    Osi.ApplyStatus(BanXian, 'BANXIAN_DH_DAY_TIAN', DH_Day_new*6, 1)

end




--饿鬼道偷取状态
function DaoHeng.EGUI.Functors_Steal(Object, BanXian)
  
    if ( Ext.Entity.Get(Object):GetComponent("StatusContainer") ~= nil ) then
	
        for _,entry in pairs(Ext.Entity.Get(Object).StatusContainer.Statuses) do
            local status = Ext.Stats.Get(entry.StatusID.ID, 0)
            if (not Utils.Filter.Status.IsSpecial(entry.StatusID.ID)) and (not Utils.Filter.Status.IsDebuff(entry.StatusID.ID))  then
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
	
        for _,entry in pairs(Ext.Entity.Get(Food).StatusContainer.Statuses) do
          -- 排除持续至长休的状态
          if ( Osi.GetStatusTurns(Food, entry.StatusID.ID) ~= -1 ) then
            local Filter = Utils.Filter.Status.IsSpecial(entry.StatusID.ID) or Utils.Filter.Status.IsDebuff(entry.StatusID.ID)
            if EGui == Target then
              Filter = Utils.Filter.Status.IsSpecial(entry.StatusID.ID) or (not Utils.Filter.Status.IsDebuff(entry.StatusID.ID))
            end
            if Filter == false then
                  local Duration = (Osi.GetStatusTurns(Food, entry.StatusID.ID) or 0) + (Osi.GetStatusTurns(EGui, 'BANXIAN_DH_DAY_EGUI') or 0)
                  Osi.ApplyStatus(EGui, 'BANXIAN_DH_DAY_EGUI', Duration*6)
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
    local TARGET_LG_TZ = Osi.GetStatusTurns(Target, 'BANXIAN_LG_TZ') or 0
    local TARGET_DH_YEAR = Osi.GetStatusTurns(Target, 'BANXIAN_DH_YEAR') or 0

    local increase_day = level*(1+TARGET_LG_TZ)

    local P = math.max(0.05,(TARGET_LG_TZ - CASTER_LG_TZ + 1)/20)
    local increase_year = TARGET_DH_YEAR*P
    if MaxHP >= 100 and TARGET_DH_YEAR == 0 then
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
    increase_day  = increase_day  + (Osi.GetStatusTurns(Caster, 'BANXIAN_DH_DAY_HEHUAN')  or 0)
    increase_year = increase_year + (Osi.GetStatusTurns(Caster, 'BANXIAN_DH_YEAR_HEHUAN') or 0)

    local caster_year = Osi.GetStatusTurns(Caster, 'BANXIAN_DH_YEAR_HEHUAN') or 0
    if TARGET_DH_YEAR > caster_year then
        --目标道行更深：施法者损失一半年道行，但仍获得天数进度
        increase_year = caster_year / 2
        Osi.ApplyStatus(Caster, 'BANXIAN_DH_YEAR_HEHUAN', increase_year*6, 1)
        Osi.ApplyStatus(Caster, 'BANXIAN_DH_DAY_HEHUAN', increase_day*6, 1)
        Osi.ApplyStatus(Target, 'BANXIAN_DH_YEAR_HEHUAN', (TARGET_DH_YEAR + increase_year)*6, 1)
    else
        --目标道行较浅：施法者夺取目标全部修为
        Osi.RemoveStatus(Target, 'BANXIAN_DH_YEAR_HEHUAN')
        Osi.RemoveStatus(Target, 'BANXIAN_DH_DAY_HEHUAN')
        Osi.ApplyStatus(Caster, 'BANXIAN_DH_YEAR_HEHUAN', increase_year*6, 1)
        Osi.ApplyStatus(Caster, 'BANXIAN_DH_DAY_HEHUAN', increase_day*6, 1)
    end
end

--合欢道征服随从
function DaoHeng.HeHuan.AddFollower(Object,Causee)

    local level = Osi.GetLevel(Object)
    local DH_YEAR = Osi.GetStatusTurns(Causee, 'BANXIAN_DH_YEAR_HEHUAN') or 0
    local TARGET_DH_YEAR = Osi.GetStatusTurns(Object, 'BANXIAN_DH_YEAR') or 0
    Osi.ApplyStatus(Causee,'BANXIAN_DH_YEAR_HEHUAN', math.max(0, DH_YEAR-level)*6, 1)
    Osi.ApplyStatus(Object,'BANXIAN_DH_YEAR', (TARGET_DH_YEAR+level)*6, 1)
    Osi.SetFaction(Object, Osi.GetFaction(Causee))
    Osi.AddPartyFollower(Object, Causee)
    --SetIndividualRelation(Causee, GetFaction(Object), 100)
    Osi.AddAttitudeTowardsPlayer(Object, Causee, 100)
    Utils.CharacterChange.Equipable(Object)

    --记录
    PersistentVars['[HEHUAN_LEADER]'..Object] = Causee  --记录主人
    local count = (PersistentVars['[HEHUAN_COUNT]'..Causee] or 0) + 1
    PersistentVars['[HEHUAN_FOLLOWER]'..Causee..'_'..count] = Object --记录随从
    PersistentVars['[HEHUAN_COUNT]'..Causee] = count
    
end

--合欢道移除征服随从
function DaoHeng.HeHuan.RemoveFollower(Object)
    local Causee = PersistentVars['[HEHUAN_LEADER]'..Object]
    if not Causee then return end
    local count = PersistentVars['[HEHUAN_COUNT]'..Causee] or 0
    for i = 1, count, 1 do
        if PersistentVars['[HEHUAN_FOLLOWER]'..Causee..'_'..i] == Object then
            PersistentVars['[HEHUAN_FOLLOWER]'..Causee..'_'..i] = nil
            break
        end
    end
    --ClearIndividualRelation(Causee, GetFaction(Object))
    --_P('已清除关系') --DEBUG
    Osi.RemovePartyFollower(Object, Causee)
    PersistentVars['[HEHUAN_LEADER]'..Object] = nil
    Utils.CharacterChangeCancel.Equipable(Object)
end

--合欢道随从承受伤害
function DaoHeng.HeHuan.FollowerProtect(Defender, Attacker, DamageType, DamageAmount)
    local Leader = Defender
    local count = PersistentVars['[HEHUAN_COUNT]'..Leader] or 0
    for i = 1, count, 1 do
        if PersistentVars['[HEHUAN_FOLLOWER]'..Leader..'_'..i] ~= nil then
            Osi.ApplyDamage(PersistentVars['[HEHUAN_FOLLOWER]'..Leader..'_'..i], DamageAmount, DamageType, Attacker)
            Osi.SetHitpoints(Defender, Osi.GetHitpoints(Defender)+DamageAmount)
            break
        end
    end
end

--地狱道获取道行
function DaoHeng.DiYu.AddDH(Object,Causee)
    local DH_Day = Osi.GetStatusTurns(Causee, 'BANXIAN_DH_DAY_DIYU') or 0

    local increase_day = Osi.GetStatusTurns(Object, 'BURNING_YEHUO') or 0
    local DH_Day_new = DH_Day + increase_day

    Osi.RemoveStatus(Object, 'BURNING_YEHUO')
    Osi.ApplyStatus(Causee, 'BANXIAN_DH_DAY_DIYU', DH_Day_new*6, 1)
end


--剑道：更改施法动作·施法前
function DaoHeng.Jian.Animation_Before(ID,Animation)
    local spell = Ext.Stats.Get(ID)
    --_D(spell) --DEBUG
    PersistentVars['Jiandao_Projectile_AimationBackup'] = spell.SpellAnimation
    spell.SpellAnimation = Animation
    spell:Sync()

end

--剑道：更改施法动作·施法后
function DaoHeng.Jian.Animation_After(ID)
    local spell = Ext.Stats.Get(ID)
    --_D(spell) --DEBUG
    spell.SpellAnimation = PersistentVars['Jiandao_Projectile_AimationBackup']
    spell:Sync()

    PersistentVars['Jiandao_Projectile_AimationBackup'] = nil
end





-- 事件·大道相关状态前
function DaoHeng.OnStatusApplied_before(Object, Status, Causee)

    if Status == 'DYING' and  Osi.HasActiveStatus(Object, 'BURNING_YEHUO') == 1 then
        local FireSource = Utils.Get.YeHuoSource(Object)
        DaoHeng.DiYu.AddDH(Object, FireSource)
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

    local PATH_DAY_STATUSES = {
        BANXIAN_DH_DAY_XIULUO = 'XIULUO', BANXIAN_DH_DAY_TIAN = 'TIAN',
        BANXIAN_DH_DAY_RENJIAN = 'RENJIAN', BANXIAN_DH_DAY_CHUSHENG = 'CHUSHENG',
        BANXIAN_DH_DAY_EGUI = 'EGUI', BANXIAN_DH_DAY_DIYU = 'DIYU',
        BANXIAN_DH_DAY_JIAN = 'JIAN', BANXIAN_DH_DAY_LI = 'LI',
        BANXIAN_DH_DAY_HEHUAN = 'HEHUAN', BANXIAN_DH_DAY_YI = 'YI',
    }
    local PATH_YEAR_STATUSES = {
        BANXIAN_DH_YEAR_XIULUO=true, BANXIAN_DH_YEAR_TIAN=true,
        BANXIAN_DH_YEAR_RENJIAN=true, BANXIAN_DH_YEAR_CHUSHENG=true,
        BANXIAN_DH_YEAR_EGUI=true, BANXIAN_DH_YEAR_DIYU=true,
        BANXIAN_DH_YEAR_JIAN=true, BANXIAN_DH_YEAR_LI=true,
        BANXIAN_DH_YEAR_HEHUAN=true, BANXIAN_DH_YEAR_YI=true,
    }

    if PATH_DAY_STATUSES[Status] then
        Utils.DaDao.ConvertPathDayToYear(Object, PATH_DAY_STATUSES[Status])
        Utils.DaDao.UpdateSharedYear(Object)
        DaoHeng.Check(Object)
        Utils.DaDao.Hehuan(Object)
        Utils.DaDao.Li(Object)
        Utils.ShenShi.Check(Object)
    elseif PATH_YEAR_STATUSES[Status] then
        Utils.DaDao.UpdateSharedYear(Object)
        DaoHeng.Check(Object)
        Utils.DaDao.Hehuan(Object)
        Utils.DaDao.Li(Object)
        Utils.ShenShi.Check(Object)
    end

    if Status == 'BANXIAN_DH_DAY' or Status == 'BANXIAN_DH_YEAR' or Status == 'SIGNAL_DAOXINCHECK' then
        Utils.DaDao.ConvertDayToYear(Object)
        DaoHeng.Check(Object)
        Utils.DaDao.Hehuan(Object)
        Utils.DaDao.Li(Object)
        Utils.ShenShi.Check(Object)
    elseif Status == 'SIGNAL_DH_XIULUO' then --修罗道、天道获取道行
        DaoHeng.XiuLuo.AddDH(Object, Causee)
    elseif Status == 'DOMINATE_HEHUAN' then
        DaoHeng.HeHuan.AddFollower(Object,Causee)
    elseif Status == 'SIGNAL_BanXian_HEHUAN_REMOVEPARTYFOLLOWER' then
        DaoHeng.HeHuan.RemoveFollower(Object)
        Osi.ClearIndividualRelation(Causee, Osi.GetFaction(Object))
    elseif Status == 'SIGNAL_DH_EGui' and Object ~= Causee then --饿鬼道偷取状态
        DaoHeng.EGUI.Functors_Steal(Object, Causee)
    end

    if Status == 'JIANDAO_PROJECTILE_RETURN' then
        if Jiandao_Projectile ~= nil then
            Osi.UseSpell(Causee, Jiandao_Projectile, Object)
        end
    end

    --天道
    if Status == "SIGNAL_BANXIAN_TIANKAO_KILLED_ABANDON" then
        DaoHeng.Tian.AddDH(Object, Causee)
    end
    if Status == "TIANDAO_EYES" then
        Osi.ApplyStatus(Object,'SIGNAL_TIANDAO_EYES_APPLY',-1,1,Object)
    end
    if Status == "SIGNAL_TIANLEI_EXTRADAMAGE" then
        local TIMES = Osi.GetStatusTurns(Causee, 'BANXIAN_DH_YEAR_TIAN')
        if TIMES >= 1 then
            for i = 1, TIMES, 1 do
                Osi.ApplyStatus(Object,'TIANDAO_TIANLEI_KILLTHEDEMON_3D10',0,1,Causee)
            end
        end
    end
end

-- 事件·大道相关施法后
function DaoHeng.OnUsingSpellOnTarget_after(Caster, Target, Name)

    if (Name == 'Succubus_TakingHeart' or Name == 'Succubus_SpiderKiss' or Name == 'Succubus_SpiderKiss_Extra' or Name == 'Target_DrainingKiss_HEHUAN') and Osi.HasActiveStatus(Target, 'BanXian_DH_HEHUAN_ALREADYTAKE') == 0 then
        if Osi.HasPassive(Caster, 'BanXian_DH_HeHuan') == 1 then
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
    end
end

-- 事件·大道相关施法前
function DaoHeng.OnUsingSpellOnTarget_before(Caster, Target, Name)

    --更改弹反施法动作
    if Jiandao_Projectile ~= nil then
        local Animation = "None"

        if Osi.HasActiveStatus(Target, 'JIANDAO_PROJECTILE_RETURN') == 1 and Name == Jiandao_Projectile then
            if Osi.HasActiveStatus(Caster, 'JIANDAO_DODGE_MODE') == 1 then
                Animation = "8b8bb757-21ce-4e02-a2f3-97d55cf2f90b,,;,,;c3340bf4-833e-4c4d-b679-8ccdb26c30e7,,;6c5e8729-472f-4aab-acc4-a51d6657a50d,,;7bb52cd4-0b1c-4926-9165-fa92b75876a3,,;,,;0b07883a-08b8-43b6-ac18-84dc9e84ff50,,;,,;,,"
                Osi.RemoveStatus(Caster, 'JIANDAO_DODGE_MODE')
            elseif Osi.HasActiveStatus(Caster, 'JIANDAO_PARRY_MODE') == 1 then
                Animation = "3ff87abf-1ea1-4c32-aadf-c822d74c7dc0,,;,,;39daf365-ec06-49a8-81f3-9032640699d7,,;5c400e93-0266-499c-a2e1-75d53358460f,,;d8925ce4-d6d9-400c-92f5-ad772ef7f178,,;,,;eadedcce-d01b-4fbb-a1ae-d218f13aa5d6,,;,,;,,"
                Osi.RemoveStatus(Caster, 'JIANDAO_PARRY_MODE')
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

-- 事件·大道相关攻击后
function DaoHeng.OnAttackedBy_after(Defender, AttackerOwner, Attacker, DamageType, DamageAmount, DamageCause, StoryActionID)

    if Osi.HasActiveStatus(Defender, 'MODE_BANXIAN_DH_HEHUAN_TECHNICAL') == 1 and DamageAmount >= 1 then
        DaoHeng.HeHuan.FollowerProtect(Defender, Attacker, DamageType, DamageAmount)
    end

end

return DaoHeng
