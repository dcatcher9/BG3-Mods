local LingGen = {}
local Variables = require("Server.Modules.Variables")
local Utils = require("Server.Modules.Utils")

-- 初始化灵根系统
function LingGen.Init()
    _P("[LingGen] 初始化灵根系统...")

    -- 注册事件监听灵根相关状态
    Ext.Osiris.RegisterListener("StatusApplied", 4, "after", LingGen.OnStatusApplied_after)

    -- 注册事件监听灵根相关洗点
    Ext.Osiris.RegisterListener("RespecCompleted", 1, "after", LingGen.OnRespecCompleted_after)

    _P("[LingGen] 灵根系统初始化完成！")
end


--灵根层级检测（应用或移除TIAN/XIAN/SHENG三个高阶层级状态）
function LingGen.ApplyTierLingGen_Check(Object, TLG, tian_c, xian_c, sheng_c)
    if sheng_c then
        Osi.ApplyStatus(Object, TLG..'_SHENG', -1, 1, Object)
    else
        Osi.RemoveStatus(Object, TLG..'_SHENG')
    end
    if xian_c then
        Osi.ApplyStatus(Object, TLG..'_XIAN', -1, 1, Object)
    else
        Osi.RemoveStatus(Object, TLG..'_XIAN')
    end
    if tian_c then
        Osi.ApplyStatus(Object, TLG..'_TIAN', -1, 1, Object)
    else
        Osi.RemoveStatus(Object, TLG..'_TIAN')
    end
end

