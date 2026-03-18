local JingMai = {}
local Variables = require("Server.Modules.Variables")
local Utils = require("Server.Modules.Utils")

-- ============ 键名工具 ============

-- 经脉键：按 index 排序保证唯一 (木火 not 火木)
local function MeridianKey(elemA, elemB)
    local iA = Variables.ELEM_INDEX[elemA]
    local iB = Variables.ELEM_INDEX[elemB]
    if iA == nil or iB == nil then return nil end
    if iA <= iB then return elemA .. elemB
    else return elemB .. elemA end
end

-- PersistentVars 存储键
local function PVKey(character)
    return 'JINGMAI_' .. tostring(character)
end

-- ============ 读写 ============

-- 获取角色的经脉表（创建如不存在）
function JingMai.GetTable(character)
    local key = PVKey(character)
    if not PersistentVars[key] then
        -- 初始化：所有经脉关闭
        local t = {}
        for _, pair in ipairs(Variables.MERIDIAN_PAIRS) do
            t[pair] = false
        end
        PersistentVars[key] = t
    end
    return PersistentVars[key]
end

-- 查询单条经脉是否开通
function JingMai.IsOpen(character, elemA, elemB)
    local mkey = MeridianKey(elemA, elemB)
    if not mkey then return false end
    local t = JingMai.GetTable(character)
    return t[mkey] == true
end

-- 开通经脉
function JingMai.Open(character, elemA, elemB)
    local mkey = MeridianKey(elemA, elemB)
    if not mkey then return false end
    local t = JingMai.GetTable(character)
    if t[mkey] then return false end  -- 已开
    t[mkey] = true
    _P("[修仙] 开脉: " .. elemA .. "─" .. elemB .. " (" .. tostring(character) .. ")")
    return true
end

-- 关闭经脉
function JingMai.Close(character, elemA, elemB)
    local mkey = MeridianKey(elemA, elemB)
    if not mkey then return false end
    local t = JingMai.GetTable(character)
    t[mkey] = false
    return true
end

-- ============ 查询 ============

-- 检查是否满足开脉条件
function JingMai.CanOpen(character, elemA, elemB)
    -- 已开通则不需要
    if JingMai.IsOpen(character, elemA, elemB) then return false end
    -- 两端灵根均 ≥ 门槛
    local LingGen = Utils._Systems and Utils._Systems.LingGen
    if not LingGen then return false end
    local vA = LingGen.Get(character, elemA)
    local vB = LingGen.Get(character, elemB)
    return vA >= Variables.MERIDIAN_OPEN_THRESHOLD and vB >= Variables.MERIDIAN_OPEN_THRESHOLD
end

-- 获取所有已开通的有向边
function JingMai.GetOpenEdges(character)
    local t = JingMai.GetTable(character)
    local edges = {}
    for pair, open in pairs(t) do
        if open then
            -- 每条无向经脉产生两条有向边
            local elemA = pair:sub(1, 3)  -- UTF-8 中文字符 = 3 bytes
            local elemB = pair:sub(4, 6)
            local dAB = Utils.EdgeDistance(elemA, elemB)
            local dBA = Utils.EdgeDistance(elemB, elemA)
            table.insert(edges, {
                from = elemA, to = elemB,
                distance = dAB,
                effectName = Variables.EDGE_EFFECT_NAMES[elemA .. elemB]
            })
            table.insert(edges, {
                from = elemB, to = elemA,
                distance = dBA,
                effectName = Variables.EDGE_EFFECT_NAMES[elemB .. elemA]
            })
        end
    end
    return edges
end

-- 获取从某节点可达的元素列表
function JingMai.GetReachableFrom(character, elem)
    local t = JingMai.GetTable(character)
    local reachable = {}
    for pair, open in pairs(t) do
        if open then
            local elemA = pair:sub(1, 3)
            local elemB = pair:sub(4, 6)
            if elemA == elem then
                table.insert(reachable, elemB)
            elseif elemB == elem then
                table.insert(reachable, elemA)
            end
        end
    end
    return reachable
end

-- 统计已开通经脉数
function JingMai.CountOpen(character)
    local t = JingMai.GetTable(character)
    local count = 0
    for _, open in pairs(t) do
        if open then count = count + 1 end
    end
    return count
end

-- ============ Debug ============

function JingMai.PrintInfo(character)
    local t = JingMai.GetTable(character)
    local openList = {}
    local closedList = {}
    for _, pair in ipairs(Variables.MERIDIAN_PAIRS) do
        local elemA = pair:sub(1, 3)
        local elemB = pair:sub(4, 6)
        local d = Utils.EdgeDistance(elemA, elemB)
        local rname = Variables.REACTION_NAMES[d] or "?"
        local label = elemA .. "─" .. elemB .. "(" .. rname .. ")"
        if t[pair] then
            table.insert(openList, label)
        else
            table.insert(closedList, label)
        end
    end
    _P("  经脉 [" .. #openList .. "/" .. #Variables.MERIDIAN_PAIRS .. " 开]")
    if #openList > 0 then
        _P("    开: " .. table.concat(openList, "  "))
    end
    if #closedList > 0 then
        _P("    闭: " .. table.concat(closedList, "  "))
    end
end

function JingMai.Init()
    _P("[修仙] JingMai module loaded.")
end

return JingMai
