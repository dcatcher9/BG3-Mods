local FaBao = {
    LianHua ={},
    Passives = {
        Weapon = {},
        Armor = {},
        Ring = {}
    },
    YiHuo = {}
}
local Variables = require("Server.Modules.Variables")
local Utils = require("Server.Modules.Utils")


-- 初始化炼器系统
function FaBao.Init()

    if not PersistentVars.FaBaoData then
        PersistentVars.FaBaoData = {
            -- 结构: [存档ID] = { [装备ID] = { 属性1=值, 属性2=值... } }
        }
    end

    -- 注册事件监听大道相关施法
    Ext.Osiris.RegisterListener("StatusApplied", 4, "after", FaBao.OnStatusApplied_after)

    -- 注册事件监听大道相关施法
    Ext.Osiris.RegisterListener("Equipped", 2, "after", FaBao.OnEquipped_after)

    -- 注册事件监听大道相关施法
    Ext.Osiris.RegisterListener("UsingSpell", 5, "after", FaBao.OnUsingSpell_after)

    -- 事件·炼器相关选择后
    Ext.Osiris.RegisterListener("MessageBoxYesNoClosed", 3, "after", FaBao.OnMessageBoxYesNoClosed)

    -- 事件·炼器相关选择后
    Ext.Osiris.RegisterListener("SavegameLoaded", 0, "after", FaBao.OnSavegameLoaded)

    -- 事件·铁中血器纹伤害回溯
    Ext.Osiris.RegisterListener("AttackedBy", 7, "after", FaBao.OnAttackedBy_after)


end




--炼器·合并字符串
local function SafeConcatStrings(original, new, separator)
    -- 参数安全检查
    original = (original and tostring(original)) or ""
    new = (new and tostring(new)) or ""
    separator = separator or ";"

    -- 规范化原字符串：移除末尾所有可能的分号变体
    -- 匹配模式包括：分号前后可能有0-N个空格
    original = original:gsub("%s*;%s*$", ""):gsub("%s+$", "")
    
    -- 判断是否需要添加分隔符
    if original == "" or new == "" then
        return original .. new -- 无需分隔符的情况
    else
        return original .. separator .. new
    end
end



--炼器词条选择器A: YES OR NO
function FaBao.OpenChoiceBox_A(Character, BOOST)

    local TYPE = PersistentVars['LianQi_Choice_TYPE']
    local stat = Ext.Stats.Get(BOOST)
    --_D(FABAOstat)

    local FABAOName = "XXX"
    local DisplayName = Ext.Loca.GetTranslatedString(stat.DisplayName)
    local Description = Ext.Loca.GetTranslatedString(stat.Description)

    local Forwords = "大道五十，天衍四九。"

    local Message = Forwords.."这名为["..DisplayName.."]的器灵精华，可要炼入您的证道之器？ "
    PersistentVars['LianQi_Choice_Message'] = Message

    Osi.OpenMessageBoxYesNo(Character, Message)
end


--遍历抉择器
function FaBao.LianQi_StartChoose(Caster,FABAO)
    local Amount = PersistentVars['LianQi_Choice_Amount']
    local Rest = PersistentVars['LianQi_Choice_AmountRest']

    if Amount >= 1 and Rest >= 1 then
        local BOOST = PersistentVars['LianQi_Choice_ActiveBOOST_'..Amount]
        if BOOST ~= nil then

            --记录当前ACTIVEBOOST
            local TYPE = PersistentVars['LianQi_Choice_ActiveBOOSTTYPE_'..Amount]
            PersistentVars['LianQi_Choice_FABAO'],PersistentVars['LianQi_Choice_TYPE'],PersistentVars['LianQi_Choice_BOOST'] = FABAO,TYPE,BOOST

            FaBao.OpenChoiceBox_A(Caster, BOOST)
            PersistentVars['LianQi_Choice_Amount'] = Amount - 1

            --清除已使用数据
            PersistentVars['LianQi_Choice_ActiveBOOSTTYPE_'..Amount],PersistentVars['LianQi_Choice_ActiveBOOST_'..Amount] = nil,nil
        end
    end
