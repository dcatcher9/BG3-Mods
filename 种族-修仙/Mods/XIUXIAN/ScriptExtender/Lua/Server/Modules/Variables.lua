local Variables = {}

Variables.DEBUG_MODE = false

-- 五行元素索引
Variables.ELEM_INDEX = {
    ["木"] = 0,
    ["火"] = 1,
    ["土"] = 2,
    ["金"] = 3,
    ["水"] = 4
}

Variables.ELEM_NAMES = { "木", "火", "土", "金", "水" }

-- 脏器 → 元素映射
Variables.ORGAN_NAMES = { "肝", "心", "脾", "肺", "肾" }
Variables.ORGAN_ELEM = {
    ["肝"] = "木",
    ["心"] = "火",
    ["脾"] = "土",
    ["肺"] = "金",
    ["肾"] = "水"
}
Variables.ELEM_ORGAN = {
    ["木"] = "肝",
    ["火"] = "心",
    ["土"] = "脾",
    ["金"] = "肺",
    ["水"] = "肾"
}

-- 灵根 Tier 门槛
Variables.TIER_THRESHOLDS = {
    { tier = 3, min = 1000 },  -- T3 圣品
    { tier = 2, min = 300 },   -- T2 仙品
    { tier = 1, min = 100 },   -- T1 天品
    { tier = 0, min = 25 }     -- T0 凡品
}

-- distance → 反应类型
Variables.REACTION_NAMES = {
    [0] = "共鸣",
    [1] = "生",
    [2] = "克",
    [3] = "侮",
    [4] = "泄"
}

-- 20条有向边效果名（from_elem .. to_elem → 效果名）
Variables.EDGE_EFFECT_NAMES = {
    -- 生 (d=1)
    ["木火"] = "燃", ["火土"] = "锻", ["土金"] = "铸", ["金水"] = "雷", ["水木"] = "滋",
    -- 克 (d=2)
    ["木土"] = "侵", ["火金"] = "熔", ["土水"] = "困", ["金木"] = "斩", ["水火"] = "灭",
    -- 侮 (d=3)
    ["木金"] = "刺", ["火水"] = "蒸", ["土木"] = "震", ["金火"] = "淬", ["水土"] = "蚀",
    -- 泄 (d=4)
    ["木水"] = "泄", ["火木"] = "灰", ["土火"] = "埋", ["金土"] = "削", ["水金"] = "锈"
}

-- 资源 UUID
Variables.ResourceUUID = {
    QiPoint      = '99465841-c763-4f1f-b025-02af228116b0',
    ShenshiPoint = '469d454d-8778-4412-a8b4-49c6becbe18e',
}

-- 种族标签
Variables.TAG_XIUXIAN = 'e600bc79-6e7d-41cb-b90f-dc6f8fef63ee'

return Variables