--异灵根检测（N=凡阈值10；TIAN=天阈值50；XIAN=仙阈值150；SHENG=圣阈值500）
function LingGen.ApplyYiLingGen_Check(Object, a, b, c, d, e)

    _P('异灵根检测')
    if not a then a,b,c,d,e = Utils.Get.LingGen(Object) end
    local N     = 10   -- 凡
    local TIAN  = 50   -- 天
    local XIAN  = 150  -- 仙
    local SHENG = 500  -- 圣

    -- 冰灵根: 水+土
    if d >= N and b >= N then
        Osi.ApplyStatus(Object, 'BANXIAN_LG_BING', -1)
        LingGen.ApplyTierLingGen_Check(Object, 'BANXIAN_LG_BING',
            d >= TIAN  and b >= TIAN,
            d >= XIAN  and b >= XIAN,
            d >= SHENG and b >= SHENG)
    else
        Osi.RemoveStatus(Object, 'BANXIAN_LG_BING')
        Osi.RemoveStatus(Object, 'BANXIAN_LG_BING_TIAN')
        Osi.RemoveStatus(Object, 'BANXIAN_LG_BING_XIAN')
        Osi.RemoveStatus(Object, 'BANXIAN_LG_BING_SHENG')
    end

    -- 血灵根: 木+火
    if e >= N and a >= N then
        Osi.ApplyStatus(Object, 'BANXIAN_LG_XUE', -1)
        LingGen.ApplyTierLingGen_Check(Object, 'BANXIAN_LG_XUE',
            e >= TIAN  and a >= TIAN,
            e >= XIAN  and a >= XIAN,
            e >= SHENG and a >= SHENG)
    else
        Osi.RemoveStatus(Object, 'BANXIAN_LG_XUE')
        Osi.RemoveStatus(Object, 'BANXIAN_LG_XUE_TIAN')
        Osi.RemoveStatus(Object, 'BANXIAN_LG_XUE_XIAN')
        Osi.RemoveStatus(Object, 'BANXIAN_LG_XUE_SHENG')
    end

    -- 雷灵根: 金+水
    if c >= N and d >= N then
        Osi.ApplyStatus(Object, 'BANXIAN_LG_LEI', -1)
        LingGen.ApplyTierLingGen_Check(Object, 'BANXIAN_LG_LEI',
            c >= TIAN  and d >= TIAN,
            c >= XIAN  and d >= XIAN,
            c >= SHENG and d >= SHENG)
    else
        Osi.RemoveStatus(Object, 'BANXIAN_LG_LEI')
        Osi.RemoveStatus(Object, 'BANXIAN_LG_LEI_TIAN')
        Osi.RemoveStatus(Object, 'BANXIAN_LG_LEI_XIAN')
        Osi.RemoveStatus(Object, 'BANXIAN_LG_LEI_SHENG')
    end

    -- 风灵根: 土+木
    if b >= N and e >= N then
        Osi.ApplyStatus(Object, 'BANXIAN_LG_FENG', -1)
        LingGen.ApplyTierLingGen_Check(Object, 'BANXIAN_LG_FENG',
            b >= TIAN  and e >= TIAN,
            b >= XIAN  and e >= XIAN,
            b >= SHENG and e >= SHENG)
    else
        Osi.RemoveStatus(Object, 'BANXIAN_LG_FENG')
        Osi.RemoveStatus(Object, 'BANXIAN_LG_FENG_TIAN')
        Osi.RemoveStatus(Object, 'BANXIAN_LG_FENG_XIAN')
        Osi.RemoveStatus(Object, 'BANXIAN_LG_FENG_SHENG')
    end

    -- 光灵根: 火+木+土
    if a >= N and e >= N and b >= N then
        Osi.ApplyStatus(Object, 'BANXIAN_LG_GUANG', -1)
        LingGen.ApplyTierLingGen_Check(Object, 'BANXIAN_LG_GUANG',
            a >= TIAN  and e >= TIAN  and b >= TIAN,
            a >= XIAN  and e >= XIAN  and b >= XIAN,
            a >= SHENG and e >= SHENG and b >= SHENG)
    else
        Osi.RemoveStatus(Object, 'BANXIAN_LG_GUANG')
        Osi.RemoveStatus(Object, 'BANXIAN_LG_GUANG_TIAN')
        Osi.RemoveStatus(Object, 'BANXIAN_LG_GUANG_XIAN')
        Osi.RemoveStatus(Object, 'BANXIAN_LG_GUANG_SHENG')
    end

    -- 暗灵根: 水+金+木
    if d >= N and c >= N and e >= N then
        Osi.ApplyStatus(Object, 'BANXIAN_LG_AN', -1)
        LingGen.ApplyTierLingGen_Check(Object, 'BANXIAN_LG_AN',
            d >= TIAN  and c >= TIAN  and e >= TIAN,
            d >= XIAN  and c >= XIAN  and e >= XIAN,
            d >= SHENG and c >= SHENG and e >= SHENG)
    else
        Osi.RemoveStatus(Object, 'BANXIAN_LG_AN')
        Osi.RemoveStatus(Object, 'BANXIAN_LG_AN_TIAN')
        Osi.RemoveStatus(Object, 'BANXIAN_LG_AN_XIAN')
        Osi.RemoveStatus(Object, 'BANXIAN_LG_AN_SHENG')
    end

    -- 毒灵根: 木+火+水
    if e >= N and a >= N and d >= N then
        Osi.ApplyStatus(Object, 'BANXIAN_LG_DU', -1)
        LingGen.ApplyTierLingGen_Check(Object, 'BANXIAN_LG_DU',
            e >= TIAN  and a >= TIAN  and d >= TIAN,
            e >= XIAN  and a >= XIAN  and d >= XIAN,
            e >= SHENG and a >= SHENG and d >= SHENG)
    else
        Osi.RemoveStatus(Object, 'BANXIAN_LG_DU')
        Osi.RemoveStatus(Object, 'BANXIAN_LG_DU_TIAN')
        Osi.RemoveStatus(Object, 'BANXIAN_LG_DU_XIAN')
        Osi.RemoveStatus(Object, 'BANXIAN_LG_DU_SHENG')
    end

    -- 混沌灵根: 五行皆备
    if a >= N and b >= N and c >= N and d >= N and e >= N then
        Osi.ApplyStatus(Object, 'BANXIAN_LG_HUNDUN', -1)
        LingGen.ApplyTierLingGen_Check(Object, 'BANXIAN_LG_HUNDUN',
            a >= TIAN  and b >= TIAN  and c >= TIAN  and d >= TIAN  and e >= TIAN,
            a >= XIAN  and b >= XIAN  and c >= XIAN  and d >= XIAN  and e >= XIAN,
            a >= SHENG and b >= SHENG and c >= SHENG and d >= SHENG and e >= SHENG)
    else
        Osi.RemoveStatus(Object, 'BANXIAN_LG_HUNDUN')
        Osi.RemoveStatus(Object, 'BANXIAN_LG_HUNDUN_TIAN')
        Osi.RemoveStatus(Object, 'BANXIAN_LG_HUNDUN_XIAN')
        Osi.RemoveStatus(Object, 'BANXIAN_LG_HUNDUN_SHENG')
    end

