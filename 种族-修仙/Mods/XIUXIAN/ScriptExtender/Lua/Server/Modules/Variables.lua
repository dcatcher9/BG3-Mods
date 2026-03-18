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

-- 灵根状态名（status turns 存储）
Variables.LINGGEN_STATUS = {
    ["木"] = "XIUXIAN_LG_MU",
    ["火"] = "XIUXIAN_LG_HUO",
    ["土"] = "XIUXIAN_LG_TU",
    ["金"] = "XIUXIAN_LG_JIN",
    ["水"] = "XIUXIAN_LG_SHUI"
}

-- 15条经脉（无向，排序键：index小的在前）
-- 10条脏器间 + 5条丹田经脉
Variables.MERIDIAN_PAIRS = {
    -- 相生序 (d=1/4)
    "木火", "火土", "土金", "金水", "水木",
    -- 相克序 (d=2/3)
    "木土", "土水", "水火", "火金", "金木",
    -- 丹田经脉（Phase 4 筑基后激活）
    -- "丹田木", "丹田火", "丹田土", "丹田金", "丹田水"
}

-- 开脉灵根门槛
Variables.MERIDIAN_OPEN_THRESHOLD = 50

-- Tier 名称
Variables.TIER_NAMES = {
    [-1] = "无",
    [0] = "凡品",
    [1] = "天品",
    [2] = "仙品",
    [3] = "圣品"
}

return Variables
