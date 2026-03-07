local ZhenFa = {
    Tool = {},
    Core = {},
    Flags = {}
}
local Variables = require("Server.Modules.Variables")
local Utils = require("Server.Modules.Utils")

-- 初始化阵法系统
function ZhenFa.Init()
    _P("[ZhenFa] 初始化阵法系统...")

    -- 注册事件监听阵法相关状态
    Ext.Osiris.RegisterListener("StatusApplied", 4, "after", ZhenFa.OnStatusApplied_after)

    -- 注册事件监听阵法相关施法1
    Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", ZhenFa.OnUsingSpellOnTarget_after)

    -- 注册事件监听阵法相关施法2
    Ext.Osiris.RegisterListener("UsingSpellAtPosition", 8, "after", ZhenFa.OnUsingSpellAtPosition_after)


    _P("[ZhenFa] 阵法系统初始化完成！")
end



--聚灵阵阵眼注册
function ZhenFa.Core.Register(Object,Status)

    for i = 1, 9, 1 do
        if Status == 'BANXIAN_ZHENFA_CORE_JULING_AURA_'..i then
            PersistentVars['ZhenFa_Core_JuLing'] = Object
            _P('[PersistentVars]记录数据[ZhenFa_Core_JuLing]:'..Object) --DEBUG
            PersistentVars['ZhenFa_Core_JuLing_LEVEL'] = i
            _P('[PersistentVars]记录数据[ZhenFa_Core_JuLing_LEVEL]:'..i) --DEBUG
            _P('[已安置'..i..'级阵眼]'..PersistentVars['ZhenFa_Core_JuLing'])
        end
    end
    
end

--聚灵阵激活判定
function ZhenFa.Core.Check(CoreRadius,Offset)
    local Core = PersistentVars['ZhenFa_Core_JuLing']
    _P('阵法检查：聚灵阵*******') --DEBUG

    for FLAG, NAME in pairs(Variables.Constants.ZhenFa.Flags) do
        if PersistentVars[FLAG] ~= nil then
            local Flag = PersistentVars[FLAG]
            local ToWards = Variables.Constants.ZhenFa.Core.JuLing.ToWards[FLAG]
            local X,Y,TW,Radius = Utils.ZhenFa.GetFlagsParams(Flag,Core)
            if TW ~= ToWards then
                return '未激活]原因：'..NAME..'旗方位不是'..ToWards
            end
            if Radius > Offset or Radius < CoreRadius then
                return '未激活]原因：'..NAME..'旗距离错误'
            end
            _P('[阵旗激活]：'..NAME)
        else
            return '未激活]原因：'..NAME..'旗缺失'
        end
    end
    return '已激活]'
end

--聚灵阵增益应用
function ZhenFa.Core.Functors(CoreRadius,Offset)
    if PersistentVars['ZhenFa_Core_JuLing'] ~= nil then
        local Core = PersistentVars['ZhenFa_Core_JuLing']
        local level = PersistentVars['ZhenFa_Core_JuLing_LEVEL']
        local STATUS = 'BANXIAN_ZHENFA_CORE_JULING_TOGGLEON_'..level
        local RESULT = ZhenFa.Core.Check(CoreRadius,Offset)

        if RESULT == '已激活]' and Osi.HasActiveStatus(Core, STATUS) == 0 then
            Osi.ApplyStatus(Core, STATUS, -1, 1, Core)
            return true
        elseif RESULT ~= '已激活]' and Osi.HasActiveStatus(Core, STATUS) == 1 then
            Osi.RemoveStatus(Core, STATUS)
            return false
        end

    else
        _P('缺少阵眼')
        return 
    end
end



--阵旗检测
function ZhenFa.Flags.Check(Object,Core)
    if Core ~= nil then
        for FLAG, NAME in pairs(Variables.Constants.ZhenFa.Flags) do
            if PersistentVars[FLAG] == Object then
                local X,Y,TW,Radius = Utils.ZhenFa.GetFlagsParams(Object,Core)
                _P('[安置阵旗参数]'..NAME..": "..'相对坐标('..X..','..Y..')'..' 方位：'..TW.." 距离："..Radius)
            end
        end
        local STATU = ZhenFa.Core.Functors(6,6.8)
        
        if STATU == true then
            _P('聚灵阵激活')
        elseif STATU == false then
            _P('聚灵阵关闭')
        end
    end
end


--罗盘测算
function ZhenFa.Tool.LuoPanFunctors(Caster,X,Z)
    local MESSAGE = "[罗盘测算] 世界平面坐标："..Utils.TakePoint(X, 0.1)..", "..Utils.TakePoint(Z, 0.1)

    if PersistentVars['ZhenFa_Core_JuLing'] ~= nil then
        local Core = PersistentVars['ZhenFa_Core_JuLing']
        local CX,CZ = Utils.GetXZ(Core)
        local dX,dZ = X-CX,Z-CZ
        local TW =  Utils.XZGetTowards(dX,dZ)
        local Radius = Utils.TakePoint((math.sqrt(dX*dX + dZ*dZ)),0.1)
        local RESULT = ZhenFa.Core.Check(6,6.8)
        local level = PersistentVars['ZhenFa_Core_JuLing_LEVEL']
        local STATUS = 'BANXIAN_ZHENFA_CORE_JULING_TOGGLEON_'..level
        
        ZhenFa.Core.Functors(6, 6.8)

        local MESSAGE_ADD = "\n[阵法测算·聚灵阵] 方位："..TW.."   平面距离："..Radius.."   \n[测算结果："..RESULT
        MESSAGE = MESSAGE..MESSAGE_ADD
    end

    Osi.OpenMessageBox(Caster, MESSAGE)