end

--词条过滤_避免冗长
function FaBao.Boosts_Filter(TYPE,ActiveBOOST,FABAO)
    local stat = Ext.Stats.Get(FABAO)
    local Filter = Variables.Constants.Filter.BOOST.Boosts
    local OBT = Utils.GetStatField(stat, TYPE, FABAO)

    if TYPE == "DefaultBoosts" or TYPE == "BoostsOnEquipMainHand" or TYPE == "BoostsOnEquipOffHand" then
        for _, value in ipairs(Filter) do
            if string.find(ActiveBOOST, value) then
                return false
            end
        end
    end

    --检查词条是否重复
    if OBT ~= nil then
        if string.find(OBT, ActiveBOOST) then
            return false
        end
    end

    return true
end

--被动查重
function FaBao.SamePassives_Check(TYPE,Passive,FABAO)
    local stat = Ext.Stats.Get(FABAO)
    local OBT = stat[TYPE]

    --检查词条是否重复
    if OBT ~= nil then
        if string.find(OBT, Passive) then
            return false
        end
    end

    return true
end

--隐藏被动检查
function FaBao.HiddenPassives_Check(Passive)
    local stat = Ext.Stats.Get(Passive)
    --_D(stat) --DEBUG

    if stat.Properties then
        --_D(stat.Properties) --DEBUG
        for _, Properties in ipairs(stat.Properties) do
            if Properties == "IsHidden" then
                return false
            end
        end
    end

    return true
end

--炼器·添加增益
function FaBao.AddBoosts_AfterChoice(FABAO,TYPE,BOOST)
    local stat = Ext.Stats.Get(FABAO)

    local newValue = SafeConcatStrings(Utils.GetStatField(stat, TYPE, FABAO), BOOST)
    Utils.SetStatField(stat, TYPE, newValue)

    PersistentVars['FABAO_Stats_'..TYPE..'_'..FABAO] = newValue
    stat:Sync()
    --_D(stat) --DEBUG

    Utils.FaBao_LianQiSaveStats(FABAO)

    if PersistentVars['LianQi_Choice_AmountRest'] ~= nil then
        if PersistentVars['LianQi_Choice_AmountRest'] <= 1 then
            PersistentVars['LianQi_Choice_FABAO'] = nil
            PersistentVars['LianQi_Choice_TYPE'] = nil
            PersistentVars['LianQi_Choice_BOOST'] = nil
        end
    end
    PersistentVars['LianQi_Choice_Message'] = nil
    
end


