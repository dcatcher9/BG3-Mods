local GongFa = {
    Tianxian = {
        ZhouTianCuiTi = {},
        BaiMaiDuanBao = {}
    }
}
local Utils = require("Server.Modules.Utils")

-- 初始化功法系统
function GongFa.Init()

    -- 注册事件监听功法相关状态
    Ext.Osiris.RegisterListener("StatusApplied", 4, "after", GongFa.OnStatusApplied_after)


    _P("[GongFa] 功法系统初始化完成！")
end



--周天淬体诀
function GongFa.Tianxian.ZhouTianCuiTi.Check(Object)
    local BanXian_CuiTi = 'CuiTi_ZhouTian_'
    local CuiTi_ZhouTian_Short = false
    local CuiTi_ZhouTian_Long = true

    for i = 1, 12, 1 do --大周天，检查是否已全部淬体
        if Osi.HasPassive(Object, BanXian_CuiTi..i) == 0 then
            CuiTi_ZhouTian_Long = false
        end
    end

    if Osi.HasPassive(Object, 'CuiTi_ZhouTian_1') == 1 and Osi.HasPassive(Object, 'CuiTi_ZhouTian_5') == 1 and Osi.HasPassive(Object, 'CuiTi_ZhouTian_7') == 1 and Osi.HasPassive(Object, 'CuiTi_ZhouTian_12') == 1  then
        CuiTi_ZhouTian_Short = true
    end

    if CuiTi_ZhouTian_Short == true  and Osi.HasPassive(Object, 'CuiTi_ZhouTian_ShortBreak') == 0 then   --检查是否已激活小周天，防止重复获得被动
        Osi.AddPassive(Object, 'CuiTi_ZhouTian_ShortBreak')
        _P("激活：小周天")
    elseif CuiTi_ZhouTian_Short == false  and Osi.HasPassive(Object, 'CuiTi_ZhouTian_ShortBreak') == 1 then
        Osi.RemovePassive(Object, 'CuiTi_ZhouTian_ShortBreak')
        _P("移除：小周天")
    end

    if CuiTi_ZhouTian_Long == true  and Osi.HasPassive(Object, 'CuiTi_ZhouTian_LongBreak') == 0 then
        Osi.AddPassive(Object, 'CuiTi_ZhouTian_LongBreak')
        _P("激活：大周天")
    elseif CuiTi_ZhouTian_Long == false  and Osi.HasPassive(Object, 'CuiTi_ZhouTian_LongBreak') == 1 then
        Osi.RemovePassive(Object, 'CuiTi_ZhouTian_LongBreak')
        _P("移除：大周天")
    end
    
end


--周天淬体诀:SHORTREST
function GongFa.Tianxian.ZhouTianCuiTi.ShortRest(Object)
    local entity = Ext.Entity.Get(Object)
    --_D(entity.ActionResources) --DEBUG
    
    for ResourceUUID, ResourceList in pairs(entity.ActionResources.Resources) do
        for _, Resource in ipairs(ResourceList) do -- ResourceList是GUID对应的资源列表
            -- 处理逻辑
        local ReplenishType = Resource.ReplenishType
        for _, type in ipairs(ReplenishType) do
            if type == "ShortRest" then
                Resource.Amount = Resource.MaxAmount
            end
        end
        end
    end

end

--周天淬体诀:LONGREST
function GongFa.Tianxian.ZhouTianCuiTi.LongRest(Object)
    local entity = Ext.Entity.Get(Object)
    --_D(entity.ActionResources) --DEBUG

    for ResourceUUID, ResourceList in pairs(entity.ActionResources.Resources) do
        for _, Resource in ipairs(ResourceList) do -- ResourceList是GUID对应的资源列表
            -- 处理逻辑
        local ReplenishType = Resource.ReplenishType
        for _, type in ipairs(ReplenishType) do
            if type == "Rest" then
                Resource.Amount = Resource.MaxAmount
            end
        end
        end
    end
    
end

--百脉锻宝诀
function GongFa.Tianxian.BaiMaiDuanBao.Check(Object)
    local FaBao_BaiMai = 'FABAO_BAIMAI_'
    local FABAO_BAIMAI_A1 = false
    local FABAO_BAIMAI_A2 = false
    local FABAO_BAIMAI_S = true

    for i = 1, 6, 1 do --大成，检查锻宝是否全部完成
        if Osi.HasPassive(Object, FaBao_BaiMai..i) == 0 then
            FABAO_BAIMAI_S = false
        end
    end

    if Osi.HasPassive(Object, 'FABAO_BAIMAI_2') == 1 and Osi.HasPassive(Object, 'FABAO_BAIMAI_3') == 1 then
        FABAO_BAIMAI_A1 = true
    end

    if Osi.HasPassive(Object, 'FABAO_BAIMAI_4') == 1 and Osi.HasPassive(Object, 'FABAO_BAIMAI_5') == 1 then
        FABAO_BAIMAI_A2 = true
    end

    if FABAO_BAIMAI_A1 == true and Osi.HasPassive(Object, 'FABAO_BAIMAI_A1') == 0 then
        Osi.AddPassive(Object, 'FABAO_BAIMAI_A1')
        _P("激活：千手")
    elseif FABAO_BAIMAI_A1 == false  and Osi.HasPassive(Object, 'FABAO_BAIMAI_A1') == 1 then
        Osi.RemovePassive(Object, 'FABAO_BAIMAI_A1')
        _P("移除：千手")
    end

    if FABAO_BAIMAI_A2 == true and Osi.HasPassive(Object, 'FABAO_BAIMAI_A2') == 0 then
        Osi.AddPassive(Object, 'FABAO_BAIMAI_A2')
        _P("激活：齐天")
    elseif FABAO_BAIMAI_A2 == false  and Osi.HasPassive(Object, 'FABAO_BAIMAI_A2') == 1 then
        Osi.RemovePassive(Object, 'FABAO_BAIMAI_A2')
        _P("移除：齐天")
    end

    if FABAO_BAIMAI_S == true and Osi.HasPassive(Object, 'FABAO_BAIMAI_S') == 0 then
        if Osi.HasActiveStatus(Object, 'FABAO_BAIMAI_EAT_STATUS') == 0 then
           Osi.ApplyStatus(Object, 'FABAO_BAIMAI_EAT_STATUS', -1, 1)
           _P("解锁：百脉锻宝诀·大成")
        end
    end
    
end

--吞食法宝
function GongFa.Tianxian.BaiMaiDuanBao.Eating(Object)

    if Osi.HasPassive(Object, 'FABAO_BAIMAI_S') == 0 then
        Osi.AddPassive(Object, 'FABAO_BAIMAI_S')
        _P("百脉锻宝诀·大成")
    end
    Utils.GongFa.BaiMai.CopyPassives(Object)
    Utils.GongFa.BaiMai.CopyStatus(Object)
    
end



-- 事件·功法状态监听
function GongFa.OnStatusApplied_after(Object, Status)

    if Status == 'SIGNAL_READD_PASSIVES' or  (string.find(Status,'CUITI_ZHOUTIAN_')) then
        GongFa.Tianxian.ZhouTianCuiTi.Check(Object)
        GongFa.Tianxian.BaiMaiDuanBao.Check(Object)
    elseif Status == 'SIGNAL_FABAO_BAIMAI_EATED' then
        Utils.GongFa.BaiMai.CopyPassives_2(Object)
    elseif Status == 'SIGNAL_FABAO_BAIMAI_EAT_1' then
        GongFa.Tianxian.BaiMaiDuanBao.Eating(Object)
    end

end


return GongFa
