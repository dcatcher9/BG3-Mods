local LingGen = {}
local Variables = require("Server.Modules.Variables")
local Utils = require("Server.Modules.Utils")

-- 初始化灵根系统
function LingGen.Init()

    -- 注册事件监听灵根相关状态
    Ext.Osiris.RegisterListener("StatusApplied", 4, "after", LingGen.OnStatusApplied_after)

    -- 注册事件监听灵根相关洗点
    Ext.Osiris.RegisterListener("RespecCompleted", 1, "after", LingGen.OnRespecCompleted_after)

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

-- 异灵根定义表（YI=50；TIAN=200；XIAN=600；SHENG=2000）
-- 参数映射: a=火(H), b=土(T), c=金(J), d=水(S), e=木(M)
local YI_LING_GEN_DEFS = {
    { status = 'BANXIAN_LG_BING',   components = {'d', 'b'} },                          -- 冰: 水+土
    { status = 'BANXIAN_LG_XUE',    components = {'e', 'a'} },                          -- 血: 木+火
    { status = 'BANXIAN_LG_LEI',    components = {'c', 'd'} },                          -- 雷: 金+水
    { status = 'BANXIAN_LG_FENG',   components = {'b', 'e'} },                          -- 风: 土+木
    { status = 'BANXIAN_LG_GUANG',  components = {'a', 'e', 'b'} },                     -- 光: 火+木+土
    { status = 'BANXIAN_LG_AN',     components = {'d', 'c', 'e'} },                     -- 暗: 水+金+木
    { status = 'BANXIAN_LG_DU',     components = {'e', 'a', 'd'} },                     -- 毒: 木+火+水
    { status = 'BANXIAN_LG_HUNDUN', components = {'a', 'b', 'c', 'd', 'e'} },           -- 混沌: 五行皆备
}

--异灵根检测（YI=50；TIAN=200；XIAN=600；SHENG=2000）
function LingGen.ApplyYiLingGen_Check(Object, a, b, c, d, e)

    if not a then a,b,c,d,e = Utils.Get.LingGen(Object) end
    local YI    = 50   -- 异
    local TIAN  = 200  -- 天异 (× 2)
    local XIAN  = 600  -- 仙异 (× 2)
    local SHENG = 2000 -- 圣异 (× 2)

    local vals = { a = a, b = b, c = c, d = d, e = e }

    for _, def in ipairs(YI_LING_GEN_DEFS) do
        local ok = true
        for _, comp in ipairs(def.components) do
            if (vals[comp] or 0) < YI then ok = false; break end
        end
        if ok then
            Osi.ApplyStatus(Object, def.status, -1, 1, Object)
            local tian_c, xian_c, sheng_c = true, true, true
            for _, comp in ipairs(def.components) do
                local v = vals[comp] or 0
                if v < TIAN  then tian_c  = false end
                if v < XIAN  then xian_c  = false end
                if v < SHENG then sheng_c = false end
            end
            LingGen.ApplyTierLingGen_Check(Object, def.status, tian_c, xian_c, sheng_c)
        else
            Osi.RemoveStatus(Object, def.status)
            Osi.RemoveStatus(Object, def.status .. '_TIAN')
            Osi.RemoveStatus(Object, def.status .. '_XIAN')
            Osi.RemoveStatus(Object, def.status .. '_SHENG')
        end
    end

end

--合并检测（异灵根+主灵根，所有调用点均需同时触发两者）
function LingGen.ApplyAllChecks(Object)
    local a,b,c,d,e = Utils.Get.LingGen(Object)
    LingGen.ApplyYiLingGen_Check(Object, a, b, c, d, e)
    LingGen.ApplyTopLingGen_Check(Object, a, b, c, d, e)
end

--主灵根检测（凡25/天100/仙300/圣1000）
function LingGen.ApplyTopLingGen_Check(Object, a, b, c, d, e)

    if not a then a,b,c,d,e = Utils.Get.LingGen(Object) end
    local NORMAL = 25
    local TIAN   = 100
    local XIAN   = 300
    local SHENG  = 1000

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
    local entity = Ext.Entity.Get(Object)
    local templateName = entity and entity.ServerCharacter and entity.ServerCharacter.Template and entity.ServerCharacter.Template.Name or ""
    local params = Variables.Constants.CompanionLingGen[templateName]
    if params then
        a,b,c,d,e,r,TZ = params[1],params[2],params[3],params[4],params[5],params[6],params[7]
    else
        -- Alfira/Losiir没有Origin，回退到名称匹配；谪仙玩家角色检查种族标签
        local displayName = Osi.GetDisplayName(Object) or ""
        local found = false
        for name, p in pairs(Variables.Constants.CompanionLingGen_ByName) do
            if string.find(displayName, name) then
                a,b,c,d,e,r,TZ = p[1],p[2],p[3],p[4],p[5],p[6],p[7]
                found = true
                break
            end
        end
        if not found and Osi.IsTagged(Object, 'fe825e69-1569-471f-9b3f-28fd3b929683') == 1 then  -- 谪仙种族标签 UUID（见 Public/XSS_BANXIAN/Tags/）
            a,b,c,d,e,r,TZ = 16,0,0,2,22,r,TZ
        end
    end
    return a,b,c,d,e,r,TZ
