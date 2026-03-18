local Utils = {}
local Variables = require("Server.Modules.Variables")

-- 系统模块引用（由 Main.lua 初始化后注入）
Utils._Systems = nil

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

-- 检查是否为真实角色（排除dummy/helper/invisible等游戏内部实体）
function Utils.IsRealCharacter(object)
    -- 必须有 Health 组件（活物）
    local entity = Ext.Entity.Get(object)
    if not entity then return false end
    if not entity.Health then return false end
    -- 排除模板名包含 Dummy/Helper/Invisible 的实体
    if entity.ServerCharacter and entity.ServerCharacter.Template then
        local name = entity.ServerCharacter.Template.Name or ""
        if name:find("Dummy") or name:find("Helper") or name:find("Invisible") or name:find("Intangible") then
            return false
        end
    end
    return true
end

-- 为角色授予修仙被动+灵根+丹田，幂等（所有真实角色，含敌人）
function Utils.GrantXiuXian(object)
    if not Utils.IsRealCharacter(object) then return end

    if Osi.HasPassive(object, 'XIUXIAN_Racial_Passive') ~= 1 then
        Osi.AddPassive(object, 'XIUXIAN_Racial_Passive')
    end

    -- 子系统初始化（外置于 idempotency guard，各自内部幂等）
    if Utils._Systems then
        if Utils._Systems.LingGen then Utils._Systems.LingGen.Awake(object) end
        if Utils._Systems.DanTian then Utils._Systems.DanTian.InitCharacter(object) end
    end
end

return Utils
