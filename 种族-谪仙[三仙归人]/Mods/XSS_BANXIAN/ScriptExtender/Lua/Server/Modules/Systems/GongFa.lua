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

    -- 注册短休事件：周天淬体诀小周天/大周天恢复
    Ext.Osiris.RegisterListener("ShortRested", 1, "after", GongFa.OnShortRested_after)

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

    if CuiTi_ZhouTian_Short == true and CuiTi_ZhouTian_Long == false and Osi.HasPassive(Object, 'CuiTi_ZhouTian_ShortBreak') == 0 then   --检查是否已激活小周天，防止重复获得被动
        Osi.AddPassive(Object, 'CuiTi_ZhouTian_ShortBreak')
    elseif (CuiTi_ZhouTian_Short == false or CuiTi_ZhouTian_Long == true) and Osi.HasPassive(Object, 'CuiTi_ZhouTian_ShortBreak') == 1 then
        Osi.RemovePassive(Object, 'CuiTi_ZhouTian_ShortBreak')
    end

    if CuiTi_ZhouTian_Long == true  and Osi.HasPassive(Object, 'CuiTi_ZhouTian_LongBreak') == 0 then
        Osi.AddPassive(Object, 'CuiTi_ZhouTian_LongBreak')
    elseif CuiTi_ZhouTian_Long == false  and Osi.HasPassive(Object, 'CuiTi_ZhouTian_LongBreak') == 1 then
        Osi.RemovePassive(Object, 'CuiTi_ZhouTian_LongBreak')
    end
    
end


--周天淬体诀：恢复指定补给类型的所有资源
local function ZhouTianRestoreResources(Object, replenishType)
    local entity = Ext.Entity.Get(Object)
    for _, ResourceList in pairs(entity.ActionResources.Resources) do
        for _, Resource in ipairs(ResourceList) do
            if Resource.ReplenishType == replenishType then
                Resource.Amount = Resource.MaxAmount
            end
        end
    end
    entity:Replicate("ActionResources")
end

--周天淬体诀:SHORTREST
function GongFa.Tianxian.ZhouTianCuiTi.ShortRest(Object)
    ZhouTianRestoreResources(Object, "ShortRest")
end

--周天淬体诀:LONGREST
function GongFa.Tianxian.ZhouTianCuiTi.LongRest(Object)
    ZhouTianRestoreResources(Object, "Rest")
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
    elseif FABAO_BAIMAI_A1 == false  and Osi.HasPassive(Object, 'FABAO_BAIMAI_A1') == 1 then
        Osi.RemovePassive(Object, 'FABAO_BAIMAI_A1')
    end

    if FABAO_BAIMAI_A2 == true and Osi.HasPassive(Object, 'FABAO_BAIMAI_A2') == 0 then
        Osi.AddPassive(Object, 'FABAO_BAIMAI_A2')
    elseif FABAO_BAIMAI_A2 == false  and Osi.HasPassive(Object, 'FABAO_BAIMAI_A2') == 1 then
        Osi.RemovePassive(Object, 'FABAO_BAIMAI_A2')
    end

    if FABAO_BAIMAI_S == true and Osi.HasPassive(Object, 'FABAO_BAIMAI_S') == 0 then
        if Osi.HasActiveStatus(Object, 'FABAO_BAIMAI_EAT_STATUS') == 0 then
           Osi.ApplyStatus(Object, 'FABAO_BAIMAI_EAT_STATUS', -1, 1)
        end
    end
    
end

--吞食法宝
function GongFa.Tianxian.BaiMaiDuanBao.Eating(Object)

    if Osi.HasPassive(Object, 'FABAO_BAIMAI_S') == 0 then
        Osi.AddPassive(Object, 'FABAO_BAIMAI_S')
    end
    Utils.GongFa.BaiMai.CopyPassives(Object)
    Utils.GongFa.BaiMai.CopyStatus(Object)
    
end



-- 事件·短休
function GongFa.OnShortRested_after(Object)
    if Osi.HasPassive(Object, 'CuiTi_ZhouTian_ShortBreak') == 1 or Osi.HasPassive(Object, 'CuiTi_ZhouTian_LongBreak') == 1 then
        GongFa.Tianxian.ZhouTianCuiTi.ShortRest(Object)
    end
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