end

--觉醒灵根
function LingGen.Add_First(Object)
    -- 五行灵根对应表（金->c,木->e,水->d,火->a,土->b）
    local lg = { a = 0, b = 0, c = 0, d = 0, e = 0 }

    if Object == nil then _P('[Add_First] ERROR: Object为nil，跳过') return end

    -- 获取随机灵根资质
    local r,TZ = Utils.LingGen.Random(1)

    -- 先天资质覆盖
    if Osi.HasPassive(Object, 'BanXian_LingGen_T0') == 1 then
        r,TZ = 200,math.random(6,10)
    elseif Osi.HasPassive(Object, 'BanXian_LingGen_T1') == 1 then
        r,TZ = 100,math.random(3,5)
    elseif Osi.HasPassive(Object, 'BanXian_LingGen_T2') == 1 then
        r,TZ = 40,2
    elseif Osi.HasPassive(Object, 'BanXian_LingGen_T3') == 1 then
        r,TZ = 20,1
    elseif Osi.HasPassive(Object, 'BanXian_LingGen_Blank') == 1 then
        r,TZ = 0,0
    end

    -- 灵根分配策略优化
    if r >= 1 then
        -- 根据灵根类型生成偏向
        local Pf = {}
        local Pf_num
        if r <= 40 then -- 平平无奇/先天慧根（1-2个主属性）
            Pf_num = math.random(1,2)
            for k = 1, Pf_num do
                repeat -- 确保不重复属性
                    Pf[k] = math.random(1,5)
                until not Utils.contains(Pf, Pf[k], 1, k-1)
            end
        elseif r <= 60 then -- （2个主属性）
            Pf_num = 2
            for k = 1, 2 do
                repeat
                    Pf[k] = math.random(1,5)
                until not Utils.contains(Pf, Pf[k], 1, k-1)
            end
        elseif r <= 100 then -- 大帝之资（3个主属性）
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
            local ratio = math.random(math.floor(min_ratio * 100), math.ceil(max_ratio * 100)) / 100
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

    --觉醒灵根
    if r == 200 then
        if Osi.HasPassive(Object,'BanXian_LingGen_T0') == 0 then
            Osi.AddPassive(Object, 'BanXian_LingGen_T0')
            Ext.Utils.Print('觉醒灵根资质[先天道体]:'..TZ..'资质点')
        end
    elseif r == 100 then
        if Osi.HasPassive(Object,'BanXian_LingGen_T1') == 0 then
            Osi.AddPassive(Object, 'BanXian_LingGen_T1')
            Ext.Utils.Print('觉醒灵根资质[大帝之资]:'..TZ..'资质点')
        end
    elseif r == 40 then
        if Osi.HasPassive(Object,'BanXian_LingGen_T2') == 0 then
            Osi.AddPassive(Object, 'BanXian_LingGen_T2')
            Ext.Utils.Print('觉醒灵根资质[先天慧根]:'..TZ..'资质点')
        end
    elseif r == 20 then
        if Osi.HasPassive(Object,'BanXian_LingGen_T3') == 0 then
            Osi.AddPassive(Object, 'BanXian_LingGen_T3')
            Ext.Utils.Print('觉醒灵根资质[平平无奇]:'..TZ..'资质点')
        end
    end

    --资质点分配
    Osi.ApplyStatus(Object,'BANXIAN_LG_TZ', TZ * 6, 1, Object)

    if lg.a > 0 then
        Osi.ApplyStatus(Object, 'BANXIAN_LG_H', lg.a * 6, 1, Object)
        Ext.Utils.Print('觉醒灵根[火]:'..lg.a..'/'..r)
    end
    if lg.b > 0 then
        Osi.ApplyStatus(Object, 'BANXIAN_LG_T', lg.b * 6, 1, Object)
        Ext.Utils.Print('觉醒灵根[土]:'..lg.b..'/'..r)
    end
    if lg.c > 0 then
        Osi.ApplyStatus(Object, 'BANXIAN_LG_J', lg.c * 6, 1, Object)
        Ext.Utils.Print('觉醒灵根[金]:'..lg.c..'/'..r)
    end
    if lg.d > 0 then
        Osi.ApplyStatus(Object, 'BANXIAN_LG_S', lg.d * 6, 1, Object)
        Ext.Utils.Print('觉醒灵根[水]:'..lg.d..'/'..r)
    end
    if lg.e > 0 then
        Osi.ApplyStatus(Object, 'BANXIAN_LG_M', lg.e * 6, 1, Object)
        Ext.Utils.Print('觉醒灵根[木]:'..lg.e..'/'..r)
    end
    LingGen.ApplyAllChecks(Object)
    Utils.ShenShi.Check(Object)
    Utils.BanXianList_AddtoList(Object)