--获取炼化难度
function FaBao.LianHua.GetThreshold(Object)
    if Osi.GetStatString(Object) then
        local FABAO = Osi.GetStatString(Object)
        local stat = Ext.Stats.Get(FABAO)
        if stat['ModifierList'] == "Weapon" or stat['ModifierList'] == "Armor" then
            local threshold_table = Variables.Constants.FaBao.GetThreshold
            local count = PersistentVars['FABAO_RefineCount_'..FABAO] or 0
            local idx = math.min(count + 1, #threshold_table)
            return threshold_table[idx]
        end
        return 365
    end
end

--宝材判定
function FaBao.LianHua.IsBaoCaiCheck(BaoCai)
    return Variables.Constants.FaBao.Materials_BaoCai[BaoCai] ~= nil
end

--炼化材料
function FaBao.LianHua.GetBoosts(Object)
    local Material = Osi.GetStatString(Object)

    local stat = Ext.Stats.Get(Material)
    local IsBaoCai = FaBao.LianHua.IsBaoCaiCheck(Material)

    --储存材料增益
    Variables.Constants.FaBao.ActiveMaterial = Material

    --移除材料
    local BladPactStatus = Variables.Constants.FaBao.BladPactStatus
    for _, Status in pairs(BladPactStatus) do
        if Osi.HasActiveStatus(Object,Status) == 1 then
            Osi.RemoveStatus(Object,Status,Object)
        end
    end
    Osi.TeleportToPosition(Object, 0, 0, 0, '', 0, 0, 0, 1, 0)
    Osi.RequestDelete(Object)
    
end

--炼妖
function FaBao.LianHua.LianYao(Object,Causee)
    local DeathType = Osi.GetDeathType(Object) or "None"
    local Level = Osi.GetLevel(Object) or 1
    local Progression = Osi.GetStatusTurns(Object, 'BANXIAN_FABAO_FIREBREATH_BURNING')
    local BaoCai_Probabilities = Variables.Constants.DanYao.DropProbabilities.BaoCai

    local DROP = false
    local DROPPED = false
    if Progression >= 49*Level and DeathType ~= "Explode" then

        for _, item in ipairs(BaoCai_Probabilities) do
            if DROPPED == false then

                local Amount = 1
                local id = item.id
                local tag = item.tag
                local minlevel = item.minlevel
        
                if tag then
                    if type(tag) == 'table' then --特殊生物材料
                        for _, t in ipairs(tag) do
                            if Osi.IsTagged(Object, t) == 1 then
                                DROP = true
                                break
                            end
                        end
                    else
                        if Osi.IsTagged(Object, tag) == 1 then
                            DROP = true
                        end
                    end
                end
        
                -- 判断是否掉落
                if DROP == true and Level >= minlevel then
                    local templateID = id < 10 and '987e1e7e-9656-4fdf-a0d2-e745bca00a0'..id or '987e1e7e-9656-4fdf-a0d2-e745bca00a'..id
                    Osi.TemplateAddTo(templateID, Causee, Amount, 1)
                    DROPPED = true
                    break
                else
                    --_P("[DanYao.Drop.YaoCai] 炼妖失败")  --DEBUG
                end
                
            end
        end
        
        if Osi.IsDead(Object) == 1 then
            Osi.ApplyStatus(Object, 'CORPSE_SWITCH_EXPLODE', 6, 1)
        end
    end

end

--炼器
function FaBao.LianHua.AddBoosts(Caster,Object,Turns)
    local FABAO,Material = Osi.GetStatString(Object),Variables.Constants.FaBao.ActiveMaterial
    local stat = Ext.Stats.Get(FABAO)
    local Materialstat = {}

    local refineCount = PersistentVars['FABAO_RefineCount_'..FABAO] or 0
    local maxRefine = #Variables.Constants.FaBao.GetThreshold
    if refineCount >= maxRefine then return end

    local IsBaoCai = FaBao.LianHua.IsBaoCaiCheck(Material)
    if Material ~= nil then
        Materialstat = Ext.Stats.Get(Material)
    end

    local ACTIVEBOOSTS = {}
    if stat['Unique'] == 1 then
        local TYPE_TABLE = {}
        --获取增益类型表
        if stat['ModifierList'] == 'Weapon' then
            TYPE_TABLE = Variables.Constants.FaBao.Weapon
        else
            TYPE_TABLE = Variables.Constants.FaBao.Base
        end

        --获取增益表
        if IsBaoCai ~= true then  --非宝材

            for TYPE, _ in pairs(TYPE_TABLE) do
                local materialValue = Utils.GetStatField(Materialstat, TYPE)
                Variables.Constants.FaBao.All[TYPE] = materialValue or ""
            end
            ACTIVEBOOSTS = Variables.Constants.FaBao.All

        else  --宝材
            if stat['ModifierList'] == 'Weapon' then
                TYPE_TABLE = Variables.Constants.FaBao.Materials_BaoCai[Material].Weapon
                ACTIVEBOOSTS = Variables.Constants.FaBao.Materials_BaoCai[Material].Weapon
            elseif stat['ModifierList'] == 'Armor' then
                local Slot = stat['Slot']
                if Slot == "Ring" or Slot == "Ring2" or Slot == "Amulet" then
                    TYPE_TABLE = Variables.Constants.FaBao.Materials_BaoCai[Material].Ring
                    ACTIVEBOOSTS = Variables.Constants.FaBao.Materials_BaoCai[Material].Ring
                else
                    TYPE_TABLE = Variables.Constants.FaBao.Materials_BaoCai[Material].Armor
                    ACTIVEBOOSTS = Variables.Constants.FaBao.Materials_BaoCai[Material].Armor
                end
            end
        end
    
        --添加增益
        local Amount = 0
        
        for TYPE, _ in pairs(TYPE_TABLE) do
            local boostValue = ACTIVEBOOSTS[TYPE]
            if boostValue and boostValue ~= "" then
                if TYPE == "PassivesOnEquip" or TYPE == "PassivesOffHand" or TYPE == "PassivesMainHand" then
                        --字符串处理
                        local Passives = Utils.Seprate_Strings(boostValue)
                        for _, Passive in ipairs(Passives) do

                            --查重过滤
                            if FaBao.HiddenPassives_Check(Passive) then
                                if FaBao.SamePassives_Check(TYPE,Passive,FABAO) then
                                    --词条计数器
                                    Amount = Amount + 1
                                    PersistentVars['LianQi_Choice_Amount'] = Amount or 0
                                    --词条记录器
                                    PersistentVars['LianQi_Choice_ActiveBOOSTTYPE_'..Amount],PersistentVars['LianQi_Choice_ActiveBOOST_'..Amount] = TYPE,Passive
                                end
                            else
                                FaBao.AddBoosts_AfterChoice(FABAO,TYPE,Passive)
                            end
                            
                        end
                    elseif TYPE == "DefaultBoosts" or TYPE == "Boosts" or TYPE == "BoostsOnEquipMainHand" or TYPE == "BoostsOnEquipOffHand" then
                        local Boosts = Utils.Seprate_Strings(boostValue)
                        for _, Boost in ipairs(Boosts) do
                            if FaBao.Boosts_Filter(TYPE,Boost,FABAO) then
                                FaBao.AddBoosts_AfterChoice(FABAO,TYPE,Boost)
                            end
                        end

                    else
                        if FaBao.Boosts_Filter(TYPE,boostValue,FABAO) then
                            FaBao.AddBoosts_AfterChoice(FABAO,TYPE,boostValue)
                        end
                    end
                end
        end

        --更改品质
        if stat['Rarity'] ~= nil then
            local Rarity = stat['Rarity']
            if Rarity == 'Common' then
                stat['Rarity'] = 'Uncommon'
            elseif Rarity == 'Uncommon' then
                stat['Rarity'] = 'Rare'
            elseif Rarity == 'Rare' then
                stat['Rarity'] = 'VeryRare'
            elseif Rarity == 'VeryRare' then
                stat['Rarity'] = 'Legendary'
            end
        end

        PersistentVars['FABAO_RefineCount_'..FABAO] = refineCount + 1

        stat:Sync()

        --启动抉择模块, 当前剩余炼器就绪层数即为可提取词条数
        PersistentVars['LianQi_Choice_AmountRest'] = Turns
        FaBao.LianQi_StartChoose(Caster,FABAO)
    
    end
    
    --重置数据
    for TYPE, _ in pairs(Variables.Constants.FaBao.All) do
        Variables.Constants.FaBao.All[TYPE] = ""
    end
    Variables.Constants.FaBao.ActiveMaterial = nil

end

--恢复炼器数据_装备时
function FaBao.LianHua.RecoverStatsStart_OnEquipped(FABAO)
    local stat = Ext.Stats.Get(FABAO)
    local TYPE_TABLE = {}
    if stat['ModifierList'] == "Weapon" then
        TYPE_TABLE = Variables.Constants.FaBao.Weapon
    else
        TYPE_TABLE = Variables.Constants.FaBao.Base
    end

    --判断是否为炼制过的法宝
    if PersistentVars[FABAO.."_IsFABAO"] ~= nil then
        local RECOVER = false

        --检查储存数据与现数是否一致
        for TYPE, _ in pairs(TYPE_TABLE) do
            if Utils.GetStatField(stat, TYPE) ~= PersistentVars['FABAO_Stats_'..TYPE..'_'..FABAO] then

                --不一致时，恢复数据
                RECOVER = true
                break
            end
        end

        --没有恢复过数据时，恢复数据
        if RECOVER then
            --覆盖数据
            for TYPE, _ in pairs(TYPE_TABLE) do
                if PersistentVars['FABAO_Stats_'..TYPE..'_'..FABAO] ~= nil and PersistentVars['FABAO_Stats_'..TYPE..'_'..FABAO] ~= "" then
                    Utils.SetStatField(stat, TYPE, PersistentVars['FABAO_Stats_'..TYPE..'_'..FABAO])
                end
            end
            if PersistentVars['FABAO_Stats_Rarity_'..FABAO] ~= nil then
                stat['Rarity'] = PersistentVars['FABAO_Stats_Rarity_'..FABAO]
            end
            stat:Sync()
        else
        end
        
    end

end



function FaBao.RestoreStatsForSave()
    for _, ID in ipairs(Ext.Stats.GetStats("Weapon")) do
        if PersistentVars[ID.."_IsFABAO"] == true then
            Utils.FaBao_LianQiLoadStats(ID)
        end
    end

    for _, ID in ipairs(Ext.Stats.GetStats("Armor")) do
        if PersistentVars[ID.."_IsFABAO"] == true then
            Utils.FaBao_LianQiLoadStats(ID)
        end
    end

end



---------------------------------------------------------
--器纹·铁角
function FaBao.Passives.Weapon.TieNiu_Check(Object, Status)
    if Ext.Stats.Get(Status) ~= nil then
        local stat = Ext.Stats.Get(Status)
        if stat.StackId == "TEMPORARY_HP" then
            --_P('[监听：获取临时生命值]') --DEBUG
            local TemporaryHP = Utils.Get.MaxTemporaryHp(Object)
            Osi.ApplyStatus(Object,'TIENIU_BOOSTS_DAMAGEBONUS',TemporaryHP*6,1,Object)
        end
    end
end

function FaBao.Passives.Armor.TieNiu_Check(Object, Status)
    if Ext.Stats.Get(Status) ~= nil then
        local stat = Ext.Stats.Get(Status)
        if stat.StackId == "TEMPORARY_HP" then
            --_P('[监听：获取临时生命值]') --DEBUG
            Osi.ApplyStatus(Object,'TIENIU_BOOSTS_ACBONUS',6,1,Object)
        end
    end
end


--器纹·妖生角
function FaBao.Passives.Ring.YaoShengJiao_Check(Caster)
    local MaxPower = Utils.Get.MaxSpellSlotPower(Caster)
    if MaxPower >6 then
        MaxPower = 6
    end
    if MaxPower >= 1 and Osi.HasActiveStatus(Caster,'TIENIU_BOOSTS_EXTRASPELLSLOT_'..MaxPower) == 0 then
        Osi.ApplyStatus(Caster,'TIENIU_BOOSTS_EXTRASPELLSLOT_'..MaxPower,-1,1,Caster)
        Variables.Constants.Hostile['UsingSpellSlot_Caster'] = Caster
        Variables.Constants.Hostile['UsingSpellSlot_Status'] = "TIENIU_BOOSTS_EXTRASPELLSLOT_USE_"..MaxPower
        Osi.TimerLaunch('FaBao_Ring_YaoShengJiao_UsingSpellSlot', 500)
    end
end


--器纹·铁中血
function FaBao.Passives.Armor.TieZhongXue_RecoverHP(Defender,DamageAmount)
    Osi.SetHitpoints(Defender, Osi.GetHitpoints(Defender)+DamageAmount)
    --_P('[FaBao.Passives.Armor.TieZhongXue_RecoverHP]回溯伤害') --DEBUG
end



---------------------------------------------------------
--异火·取火
function FaBao.YiHuo.TackeFireSeed(Object,Causee)
    local Progression = Osi.GetStatusTurns(Object, 'BANXIAN_FABAO_FIREBREATH_BURNING')
    local Level = Osi.GetLevel(Object)
    if Progression ~= nil then
        for _, value in pairs(Variables.Constants.Difficulty.YiHuo) do
            local Fire = value.Fire
            if Osi.HasPassive(Object, Fire) == 1 and Progression >= Level then
                Osi.RemovePassive(Object, Fire)
                Utils.AddPassive_Safe(Causee, Fire)
                --_P('[成功炼化火种]：'..Fire)

                local FireName = ""
                if Fire == "BANXIAN_Fire_of_Gold" then
                    FireName = "洗业金火"
                elseif Fire == "BANXIAN_Fire_of_Ghost" then
                    FireName = "幽冥鬼火"
                elseif Fire == "BANXIAN_Fire_of_ThreeMei" then
                    FireName = "三昧真火"
                elseif Fire == "BANXIAN_Fire_of_Purple" then
                    FireName = "焚天紫火"
                elseif Fire == "BANXIAN_Fire_of_SixDing" then
                    FireName = "六丁神火"
                end
                Osi.OpenMessageBox(Causee, "已收服新的天上神火["..FireName.."] ！")
            end
        end
    end
end




function FaBao.GameLoded_LianQi()
    -- 首次加载时无需全量备份；炼器时已逐件保存（FaBao_LianQiSaveStats）
    -- 仅补存列表中尚未保存过的条目（向前兼容旧存档中的FABAOLIST）
    if PersistentVars['LianQi_OriginalStats_Saved'] ~= 1 then
        local k = 1
        while PersistentVars['FABAOLIST_NO_'..k] ~= nil do
            Utils.FaBao_LianQiSaveStats(PersistentVars['FABAOLIST_NO_'..k])
            k = k + 1
        end
        PersistentVars['LianQi_OriginalStats_Saved'] = 1
    end

    FaBao.RestoreStatsForSave()
end




---------------------------------------------------------
--点金术-融化金币
local function BANXIAN_GOLDIFIED_ToGold(Object,Causee)
    local Weight = Utils.GetEntityWeight(Object)

    Osi.AddGold(Causee, Weight*0.1)

    Osi.TeleportToPosition(Object, 0, 0, 0, '', 0, 0, 0, 1, 0)
    Osi.RequestDelete(Object)

end


-- 事件·炼器相关状态后
function FaBao.OnStatusApplied_after(Object, Status, Causee)
    --淬火
    if Status == 'BANXIAN_FABAO_FIREBREATH_BURNING' then
        --_P(Object) --DEBUG

        FaBao.LianHua.LianYao(Object,Causee)  --炼妖判定
        if Osi.GetStatusTurns(Object,'BANXIAN_FABAO_FIREBREATH_BURNING') >= 10 then
            Osi.ApplyStatus(Object,'BURNING_SUPERHEATED',-1,1,Causee)  --添加过热
        end

        if Osi.GetStatusTurns(Object,'BANXIAN_FABAO_FIREBREATH_BURNING') >= FaBao.LianHua.GetThreshold(Object) and Osi.HasActiveStatus(Object,'BANXIAN_FABAO_ACTIVEBOOSTS') == 0 then
            FaBao.LianHua.GetBoosts(Object)
            local JJ = Utils.GetBanxianJingjie(Causee)
            if not JJ then return end
            local Turn = JJ + 1 --获取境界值
            Osi.ApplyStatus(Causee,'BANXIAN_FABAO_ACTIVEBOOSTS',Turn*6,1,Causee)  --炼器状态
        end

        if Osi.HasActiveStatus(Causee,'BANXIAN_FABAO_ACTIVEBOOSTS') == 1 and (Osi.HasActiveStatus(Object,'UND_ADAMANTINEGOLEM_SUPERHEATED') == 1 or Osi.HasActiveStatus(Object,'BURNING_SUPERHEATED') == 1) then
            local Turns = math.floor((Osi.GetStatusTurns(Causee,'BANXIAN_FABAO_ACTIVEBOOSTS') or 0)/6)
            Osi.RemoveStatus(Causee,'BANXIAN_FABAO_ACTIVEBOOSTS',Causee)  --移除炼器状态
            FaBao.LianHua.AddBoosts(Causee,Object,Turns)
        end
    end

    --GOLD
    if string.find(Status,"BURNING") then

        --点金术
        if Osi.HasActiveStatus(Object,'BANXIAN_GOLDIFIED') == 1 then
            BANXIAN_GOLDIFIED_ToGold(Object,Causee)
        end
    end


    if Osi.HasPassive(Object, "BanXian_Fabao_Material_BC_DaLiTieJiao_Weapon") == 1 then
        FaBao.Passives.Weapon.TieNiu_Check(Object, Status)
    end
    if Osi.HasPassive(Object, "BanXian_Fabao_Material_BC_DaLiTieJiao_Armor") == 1 then
        FaBao.Passives.Armor.TieNiu_Check(Object, Status)
    end
    if Osi.IsDead(Object) == 1 then
        FaBao.YiHuo.TackeFireSeed(Object,Causee)
    end

end

-- 事件·炼器相关装备后
function FaBao.OnEquipped_after(Item, Character)
    local FABAO = Osi.GetStatString(Item)
    FaBao.LianHua.RecoverStatsStart_OnEquipped(FABAO)
end

-- 事件·炼器相关施法后
function FaBao.OnUsingSpell_after(Caster, Spell, SpellType, SpellElement, StoryActionID)
    if Spell == "Shout_YaoShengJiao_ExtraSpellSlot" then
        FaBao.Passives.Ring.YaoShengJiao_Check(Caster)
    end
end

-- 事件·炼器相关选择后
function FaBao.OnMessageBoxYesNoClosed(Character, Message, Result)
    if Message == PersistentVars['LianQi_Choice_Message'] then
        --_P("**************") --DEBUG
        --_P(Result) --DEBUG
        --_P("**************") --DEBUG
        if Result == 1 then
            --_P('炼器申请!')
            FaBao.AddBoosts_AfterChoice(PersistentVars['LianQi_Choice_FABAO'],PersistentVars['LianQi_Choice_TYPE'],PersistentVars['LianQi_Choice_BOOST'])
            PersistentVars['LianQi_Choice_AmountRest'] = PersistentVars['LianQi_Choice_AmountRest'] - 1
        else
        end
        
        if PersistentVars['LianQi_Choice_AmountRest'] >= 1 then
            FaBao.LianQi_StartChoose(Character,PersistentVars['LianQi_Choice_FABAO']) 
        end
    end
end

--读档监听
function FaBao.OnSavegameLoaded()
    FaBao.GameLoded_LianQi()
end

-- 事件·炼器相关受击后
function FaBao.OnAttackedBy_after(Defender, AttackerOwner, Attacker, DamageType, DamageAmount, DamageCause, StoryActionID)
    if DamageAmount >= 1 and Osi.HasPassive(Defender, 'BanXian_Fabao_Material_BC_TieZhongXue_Armor') == 1 then
        FaBao.Passives.Armor.TieZhongXue_RecoverHP(Defender, DamageAmount)
    end
end





return FaBao