end

--合并检测（异灵根+主灵根，所有调用点均需同时触发两者）
function LingGen.ApplyAllChecks(Object)
    local a,b,c,d,e = Utils.Get.LingGen(Object)
    LingGen.ApplyYiLingGen_Check(Object, a, b, c, d, e)
    LingGen.ApplyTopLingGen_Check(Object, a, b, c, d, e)
end

--主灵根检测（凡10/天50/仙150/圣500）
function LingGen.ApplyTopLingGen_Check(Object, a, b, c, d, e)

    _P('主灵根检测')
    if not a then a,b,c,d,e = Utils.Get.LingGen(Object) end
    local NORMAL = 10
    local TIAN   = 50
    local XIAN   = 150
    local SHENG  = 500

    local map = {
        {val=a, base='BANXIAN_LG_HUO'},
        {val=b, base='BANXIAN_LG_TU'},
        {val=c, base='BANXIAN_LG_JIN'},
        {val=d, base='BANXIAN_LG_SHUI'},
        {val=e, base='BANXIAN_LG_MU'},
    }

    for _, entry in ipairs(map) do
        if entry.val >= NORMAL then
            Osi.ApplyStatus(Object, entry.base, -1, 1, Object)
            LingGen.ApplyTierLingGen_Check(Object, entry.base,
                entry.val >= TIAN,
                entry.val >= XIAN,
                entry.val >= SHENG)
        else
            Osi.RemoveStatus(Object, entry.base)
            Osi.RemoveStatus(Object, entry.base..'_TIAN')
            Osi.RemoveStatus(Object, entry.base..'_XIAN')
            Osi.RemoveStatus(Object, entry.base..'_SHENG')
        end
    end

end

--获取角色参数
function LingGen.GetCharacterParams(Object,a,b,c,d,e,r,TZ)
    if string.find(Object, 'Astarion') then
        a,b,c,d,e,r,TZ = 10,5,15,5,15,50,2
    elseif string.find(Object, 'Laezel') then
        a,b,c,d,e,r,TZ = 10,10,60,10,10,100,1
    elseif string.find(Object, 'Gale') then
        a,b,c,d,e,r,TZ = 4,4,4,4,4,20,5
    elseif string.find(Object, 'Shadowheart') then
        a,b,c,d,e,r,TZ = 20,20,25,25,10,100,1
    elseif string.find(Object, 'Wyll') then
        a,b,c,d,e,r,TZ = 0,20,30,0,0,50,2
    elseif string.find(Object, 'Jaheira') then
        a,b,c,d,e,r,TZ = 0,20,0,30,50,100,1
    elseif string.find(Object, 'Minthara') then
        a,b,c,d,e,r,TZ = 30,0,5,15,0,50,2
    elseif string.find(Object, 'Minsc') then
        a,b,c,d,e,r,TZ = 10,80,10,0,0,100,1
    elseif string.find(Object, 'Halsin') then
        a,b,c,d,e,r,TZ = 0,0,0,0,50,50,2
    elseif string.find(Object, 'Alfira') then
        a,b,c,d,e,r,TZ = 2,3,2,3,12,20,3
    elseif string.find(Object, 'Losiir') then
        a,b,c,d,e,r,TZ = 5,15,50,20,10,100,1
    elseif Osi.IsTagged(Object, 'fe825e69-1569-471f-9b3f-28fd3b929683') == 1 then
        a,b,c,d,e,r,TZ = 8,0,0,1,11,r,TZ
    end
    return a,b,c,d,e,r,TZ