end

--夺取灵根
function LingGen.Take_Devastatingly(caster, target)
    if Osi.IsDead(target) == 1 then return end

    -- 找目标最大灵根
    local maxVal, maxLG, maxName = 0, nil, nil
    for LG, NAME in pairs(Variables.Constants.LingGen) do
        local val = Osi.GetStatusTurns(target, LG) or 0
        if val > maxVal then
            maxVal, maxLG, maxName = val, LG, NAME
        end
    end

    if not maxLG or maxVal <= 0 then return end

    -- 夺取最大灵根的一半
    local steal = math.floor(maxVal / 2)
    local remain = maxVal - steal
    local casterVal = Osi.GetStatusTurns(caster, maxLG) or 0

    Osi.ApplyStatus(target, maxLG, remain * 6, 1, target)
    Osi.ApplyStatus(caster, maxLG, (casterVal + steal) * 6, 1, caster)

    -- 夺取资质的 1/3
    local targetTZ = Osi.GetStatusTurns(target, 'BANXIAN_LG_TZ') or 0
    local stealTZ = math.floor(targetTZ / 3)
    if stealTZ > 0 then
        local casterTZ = Osi.GetStatusTurns(caster, 'BANXIAN_LG_TZ') or 0
        Osi.ApplyStatus(target, 'BANXIAN_LG_TZ', (targetTZ - stealTZ) * 6, 1, target)
        Osi.ApplyStatus(caster, 'BANXIAN_LG_TZ', (casterTZ + stealTZ) * 6, 1, caster)
    end

    local msg = '夺灵：' .. maxName .. '灵根 ×' .. steal
    if stealTZ > 0 then msg = msg .. '  资质 ×' .. stealTZ end
    Osi.ShowNotification(caster, msg)

    -- 重新检测双方灵根效果
    LingGen.ApplyAllChecks(caster)
    LingGen.ApplyAllChecks(target)

end

-----------------------------------------------------------
--混沌灵根
function LingGen.HunDun_ShortRest(Object)
    local entity = Ext.Entity.Get(Object)
    if not entity then return end
    --_D(entity.ActionResources) --DEBUG

    for _, ResourceList in pairs(entity.ActionResources.Resources) do
        for _, Resource in ipairs(ResourceList) do -- ResourceList是GUID对应的资源列表
        --_D(Resource) --DEBUG
        if Resource.ReplenishType == "ShortRest" then
            Resource.Amount = Resource.MaxAmount
        end
        end
    end
    entity:Replicate("ActionResources")
end

--血灵根
function LingGen.Xue_ApplyBloodCurse(Object,Causee)
    local Key = math.random(1, #Variables.Constants.LingGenXue.BloodCurse)
    local Curse = Variables.Constants.LingGenXue.BloodCurse[Key]

    Osi.ApplyStatus(Object, Curse, 18, 1, Causee)
end

-- 事件·灵根状态
function LingGen.OnStatusApplied_after(Object, Status, Causee)
    local hasAwakened = Osi.HasPassive(Object, 'BanXian_LingGen')      == 1
                     or Osi.HasPassive(Object, 'BanXian_LingGen_NIL')  == 1
                     or Osi.HasPassive(Object, 'BanXian_LingGen_Blank') == 1
                     or Osi.HasPassive(Object, 'BanXian_LingGen_T0')   == 1
                     or Osi.HasPassive(Object, 'BanXian_LingGen_T1')   == 1
                     or Osi.HasPassive(Object, 'BanXian_LingGen_T2')   == 1
                     or Osi.HasPassive(Object, 'BanXian_LingGen_T3')   == 1
    if not hasAwakened then --没有觉醒过灵根
        if Status == "BANXIAN_DAOXIN" then  --创建角色：谪仙
            PersistentVars['BXAddLingGen_Waiting'] = Object
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
        LingGen.ApplyAllChecks(Character)
        Osi.ApplyStatus(Character, 'SIGNAL_DAOXINCHECK', 0, 1, Character)
    end

end

return LingGen
