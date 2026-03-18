local DanTian = {}
local Variables = require("Server.Modules.Variables")
local Utils = require("Server.Modules.Utils")

local STATUS_DANTIAN = "XIUXIAN_DANTIAN"
local STATUS_SHIHAI = "XIUXIAN_SHIHAI"

-- 初始丹田/识海容量（炼气期）
local INITIAL_DANTIAN = 2
local INITIAL_SHIHAI = 1

-- 防止同帧重复初始化
local initGuard = {}

-- ============ 读写 ============

function DanTian.GetQiMax(character)
    return Osi.GetStatusTurns(character, STATUS_DANTIAN) or 0
end

function DanTian.GetShenshiMax(character)
    return Osi.GetStatusTurns(character, STATUS_SHIHAI) or 0
end

function DanTian.SetQiMax(character, value)
    if value <= 0 then
        Osi.RemoveStatus(character, STATUS_DANTIAN)
    else
        Osi.ApplyStatus(character, STATUS_DANTIAN, value * 6, 1, character)
    end
end

function DanTian.SetShenshiMax(character, value)
    if value <= 0 then
        Osi.RemoveStatus(character, STATUS_SHIHAI)
    else
        Osi.ApplyStatus(character, STATUS_SHIHAI, value * 6, 1, character)
    end
end

function DanTian.AddQiMax(character, amount)
    DanTian.SetQiMax(character, DanTian.GetQiMax(character) + amount)
end

function DanTian.AddShenshiMax(character, amount)
    DanTian.SetShenshiMax(character, DanTian.GetShenshiMax(character) + amount)
end

-- ============ 资源同步 ============

-- 将实际 Qi/ShenShi 资源上限同步到丹田/识海值
function DanTian.SyncResources(character)
    local qiMax = DanTian.GetQiMax(character)
    local ssMax = DanTian.GetShenshiMax(character)

    -- 动态创建同步状态（ActionResource boost）
    local syncName = "XIUXIAN_RSYNC_" .. qiMax .. "_" .. ssMax
    if not Ext.Stats.Get(syncName) then
        local stat = Ext.Stats.Create(syncName, "StatusData", "XIUXIAN_RESOURCE_SYNC")
        local boosts = {}
        if qiMax > 0 then
            table.insert(boosts, "ActionResource(QiPoint," .. qiMax .. ",0)")
        end
        if ssMax > 0 then
            table.insert(boosts, "ActionResource(ShenshiPoint," .. ssMax .. ",0)")
        end
        stat.Boosts = table.concat(boosts, ";")
        stat.StackId = "XIUXIAN_RESOURCE_SYNC"
        Utils.SafeStatSync(stat)
    end
    Osi.ApplyStatus(character, syncName, -1, 1, character)
end

-- ============ 初始化 ============

-- 为角色设置初始丹田/识海（幂等）
function DanTian.InitCharacter(character)
    local key = tostring(character)
    if initGuard[key] then return end

    -- 已有丹田则只同步资源
    if DanTian.GetQiMax(character) > 0 then
        DanTian.SyncResources(character)
        return
    end

    initGuard[key] = true

    -- 设置初始值
    DanTian.SetQiMax(character, INITIAL_DANTIAN)
    DanTian.SetShenshiMax(character, INITIAL_SHIHAI)

    -- 同步资源
    DanTian.SyncResources(character)

    _P("[修仙] 丹田/识海初始化: " .. key .. " 丹田=" .. INITIAL_DANTIAN .. " 识海=" .. INITIAL_SHIHAI)
end

-- 打印信息（用于 debug）
function DanTian.PrintInfo(character)
    local qi = DanTian.GetQiMax(character)
    local ss = DanTian.GetShenshiMax(character)
    local curQi = Utils.GetActionResource(tostring(character), Variables.ResourceUUID.QiPoint)
    local curSs = Utils.GetActionResource(tostring(character), Variables.ResourceUUID.ShenshiPoint)
    _P("  丹田=" .. qi .. " (气 " .. curQi .. "/" .. qi .. ")  识海=" .. ss .. " (神识 " .. curSs .. "/" .. ss .. ")")
end

function DanTian.Init()
    _P("[修仙] DanTian module loaded.")
end

return DanTian
