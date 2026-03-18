local LingGen = {}
local Variables = require("Server.Modules.Variables")
local Utils = require("Server.Modules.Utils")

-- 防止同帧重复觉醒（Osi.GetStatusTurns 可能在 ApplyStatus 后同帧内还读不到）
local awakeGuard = {}

-- 获取单个元素的灵根值
function LingGen.Get(character, element)
    local status = Variables.LINGGEN_STATUS[element]
    if not status then return 0 end
    return Osi.GetStatusTurns(character, status) or 0
end

-- 获取所有5个灵根值
function LingGen.GetAll(character)
    local result = {}
    for _, elem in ipairs(Variables.ELEM_NAMES) do
        result[elem] = LingGen.Get(character, elem)
    end
    return result
end

-- 获取灵根总值
function LingGen.GetTotal(character)
    local total = 0
    for _, elem in ipairs(Variables.ELEM_NAMES) do
        total = total + LingGen.Get(character, elem)
    end
    return total
end

-- 获取单个元素的 Tier
function LingGen.GetTier(character, element)
    return Utils.GetTier(LingGen.Get(character, element))
end

-- 设置灵根值（覆盖）
function LingGen.Set(character, element, value)
    local status = Variables.LINGGEN_STATUS[element]
    if not status then return end
    if value <= 0 then
        Osi.RemoveStatus(character, status)
    else
        Osi.ApplyStatus(character, status, value * 6, 1, character)
    end
end

-- 增加灵根值
function LingGen.Add(character, element, amount)
    local current = LingGen.Get(character, element)
    LingGen.Set(character, element, current + amount)
end

-- 觉醒灵根：随机分配初始值
function LingGen.Awake(character)
    -- 已有灵根则跳过（status turns 检查 + 本地防重复）
    local key = tostring(character)
    if awakeGuard[key] then return end
    if LingGen.GetTotal(character) > 0 then return end
    awakeGuard[key] = true

    -- 决定总点数和分布质量
    local roll = math.random(1, 100)
    local total, spread
    if roll <= 1 then         -- 1%  先天道体
        total = 200
        spread = 5  -- 分散到多个元素
    elseif roll <= 5 then     -- 4%  大帝之资
        total = 100
        spread = 4
    elseif roll <= 15 then    -- 10% 先天慧根
        total = 50
        spread = 3
    elseif roll <= 40 then    -- 25% 平平无奇
        total = 25
        spread = 2
    else                      -- 60% 灵根微弱
        total = 10
        spread = 1
    end

    -- 随机分配到5个元素（批量分配，避免逐点循环）
    local values = {0, 0, 0, 0, 0}
    -- 选择 spread 个活跃元素
    local active = {1, 2, 3, 4, 5}
    for i = 5, 2, -1 do
        local j = math.random(1, i)
        active[i], active[j] = active[j], active[i]
    end
    local numActive = math.min(spread, 5)
    -- 用随机切分法分配总点数到活跃元素
    local cuts = {}
    for i = 1, numActive - 1 do
        cuts[i] = math.random(0, total)
    end
    cuts[numActive] = total
    table.sort(cuts)
    local prev = 0
    for i = 1, numActive do
        values[active[i]] = cuts[i] - prev
        prev = cuts[i]
    end

    -- 写入
    for i, elem in ipairs(Variables.ELEM_NAMES) do
        if values[i] > 0 then
            LingGen.Set(character, elem, values[i])
        end
    end

    _P("[修仙] 灵根觉醒: " .. tostring(character) .. " 总=" .. total)
end

-- 打印灵根信息（用于 debug）
function LingGen.PrintInfo(character)
    local all = LingGen.GetAll(character)
    local total = 0
    local parts = {}
    for _, elem in ipairs(Variables.ELEM_NAMES) do
        local v = all[elem]
        local t = Utils.GetTier(v)
        local tname = Variables.TIER_NAMES[t] or "?"
        total = total + v
        if v > 0 then
            table.insert(parts, Variables.ELEM_ORGAN[elem] .. "(" .. elem .. "): " .. v .. " [" .. tname .. "]")
        end
    end
    if #parts == 0 then
        _P("  灵根: 未觉醒")
    else
        _P("  灵根 (总=" .. total .. "): " .. table.concat(parts, "  "))
    end
end

function LingGen.Init()
    _P("[修仙] LingGen module loaded.")
end

return LingGen