end

--觉醒灵根
function LingGen.Add_First(Object)
    -- 五行灵根对应表（金->c,木->e,水->d,火->a,土->b）
    local lg = { a = 0, b = 0, c = 0, d = 0, e = 0 }

    _P('[Add_First] 开始觉醒灵根: '..tostring(Object))
    if Object == nil then _P('[Add_First] ERROR: Object为nil，跳过') return end
    _P('[Add_First] T0='..Osi.HasPassive(Object,'BanXian_LingGen_T0')..' T1='..Osi.HasPassive(Object,'BanXian_LingGen_T1')..' T2='..Osi.HasPassive(Object,'BanXian_LingGen_T2')..' T3='..Osi.HasPassive(Object,'BanXian_LingGen_T3')..' Blank='..Osi.HasPassive(Object,'BanXian_LingGen_Blank'))

    -- 获取随机灵根资质
    local r,TZ = Utils.LingGen.Random(1)
    _P('[Add_First] 随机初始值: r='..tostring(r)..' TZ='..tostring(TZ))

    -- 先天资质覆盖
    if Osi.HasPassive(Object, 'BanXian_LingGen_T0') == 1 then
        r,TZ = 100,math.random(6,10)
        _P('[Add_First] 先天道体覆盖: r='..r..' TZ='..TZ)
    elseif Osi.HasPassive(Object, 'BanXian_LingGen_T1') == 1 then
        r,TZ = 50,math.random(3,5)
        _P('[Add_First] 大帝之资覆盖: r='..r..' TZ='..TZ)
    elseif Osi.HasPassive(Object, 'BanXian_LingGen_T2') == 1 then
        r,TZ = 20,2
        _P('[Add_First] 先天慧根覆盖: r='..r..' TZ='..TZ)
    elseif Osi.HasPassive(Object, 'BanXian_LingGen_T3') == 1 then
        r,TZ = 10,1
        _P('[Add_First] 平平无奇覆盖: r='..r..' TZ='..TZ)
    elseif Osi.HasPassive(Object, 'BanXian_LingGen_Blank') == 1 then
        r,TZ = 0,0
        _P('[Add_First] 灵根破碎覆盖: r='..r..' TZ='..TZ)
    else
        _P('[Add_First] 随机灵根资质: r='..r..' TZ='..TZ)
    end

    -- 灵根分配策略优化
    if r >= 1 then
        -- 根据灵根类型生成偏向
        local Pf = {}
        local Pf_num
        if r <= 20 then -- 平平无奇/先天慧根（1-2个主属性）
            Pf_num = math.random(1,2)
            for k = 1, Pf_num do
                repeat -- 确保不重复属性
                    Pf[k] = math.random(1,5)
                until not Utils.contains(Pf, Pf[k], 1, k-1)
            end
        elseif r <= 30 then -- （2个主属性）
            Pf_num = 2
            for k = 1, 2 do
                repeat
                    Pf[k] = math.random(1,5)
                until not Utils.contains(Pf, Pf[k], 1, k-1)
            end
        elseif r <= 50 then -- 大帝之资（3个主属性）
            Pf_num = 3
            for k = 1, 3 do
                repeat
                    Pf[k] = math.random(1,5)
                until not Utils.contains(Pf, Pf[k], 1, k-1)
            end
        else -- 先天道体（4-5个属性）
            Pf_num = math.random(4,5)
            for k = 1, Pf_num do
                Pf[k] = k -- 按顺序生成避免重复
            end
            Utils.shuffle(Pf) -- 随机打乱顺序
        end

        -- 权重分配（优化后）
        local remaining = r
        for _, w in ipairs(Pf) do
            -- 主属性分配（占60%-80%权重）
            local max_ratio = (r <= 15) and 0.8 or 0.6
            local min_ratio = (r <= 15) and 0.6 or 0.4
            local ratio = math.random(min_ratio * 100, max_ratio * 100) / 100
            local value = math.floor(remaining * ratio / #Pf)
            
            -- 分配灵根权重
            if w == 1 then lg.a = lg.a + value
            elseif w == 2 then lg.b = lg.b + value
            elseif w == 3 then lg.c = lg.c + value
            elseif w == 4 then lg.d = lg.d + value
            elseif w == 5 then lg.e = lg.e + value end
            
            remaining = remaining - value
        end

        -- 剩余权重随机分配（保留原有机制）
        for i = 1, remaining do
            local w = math.random(1,5)
            if w == 1 then lg.a = lg.a + 1
            elseif w == 2 then lg.b = lg.b + 1
            elseif w == 3 then lg.c = lg.c + 1
            elseif w == 4 then lg.d = lg.d + 1
            else lg.e = lg.e + 1 end
        end
    end

    -- 保留后续处理逻辑不变
    lg.a,lg.b,lg.c,lg.d,lg.e,r,TZ = LingGen.GetCharacterParams(Object,lg.a,lg.b,lg.c,lg.d,lg.e,r,TZ)
    _P('[Add_First] GetCharacterParams后: r='..tostring(r)..' TZ='..tostring(TZ))

    --觉醒灵根
    if r == 100 then
        if Osi.HasPassive(Object,'BanXian_LingGen_T0') == 0 then
            Osi.AddPassive(Object, 'BanXian_LingGen_T0')
            Ext.Utils.Print('觉醒灵根资质[先天道体]:'..TZ..'资质点')
        end
    elseif r == 50 then
        if Osi.HasPassive(Object,'BanXian_LingGen_T1') == 0 then
            Osi.AddPassive(Object, 'BanXian_LingGen_T1')
            Ext.Utils.Print('觉醒灵根资质[大帝之资]:'..TZ..'资质点')
        end
    elseif r == 20 then
        if Osi.HasPassive(Object,'BanXian_LingGen_T2') == 0 then
            Osi.AddPassive(Object, 'BanXian_LingGen_T2')
            Ext.Utils.Print('觉醒灵根资质[先天慧根]:'..TZ..'资质点')
        end
    elseif r == 10 then
        if Osi.HasPassive(Object,'BanXian_LingGen_T3') == 0 then
            Osi.AddPassive(Object, 'BanXian_LingGen_T3')
            Ext.Utils.Print('觉醒灵根资质[平平无奇]:'..TZ..'资质点')
        end
    end

    --资质点分配
    _P('[Add_First] 最终ApplyStatus BANXIAN_LG_TZ='..tostring(TZ))
    Osi.ApplyStatus(Object,'BANXIAN_LG_TZ', TZ * 6)

    if lg.a > 0 then
        Osi.ApplyStatus(Object, 'BANXIAN_LG_H', lg.a * 6)
        Ext.Utils.Print('觉醒灵根[火]:'..lg.a..'/'..r)
    end
    if lg.b > 0 then
        Osi.ApplyStatus(Object, 'BANXIAN_LG_T', lg.b * 6)
        Ext.Utils.Print('觉醒灵根[土]:'..lg.b..'/'..r)
    end
    if lg.c > 0 then
        Osi.ApplyStatus(Object, 'BANXIAN_LG_J', lg.c * 6)
        Ext.Utils.Print('觉醒灵根[金]:'..lg.c..'/'..r)
    end
    if lg.d > 0 then
        Osi.ApplyStatus(Object, 'BANXIAN_LG_S', lg.d * 6)
        Ext.Utils.Print('觉醒灵根[水]:'..lg.d..'/'..r)
    end
    if lg.e > 0 then
        Osi.ApplyStatus(Object, 'BANXIAN_LG_M', lg.e * 6)
        Ext.Utils.Print('觉醒灵根[木]:'..lg.e..'/'..r)
    end
    LingGen.ApplyAllChecks(Object)
    Utils.ShenShi.Check(Object)
    Utils.BanXianList_AddtoList(Object)
end

--夺取灵根
function LingGen.Take_Devastatingly(caster, target)
    if Osi.IsDead(target) == 1 then return end

    --夺取灵根配比（累加到施法者现有灵根）
    Osi.AddPassive(target, 'BanXian_LingGen_NIL')
    local result_parts = {}
    for LG, NAME in pairs(Variables.Constants.LingGen) do

        if Osi.HasActiveStatus(target, LG) == 1 then
            local target_turn = Osi.GetStatusTurns(target, LG)
            local caster_turn = Osi.GetStatusTurns(caster, LG)
            Osi.RemoveStatus(target, LG)
            Osi.RemoveStatus(caster, LG)
            Osi.ApplyStatus(caster, LG, (target_turn + caster_turn) * 6, 1, caster)
            table.insert(result_parts, NAME .. '灵根+' .. target_turn)
        end

    end

    --输出夺灵结果
    if #result_parts > 0 then
        Osi.ShowNotification(caster, '夺灵成功：' .. table.concat(result_parts, '  '))
    end

    --重新检测施法者灵根效果
    LingGen.ApplyAllChecks(caster)

    --重新检测目标灵根效果（清除已失效的异灵根）
    LingGen.ApplyAllChecks(target)

end


-----------------------------------------------------------
--混沌灵根
function LingGen.HunDun_ShortRest(Object)
    local entity = Ext.Entity.Get(Object)
    --_D(entity.ActionResources) --DEBUG

    for _, ResourceList in pairs(entity.ActionResources.Resources) do
        for _, Resource in ipairs(ResourceList) do -- ResourceList是GUID对应的资源列表
        --_D(Resource) --DEBUG
        local ReplenishType = Resource.ReplenishType
        for _, type in ipairs(ReplenishType) do
            if type == "Rest" then
                Resource.Amount = Resource.MaxAmount
            end
        end
        end
    end
    entity:Replicate("ActionResources")
end

--血灵根
function LingGen.Xue_ApplyBloodCurse(Object,Causee)
    local Key = math.random(1,23)
    local Curse = Variables.Constants.LingGenXue.BloodCurse[Key]

    Osi.ApplyStatus(Object, Curse, 18, 1, Causee)
end






-- 事件·灵根状态
function LingGen.OnStatusApplied_after(Object, Status, Causee)
    local hasAwakened = Osi.HasPassive(Object, 'BanXian_LingGen')    == 1
                     or Osi.HasPassive(Object, 'BanXian_LingGen_Blank') == 1
                     or Osi.HasPassive(Object, 'BanXian_LingGen_T0')   == 1
                     or Osi.HasPassive(Object, 'BanXian_LingGen_T1')   == 1
                     or Osi.HasPassive(Object, 'BanXian_LingGen_T2')   == 1
                     or Osi.HasPassive(Object, 'BanXian_LingGen_T3')   == 1
    if not hasAwakened then --没有觉醒过灵根
        if Status == "BANXIAN_DAOXIN" then  --创建角色：谪仙
            _P("[EventHandlers] 事件·觉醒灵根: ") 
            PersistentVars['BXAddLingGen_Waiting'] = Object
            _P('[PersistentVars]记录数据[BXAddLingGen_Waiting]:'..Object) --DEBUG
            Osi.TimerLaunch('BanXian_AddLingGen', 10000)
        elseif Status == "POTION_OF_VITALITY" then  --活力药水觉醒
            LingGen.Add_First(Object)
        end
    elseif Status == "BANXIAN_TAKELINGGEN" then
        LingGen.Take_Devastatingly(Causee, Object)
    end

    if Status == 'SIGNAL_YLG_CHECK' then
        LingGen.ApplyAllChecks(Object)
    end

    if Status == "SIGNAL_LG_HUNDUN_SHORTREST" then
        LingGen.HunDun_ShortRest(Object) 
    end

    if Status == "BLEEDING" then
        if Osi.HasActiveStatus(Causee, 'BANXIAN_LG_XUE') == 1 then
            LingGen.Xue_ApplyBloodCurse(Object, Causee)
        end
    end

end

-- 事件·灵根洗点
function LingGen.OnRespecCompleted_after(Character)

    if Osi.HasPassive(Character,'BanXian_DH_DaoXin') == 1 then
        LingGen.ApplyYiLingGen_Check(Character)
        Osi.ApplyStatus(Character, 'SIGNAL_DAOXINCHECK', 0, 1, Character)
    end

end

return LingGen
