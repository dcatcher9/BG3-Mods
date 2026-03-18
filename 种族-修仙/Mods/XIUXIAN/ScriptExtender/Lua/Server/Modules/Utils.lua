local Utils = {}
local Variables = require("Server.Modules.Variables")

-- 计算五行距离 (from_elem, to_elem) → 0-4
function Utils.EdgeDistance(from, to)
    if from == "丹田" or to == "丹田" then
        return nil  -- 丹田特殊处理（Phase 4）
    end
    local fi = Variables.ELEM_INDEX[from]
    local ti = Variables.ELEM_INDEX[to]
    if fi == nil or ti == nil then return nil end
    return (ti - fi + 5) % 5
end

-- 获取边效果名
function Utils.GetEdgeEffectName(from, to)
    return Variables.EDGE_EFFECT_NAMES[from .. to]
end

-- 计算灵根 Tier
function Utils.GetTier(linggen_value)
    for _, entry in ipairs(Variables.TIER_THRESHOLDS) do
        if linggen_value >= entry.min then
            return entry.tier
        end
    end
    return -1  -- 未达凡品
end

-- 安全添加被动
function Utils.AddPassive_Safe(entity, passiveId)
    if Osi.HasPassive(entity, passiveId) == 0 then
        Osi.AddPassive(entity, passiveId)
    end
end

-- 安全同步 stat
function Utils.SafeStatSync(stat)
    local success, err = pcall(function()
        if stat and stat.Sync then
            stat:Sync()
        end
    end)
    if not success then
        Ext.Utils.PrintError(("[修仙] Sync失败: %s"):format(tostring(err)))
        return false
    end
    return true
end

-- 表内查找
function Utils.contains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then return true end
    end
    return false
end

-- 获取资源当前值
function Utils.GetActionResource(object, resourceId)
    local entity = Ext.Entity.Get(object)
    if not entity then return 0 end
    if entity.ActionResources and entity.ActionResources.Resources[resourceId] then
        return math.floor(entity.ActionResources.Resources[resourceId][1].Amount)
    end
    return 0
end

-- 获取资源最大值
function Utils.GetActionResourceMax(object, resourceId)
    local entity = Ext.Entity.Get(object)
    if not entity then return 0 end
    if entity.ActionResources and entity.ActionResources.Resources[resourceId] then
        return math.floor(entity.ActionResources.Resources[resourceId][1].MaxAmount)
    end
    return 0
end

-- 为角色授予修仙被动+资源，幂等（所有角色，含敌人）
function Utils.GrantXiuXian(object)
    if Osi.HasPassive(object, 'XIUXIAN_Racial_Passive') == 1 then return end
    Osi.AddPassive(object, 'XIUXIAN_Racial_Passive')
    Osi.AddBoosts(object, 'ActionResource(QiPoint,2,0);ActionResource(ShenshiPoint,1,0)', '', '')
end

return Utils