end



-- 事件·阵法状态监听
function ZhenFa.OnStatusApplied_after(Object, Status, Causee)

    if string.find(Status,"BANXIAN_ZHENFA_CORE_JULING_AURA") then --聚灵阵阵眼注册
        ZhenFa.Core.Register(Object,Status)
    elseif Status == 'BANXIAN_ZHENFA_CORE_JULING' then
        local Core = PersistentVars['ZhenFa_Core_JuLing']
        ZhenFa.Flags.Check(Object,Core)
    elseif Status == 'BANXIAN_ZHENFA_FALGS_JULING_AURA_QIAN'  then
        PersistentVars['ZhenFa_Flags_Qian'] = Object
        _P('[PersistentVars]记录数据[ZhenFa_Flags_Qian]:'..Object) --DEBUG
        _P('[安置阵旗：乾]'..PersistentVars['ZhenFa_Flags_Qian'])
    elseif Status == 'BANXIAN_ZHENFA_FALGS_JULING_AURA_KUN'  then
        PersistentVars['ZhenFa_Flags_Kun'] = Object
        _P('[PersistentVars]记录数据[ZhenFa_Flags_Kun]:'..Object) --DEBUG
        _P('[安置阵旗：坤]'..PersistentVars['ZhenFa_Flags_Kun'])
    elseif Status == 'BANXIAN_ZHENFA_FALGS_JULING_AURA_XUN'  then
        PersistentVars['ZhenFa_Flags_Xun'] = Object
        _P('[PersistentVars]记录数据[ZhenFa_Flags_Xun]:'..Object) --DEBUG
        _P('[安置阵旗：巽]'..PersistentVars['ZhenFa_Flags_Xun'])
    elseif Status == 'BANXIAN_ZHENFA_FALGS_JULING_AURA_ZHEN'  then
        PersistentVars['ZhenFa_Flags_Zhen'] = Object
        _P('[PersistentVars]记录数据[ZhenFa_Flags_Zhen]:'..Object) --DEBUG
        _P('[安置阵旗：震]'..PersistentVars['ZhenFa_Flags_Zhen'])
    elseif Status == 'BANXIAN_ZHENFA_FALGS_JULING_AURA_KAN'  then
        PersistentVars['ZhenFa_Flags_Kan'] = Object
        _P('[PersistentVars]记录数据[ZhenFa_Flags_Kan]:'..Object) --DEBUG
        _P('[安置阵旗：坎]'..PersistentVars['ZhenFa_Flags_Kan'])
    elseif Status == 'BANXIAN_ZHENFA_FALGS_JULING_AURA_LI'  then
        PersistentVars['ZhenFa_Flags_Li'] = Object
        _P('[PersistentVars]记录数据[ZhenFa_Flags_Li]:'..Object) --DEBUG
        _P('[安置阵旗：离]'..PersistentVars['ZhenFa_Flags_Li'])
    elseif Status == 'BANXIAN_ZHENFA_FALGS_JULING_AURA_GEN'  then
        PersistentVars['ZhenFa_Flags_Gen'] = Object
        _P('[PersistentVars]记录数据[ZhenFa_Flags_Gen]:'..Object) --DEBUG
        _P('[安置阵旗：艮]'..PersistentVars['ZhenFa_Flags_Gen'])
    elseif Status == 'BANXIAN_ZHENFA_FALGS_JULING_AURA_DUI'  then
        PersistentVars['ZhenFa_Flags_Dui'] = Object
        _P('[PersistentVars]记录数据[ZhenFa_Flags_Dui]:'..Object) --DEBUG
        _P('[安置阵旗：兑]'..PersistentVars['ZhenFa_Flags_Dui'])
    end

end

-- 事件·阵法施法监听1
function ZhenFa.OnUsingSpellOnTarget_after(caster, target, name, _, _, _, _)

    if name == 'ZhenFa_Tool_LuoPan_Measure' then
        Variables.Constants.ZhenFa.LuoPan.Caster = caster
        Variables.Constants.ZhenFa.LuoPan.X,Variables.Constants.ZhenFa.LuoPan.Z = Utils.GetXZ(target)
        Osi.TimerLaunch('Banxian_LuoPan_Caculate', 1000)
    end

end

-- 事件·阵法施法监听2
function ZhenFa.OnUsingSpellAtPosition_after(Caster, X, Y, Z, Spell, SpellType, SpellElement, StoryActionID)

    if Spell == 'ZhenFa_Tool_LuoPan_Measure' then
        Variables.Constants.ZhenFa.LuoPan.Caster,Variables.Constants.ZhenFa.LuoPan.X,Variables.Constants.ZhenFa.LuoPan.Z = Caster,X,Z
        Osi.TimerLaunch('Banxian_LuoPan_Caculate', 1000)
    end

end


return ZhenFa
