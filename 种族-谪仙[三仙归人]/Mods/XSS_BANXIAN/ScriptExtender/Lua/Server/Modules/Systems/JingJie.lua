local JingJie = {}
local Utils = require("Server.Modules.Utils")

-- 五行相克循环：火→金→木→土→水→火
-- BG3 DamageType mapping: Fire, Lightning(金), Poison(木), Thunder(土), Cold(水)
local WUXING_CYCLE = {
    {name = '火克金', damage = 'Fire'},
    {name = '金克木', damage = 'Lightning'},
    {name = '木克土', damage = 'Poison'},
    {name = '土克水', damage = 'Thunder'},
    {name = '水克火', damage = 'Cold'},
}
-- 灵根元素对应五行阶段（用于灵根亲和加成）
local WUXING_LINGGEN = {
    [1] = 'BANXIAN_LG_H', -- 火
    [2] = 'BANXIAN_LG_J', -- 金
    [3] = 'BANXIAN_LG_M', -- 木
    [4] = 'BANXIAN_LG_T', -- 土
    [5] = 'BANXIAN_LG_S', -- 水
}

-- 大道共鸣映射：大道passive → 领域共鸣状态
local DAO_RESONANCE = {
    ['BanXian_DH_Tian']     = 'BANXIAN_JJ8_LINGYU_DAO_TIAN',
    ['BanXian_DH_XiuLuo']   = 'BANXIAN_JJ8_LINGYU_DAO_XIULUO',
    ['BanXian_DH_DiYu']     = 'BANXIAN_JJ8_LINGYU_DAO_DIYU',
    ['BanXian_DH_Jian']     = 'BANXIAN_JJ8_LINGYU_DAO_JIAN',
    ['BanXian_DH_Yi']       = 'BANXIAN_JJ8_LINGYU_DAO_YI',
    ['BanXian_DH_EGui']     = 'BANXIAN_JJ8_LINGYU_DAO_EGUI',
    ['BanXian_DH_Li']       = 'BANXIAN_JJ8_LINGYU_DAO_LI',
    ['BanXian_DH_HeHuan']   = 'BANXIAN_JJ8_LINGYU_DAO_HEHUAN',
    ['BanXian_DH_RenJian']  = 'BANXIAN_JJ8_LINGYU_DAO_RENJIAN',
    ['BanXian_DH_ChuSheng'] = 'BANXIAN_JJ8_LINGYU_DAO_CHUSHENG',
}

-- 大道后缀（用于查找最高道行大道）
local DADAO_SUFFIX = {
    ['BanXian_DH_Tian']='TIAN', ['BanXian_DH_XiuLuo']='XIULUO',
    ['BanXian_DH_RenJian']='RENJIAN', ['BanXian_DH_ChuSheng']='CHUSHENG',
    ['BanXian_DH_EGui']='EGUI', ['BanXian_DH_DiYu']='DIYU',
    ['BanXian_DH_Jian']='JIAN', ['BanXian_DH_Li']='LI',
    ['BanXian_DH_HeHuan']='HEHUAN', ['BanXian_DH_Yi']='YI',
}

--================================
-- Tier 5 · 化神 · 因果律链式伤害
--================================
-- 因果链：攻击命中时，对目标6m内随机敌人造成同类型攻击
-- 武器攻击（物理伤害）→ ExecuteWeaponAttack（真实攻击：AC/暴击/on-hit被动）
-- 法术伤害（非物理）→ 读取原始法术的豁免属性，动态创建豁免+伤害状态
-- 首次跳跃必中，之后概率递减（100→50→25→12...），最多5层

local yinGuoChaining = {} -- 递归防护：attacker UUID → true
local yinGuoLastSpell = {} -- 记录最后施放的法术：attacker GUID → spell name
local PHYSICAL_DAMAGE = {Slashing=true, Piercing=true, Bludgeoning=true}

-- ===== 跨境界追踪变量 =====
-- 劫气层数持久化：存入PersistentVars以防save/reload丢失
local function getJieqi(guid) return PersistentVars['JIEQI_COUNT_'..tostring(guid)] or 0 end
local function setJieqi(guid, val) PersistentVars['JIEQI_COUNT_'..tostring(guid)] = val end

local function YinGuoChain_Recurse(origin, attacker, chance, hitSet, depth, isWeapon, spellName)
    if depth <= 0 then return end
    local RADIUS = 6
    local candidates = {}
    for _, entity in pairs(Ext.Entity.GetAllEntitiesWithComponent("Health")) do
        if entity.Uuid then
            local guid = tostring(entity.Uuid.EntityUuid)
            if not hitSet[guid] and Osi.IsDead(guid) == 0 and Osi.IsEnemy(guid, attacker) == 1 then
                local dist = Osi.GetDistanceTo(origin, guid)
                if dist and dist <= RADIUS then
                    table.insert(candidates, guid)
                end
            end
        end
    end
    if #candidates == 0 then return end

    local picked = candidates[math.random(1, #candidates)]
    hitSet[picked] = true

    if isWeapon then
        -- 武器攻击：完整武器攻击（AC判定/暴击/on-hit被动）
        Osi.ApplyStatus(picked, 'BANXIAN_JJ5_YINGUO_CHAIN_HIT', 1, 1, attacker)
    else
        -- 法术攻击：引擎完整施放原始法术（骰子/豁免/攻击骰/附加效果全部保留）
        Osi.UseSpell(attacker, spellName, picked)
    end

    -- 概率递减连锁
    local nextChance = math.floor(chance / 2)
    if nextChance >= 10 and math.random(1, 100) <= nextChance then
        YinGuoChain_Recurse(picked, attacker, nextChance, hitSet, depth - 1, isWeapon, spellName)
    end
end

local function YinGuoChain(target, attacker, damageType, damageAmount)
    if not target or not attacker then return end
    -- 防止链式攻击的AttackedBy事件重新触发因果链
    if yinGuoChaining[tostring(attacker)] then return end

    yinGuoChaining[tostring(attacker)] = true
    local isWeapon = PHYSICAL_DAMAGE[damageType] or false
    local spellName = not isWeapon and yinGuoLastSpell[tostring(attacker)] or nil

    -- 没有记录到法术名（如被动伤害触发），回退到武器攻击
    if not isWeapon and not spellName then
        isWeapon = true
    end

    YinGuoChain_Recurse(target, attacker, 100, {[tostring(target)] = true}, 5, isWeapon, spellName)
    yinGuoChaining[tostring(attacker)] = nil
end

--================================
-- Tier 5 · 化神 · 五行律标记系统
--================================
-- 五行律命中处理：循环施加五行印（火→金→木→土→水）
-- 当战场上集齐全部5种元素印记时，触发五行崩：
-- 所有被标记的敌人承受 (等级)d6 × 身上印记数 的元素伤害 + 震慑1回合
-- 然后消耗所有印记

local WUXING_MARKS = {
    'BANXIAN_JJ5_WUXING_MARK_1', -- 火印
    'BANXIAN_JJ5_WUXING_MARK_2', -- 金印
    'BANXIAN_JJ5_WUXING_MARK_3', -- 木印
    'BANXIAN_JJ5_WUXING_MARK_4', -- 土印
    'BANXIAN_JJ5_WUXING_MARK_5', -- 水印
}

-- 扫描战场：收集所有带五行印的敌人，返回 {已出现的元素set, 被标记的敌人列表}
local function WuXingScanMarks(attacker)
    local elementsFound = {}
    local markedEnemies = {} -- {guid, markCount, markElements[]}

    for _, entity in pairs(Ext.Entity.GetAllEntitiesWithComponent("Health")) do
        if entity.Uuid then
            local guid = tostring(entity.Uuid.EntityUuid)
            if Osi.IsDead(guid) == 0 and Osi.IsEnemy(guid, attacker) == 1 then
                local marks = {}
                for i, markStatus in ipairs(WUXING_MARKS) do
                    if Osi.HasActiveStatus(guid, markStatus) == 1 then
                        elementsFound[i] = true
                        table.insert(marks, i)
                    end
                end
                if #marks > 0 then
                    table.insert(markedEnemies, {guid = guid, marks = marks})
                end
            end
        end
    end

    -- 检查是否集齐5种元素
    local allFound = true
    for i = 1, 5 do
        if not elementsFound[i] then allFound = false; break end
    end

    return allFound, markedEnemies
end

-- 凸包算法（Graham Scan，2D XZ平面）：返回凸包顶点列表（逆时针）
local function ConvexHull2D(points)
    if #points <= 2 then return points end

    -- 按X排序，X相同按Z排序
    table.sort(points, function(a, b)
        if a.x == b.x then return a.z < b.z end
        return a.x < b.x
    end)

    -- 叉积：>0 左转, <0 右转, =0 共线
    local function cross(O, A, B)
        return (A.x - O.x) * (B.z - O.z) - (A.z - O.z) * (B.x - O.x)
    end

    local lower = {}
    for _, p in ipairs(points) do
        while #lower >= 2 and cross(lower[#lower-1], lower[#lower], p) <= 0 do
            table.remove(lower)
        end
        table.insert(lower, p)
    end

    local upper = {}
    for i = #points, 1, -1 do
        local p = points[i]
        while #upper >= 2 and cross(upper[#upper-1], upper[#upper], p) <= 0 do
            table.remove(upper)
        end
        table.insert(upper, p)
    end

    -- 首尾重复，去掉
    table.remove(lower)
    table.remove(upper)
    for _, p in ipairs(upper) do table.insert(lower, p) end
    return lower
end

-- 判断点是否在凸包内（XZ平面）
local function PointInConvexHull(hull, px, pz)
    local n = #hull
    if n < 3 then return false end
    for i = 1, n do
        local j = (i % n) + 1
        -- 叉积：边 hull[i]→hull[j] 对点 p
        local cross = (hull[j].x - hull[i].x) * (pz - hull[i].z) - (hull[j].z - hull[i].z) * (px - hull[i].x)
        if cross < 0 then return false end -- 点在边的右侧（凸包外）
    end
    return true
end

-- 五行崩：对所有被标记的敌人 + 凸包区域内未标记敌人造成元素爆发伤害 + 震慑
local function WuXingCollapse(attacker, markedEnemies)
    local level = Osi.GetLevel(attacker) or 1
    local dicePerMark = math.max(1, level)

    -- 收集标记目标的XZ坐标，构建凸包
    local markedGuids = {}
    local hullPoints = {}
    for _, enemy in ipairs(markedEnemies) do
        markedGuids[enemy.guid] = true
        local x, y, z = Osi.GetPosition(enemy.guid)
        if x then
            table.insert(hullPoints, {x = x, z = z})
        end
    end
    local hull = ConvexHull2D(hullPoints)

    -- 查找凸包内的未标记敌人
    local bystanders = {}
    if #hull >= 3 then
        for _, entity in pairs(Ext.Entity.GetAllEntitiesWithComponent("Health")) do
            if entity.Uuid then
                local guid = tostring(entity.Uuid.EntityUuid)
                if not markedGuids[guid] and Osi.IsDead(guid) == 0 and Osi.IsEnemy(guid, attacker) == 1 then
                    local x, y, z = Osi.GetPosition(guid)
                    if x and PointInConvexHull(hull, x, z) then
                        table.insert(bystanders, guid)
                    end
                end
            end
        end
    end

    -- 对标记目标造成元素爆发伤害（每个印记对应元素各 level×d6）
    for _, enemy in ipairs(markedEnemies) do
        for _, markIdx in ipairs(enemy.marks) do
            local dmgType = WUXING_CYCLE[markIdx].damage
            local dmgStr = dicePerMark .. 'd6'

            local statusName = 'BANXIAN_JJ5_WUXING_BURST_'..markIdx..'_'..dicePerMark
            if Ext.Stats.Get(statusName) == nil then
                local Stats = Ext.Stats.Create(statusName, 'StatusData', 'BANXIAN_JJ5_WUXING_HIT')
                Stats.OnApplyFunctors = 'DealDamage('..dmgStr..','..dmgType..',Magical)'
                Stats:Sync()
            end
            Osi.ApplyStatus(enemy.guid, statusName, 1, 1, attacker)
        end

        Osi.ApplyStatus(enemy.guid, 'STUNNED', 1, 1, attacker)

        -- 消耗所有印记
        for _, markIdx in ipairs(enemy.marks) do
            Osi.RemoveStatus(enemy.guid, WUXING_MARKS[markIdx])
        end
    end

    -- 对凸包内未标记敌人造成全五行爆发伤害 + 震慑
    for _, guid in ipairs(bystanders) do
        for i = 1, 5 do
            local dmgType = WUXING_CYCLE[i].damage
            local dmgStr = dicePerMark .. 'd6'

            local statusName = 'BANXIAN_JJ5_WUXING_BURST_'..i..'_'..dicePerMark
            if Ext.Stats.Get(statusName) == nil then
                local Stats = Ext.Stats.Create(statusName, 'StatusData', 'BANXIAN_JJ5_WUXING_HIT')
                Stats.OnApplyFunctors = 'DealDamage('..dmgStr..','..dmgType..',Magical)'
                Stats:Sync()
            end
            Osi.ApplyStatus(guid, statusName, 1, 1, attacker)
        end

        Osi.ApplyStatus(guid, 'STUNNED', 1, 1, attacker)
    end

    -- 重置五行阶段
    PersistentVars['WUXING_STAGE_'..attacker] = 0
end

-- 五行律命中：施加印记，检查五行崩
local function WuXingOnHit(attacker, target)
    if not attacker or not target then return end

    -- 获取当前五行阶段（1-5循环）
    local stage = PersistentVars['WUXING_STAGE_'..attacker] or 0
    stage = stage + 1
    if stage > 5 then stage = 1 end
    PersistentVars['WUXING_STAGE_'..attacker] = stage

    -- 施加对应元素印记（持续到被消耗）
    Osi.ApplyStatus(target, WUXING_MARKS[stage], -1, 1, attacker)

    -- 灵根亲和加成：如果有对应灵根，额外造成一次元素伤害
    local linggenStatus = WUXING_LINGGEN[stage]
    if linggenStatus and Osi.HasActiveStatus(attacker, linggenStatus) == 1 then
        local dmgType = WUXING_CYCLE[stage].damage
        local level = Osi.GetLevel(attacker) or 1
        local dice = math.max(1, math.floor(level / 2))
        local statusName = 'BANXIAN_JJ5_WUXING_AFFINITY_'..stage..'_'..dice
        if Ext.Stats.Get(statusName) == nil then
            local Stats = Ext.Stats.Create(statusName, 'StatusData', 'BANXIAN_JJ5_WUXING_HIT')
            Stats.OnApplyFunctors = 'DealDamage('..dice..'d6,'..dmgType..',Magical)'
            Stats:Sync()
        end
        Osi.ApplyStatus(target, statusName, 1, 1, attacker)
    end

    -- 检查五行崩条件
    local allFound, markedEnemies = WuXingScanMarks(attacker)
    if allFound then
        WuXingCollapse(attacker, markedEnemies)
    end
end

--================================
-- Tier 6 · 炼虚 · 虚影分身系统
--================================
-- 召唤虚影分身（完整实现：复制被动、设定属性、跟随模式）
local function SummonShadowClone(Object)
    if not Object then return end
    if PersistentVars['XUYING_CLONE_'..Object] then
        -- 已有虚影，不重复召唤
        return
    end

    -- 获取本体位置
    local x, y, z = Osi.GetPosition(Object)
    if not x then return end

    -- 获取模板并创建虚影实体
    local templateUUID = Osi.GetTemplate(Object)
    if not templateUUID then
        _P('[境界·炼虚] 无法获取角色模板')
        return
    end

    local clone = Osi.CreateAt(templateUUID, x + 1.5, y, z, 0, 0, "")
    if not clone then
        _P('[境界·炼虚] 虚影创建失败')
        return
    end

    -- 记录映射关系
    PersistentVars['XUYING_CLONE_'..Object] = clone
    PersistentVars['XUYING_OWNER_'..clone] = Object

    -- 设置阵营和跟随
    local faction = Osi.GetFaction(Object)
    if faction then
        Osi.SetFaction(clone, faction)
    end
    Osi.AddPartyFollower(clone, Object)
    Osi.AddAttitudeTowardsPlayer(clone, Object, 100)

    -- 设置HP为本体75%
    local maxHP = Osi.GetMaxHitpoints(Object) or 100
    local halfHP = math.max(1, math.floor(maxHP * 3 / 4))

    -- 延迟设置HP和复制被动（等待实体完全初始化）
    PersistentVars['XUYING_PENDING_SETUP'] = clone
    PersistentVars['XUYING_PENDING_OWNER'] = Object
    PersistentVars['XUYING_PENDING_HP'] = halfHP
    Osi.TimerLaunch('BanXian_XuYing_Setup', 500)

    _P('[境界·炼虚] 虚影分身已召唤')
end

-- 虚影初始化延迟执行：复制被动和状态
local function SetupShadowClone()
    local clone = PersistentVars['XUYING_PENDING_SETUP']
    local owner = PersistentVars['XUYING_PENDING_OWNER']
    local halfHP = PersistentVars['XUYING_PENDING_HP']
    PersistentVars['XUYING_PENDING_SETUP'] = nil
    PersistentVars['XUYING_PENDING_OWNER'] = nil
    PersistentVars['XUYING_PENDING_HP'] = nil

    if not clone or not owner then return end

    -- 应用虚影外观标记
    Osi.ApplyStatus(clone, 'BANXIAN_JJ6_XUYING_MARK', -1, 1, owner)

    -- 设置HP
    if halfHP then
        Osi.SetHitpoints(clone, halfHP)
    end

    -- 复制本体的被动到虚影（参考Base.lua的Transform_Apply模式）
    local ownerEntity = Ext.Entity.Get(owner)
    if ownerEntity and ownerEntity.PassiveContainer and ownerEntity.PassiveContainer.Passives then
        local k = 1
        for _, entry in pairs(ownerEntity.PassiveContainer.Passives) do
            local ID = entry.Passive.PassiveId
            -- 排除境界系统被动（避免无限递归）和虚影本身的被动
            if not string.find(ID, 'BANXIAN_JJ6_XUYING', 1, true)
                and not string.find(ID, 'BANXIAN_JJ10_', 1, true)
                and Osi.HasPassive(clone, ID) == 0 then
                Osi.AddPassive(clone, ID)
                PersistentVars['XUYING_COPY_PASSIVE_'..clone..'_'..k] = ID
                k = k + 1
            end
        end
        PersistentVars['XUYING_COPY_PASSIVE_'..clone..'_COUNT'] = k - 1
    end

    -- 复制本体的BOOST状态到虚影（参考Base.lua的Transform模式）
    if ownerEntity and ownerEntity.StatusContainer and ownerEntity.StatusContainer.Statuses then
        local k = 1
        for _, entry in pairs(ownerEntity.StatusContainer.Statuses) do
            local ID = entry.StatusID.ID
            -- 排除虚影相关状态和境界标记
            if not string.find(ID, 'XUYING', 1, true)
                and not string.find(ID, 'BANXIAN_JJ_', 1, true)
                and Osi.HasActiveStatus(clone, ID) == 0 then
                local Duration = Osi.GetStatusTurns(owner, ID) or -1
                Osi.ApplyStatus(clone, ID, Duration, 1, owner)
                PersistentVars['XUYING_COPY_STATUS_'..clone..'_'..k] = ID
                k = k + 1
            end
        end
        PersistentVars['XUYING_COPY_STATUS_'..clone..'_COUNT'] = k - 1
    end

    _P('[境界·炼虚] 虚影被动/状态复制完成')
end

-- 清理虚影分身的PersistentVars记录
local function CleanupCloneVars(clone, owner)
    local passiveCount = PersistentVars['XUYING_COPY_PASSIVE_'..clone..'_COUNT'] or 0
    for i = 1, passiveCount do
        PersistentVars['XUYING_COPY_PASSIVE_'..clone..'_'..i] = nil
    end
    PersistentVars['XUYING_COPY_PASSIVE_'..clone..'_COUNT'] = nil

    local statusCount = PersistentVars['XUYING_COPY_STATUS_'..clone..'_COUNT'] or 0
    for i = 1, statusCount do
        PersistentVars['XUYING_COPY_STATUS_'..clone..'_'..i] = nil
    end
    PersistentVars['XUYING_COPY_STATUS_'..clone..'_COUNT'] = nil

    PersistentVars['XUYING_CLONE_'..owner] = nil
    PersistentVars['XUYING_OWNER_'..clone] = nil
end

-- 召回虚影：恢复其剩余HP到本体
local function RecallShadowClone(Object)
    if not Object then return end
    local clone = PersistentVars['XUYING_CLONE_'..Object]
    if not clone then return end

    -- 防止死亡触发也进入此函数时的重入
    if PersistentVars['XUYING_RECALLING_'..Object] then return end
    PersistentVars['XUYING_RECALLING_'..Object] = true

    -- 获取虚影剩余HP用于治疗本体
    local cloneHP = Osi.GetHitpoints(clone) or 0
    if cloneHP > 0 then
        local currentHP = Osi.GetHitpoints(Object) or 0
        local maxHP = Osi.GetMaxHitpoints(Object) or 100
        local newHP = math.min(currentHP + cloneHP, maxHP)
        Osi.SetHitpoints(Object, newHP)
        _P('[境界·炼虚] 虚影召回，恢复' .. cloneHP .. 'HP')
    end

    -- 清除虚影复制的被动（召回时需要实际移除被动）
    local passiveCount = PersistentVars['XUYING_COPY_PASSIVE_'..clone..'_COUNT'] or 0
    for i = 1, passiveCount do
        local passiveID = PersistentVars['XUYING_COPY_PASSIVE_'..clone..'_'..i]
        if passiveID and Osi.HasPassive(clone, passiveID) == 1 then
            Osi.RemovePassive(clone, passiveID)
        end
    end

    -- 移除虚影
    Osi.RemovePartyFollower(clone, Object)
    Osi.Die(clone, 0, "None", Osi.GetHostCharacter())

    -- 清理所有记录
    CleanupCloneVars(clone, Object)
    PersistentVars['XUYING_RECALLING_'..Object] = nil
end

-- 虚影死亡处理：灵魂反噬
local function OnShadowCloneDeath(clone)
    local owner = PersistentVars['XUYING_OWNER_'..clone]
    if not owner then return end

    -- 防止重入
    if PersistentVars['XUYING_RECALLING_'..owner] then return end

    _P('[境界·炼虚] 虚影被摧毁！灵魂反噬！')

    -- 反噬：对本体造成5d10精神伤害 + 失去2神识
    Osi.ApplyStatus(owner, 'BANXIAN_JJ6_XUYING_BACKLASH', 1, 1, owner)

    -- 移除本体虚影激活状态（注意：这会触发StatusRemoved，但RecallShadowClone有重入保护）
    PersistentVars['XUYING_RECALLING_'..owner] = true
    Osi.RemoveStatus(owner, 'BANXIAN_JJ6_XUYING_ACTIVE')

    -- 清理所有记录
    CleanupCloneVars(clone, owner)
    PersistentVars['XUYING_RECALLING_'..owner] = nil
end

--================================
-- Tier 6 · 炼虚 · 虚实互换
--================================
local function SwapWithClone(owner)
    local clone = PersistentVars['XUYING_CLONE_'..owner]
    if not clone then return end
    local ox, oy, oz = Osi.GetPosition(owner)
    local cx, cy, cz = Osi.GetPosition(clone)
    if not ox or not cx then return end
    Osi.TeleportToPosition(owner, cx, cy, cz, "", 0, 0, 0, 0, 1)
    Osi.TeleportToPosition(clone, ox, oy, oz, "", 0, 0, 0, 0, 1)
    Osi.ApplyStatus(clone, 'BANXIAN_JJ6_SWAP_BLUR', 1, 1, owner)
    _P('[境界·炼虚] 虚实互换！')
end

-- Tier 6 · 相位游离：纯stat实现（OnDamaged + HasHPPercentageLessThan(50)）
-- Tier 6 · 虚空侵蚀：纯stat实现（XUYING_MARK status → XUYING_EROSION_P passive）
-- Tier 6 · 虚空断裂传送：纯stat实现（Force(9,OriginToTarget,Aggressive)）

--================================
-- Tier 6 · 炼虚 · 虚空断裂击杀爆炸（仍需Lua检查Dying + MARK）
--================================
local function VoidSunderKillExplosion(attacker, deadTarget)
    local statusName = 'BANXIAN_JJ6_VOID_EXPLODE_DMG'
    if Ext.Stats.Get(statusName) == nil then
        local stat = Ext.Stats.Create(statusName, 'StatusData', 'BANXIAN_JJ5_SHENGMIE_EXPLODE')
        stat.OnApplyFunctors = 'DealDamage(4d8,Force,Magical)'
        stat:Sync()
    end
    local enemies = Utils.GetNearbyEnemies(deadTarget, attacker, 4)
    for _, enemy in ipairs(enemies) do
        Osi.ApplyStatus(enemy.guid, statusName, 1, 1, attacker)
    end
    _P('[境界·炼虚] 虚空爆炸！')
end

--================================
-- Tier 7 · 合体 · 法相裂地（移动时3m内敌人DEX豁免否则倒地）
--================================
local faxiangTurnStartPos = {} -- guid → {x, y, z}

local function FaxiangQuakeOnTurnStart(Object)
    if Osi.HasActiveStatus(Object, 'BANXIAN_JJ7_FAXIANG_STATUS') ~= 1 then
        faxiangTurnStartPos[tostring(Object)] = nil
        return
    end
    local x, y, z = Osi.GetPosition(Object)
    if x then
        faxiangTurnStartPos[tostring(Object)] = {x = x, y = y, z = z}
    end
end

local function FaxiangQuakeOnTurnEnd(Object)
    local key = tostring(Object)
    local startPos = faxiangTurnStartPos[key]
    if not startPos then return end
    faxiangTurnStartPos[key] = nil

    if Osi.HasActiveStatus(Object, 'BANXIAN_JJ7_FAXIANG_STATUS') ~= 1 then return end

    local x, y, z = Osi.GetPosition(Object)
    if not x then return end

    -- 检查是否移动了（距离 > 1m）
    local dx, dz = x - startPos.x, z - startPos.z
    if dx * dx + dz * dz < 1 then return end

    -- 对3m内所有敌人施加DEX豁免否则倒地
    local enemies = Utils.GetNearbyEnemies(Object, Object, 3)
    for _, enemy in ipairs(enemies) do
        Osi.ApplyStatus(enemy.guid, 'BANXIAN_JJ7_FAXIANG_QUAKE_HIT', 1, 1, Object)
    end
end

--================================
-- Tier 7 · 合体 · 法力共振动态伤害
--================================
-- 法相近战命中时，额外造成（6m内敌人数 × 1d6）力场伤害
local function FaxiangDynamicDamage(attacker, target)
    if Osi.HasActiveStatus(attacker, 'BANXIAN_JJ7_FAXIANG_STATUS') ~= 1 then return end
    local enemies = Utils.GetNearbyEnemies(attacker, attacker, 6)
    local enemyCount = #enemies
    if enemyCount <= 0 then return end

    local statusName = 'BANXIAN_JJ7_FAXIANG_RESONANCE_'..enemyCount
    if Ext.Stats.Get(statusName) == nil then
        local stat = Ext.Stats.Create(statusName, 'StatusData', 'BANXIAN_JJ5_SHENGMIE_EXPLODE')
        stat.OnApplyFunctors = 'DealDamage('..enemyCount..'d6,Force,Magical)'
        stat:Sync()
    end
    Osi.ApplyStatus(target, statusName, 1, 1, attacker)
end

-- Tier 7 · 金刚不坏：全部由stat被动BANXIAN_JJ7_JINGANG处理
-- DamageReduction(All,Flat,ProficiencyBonus) + CriticalHit(AttackTarget,Success,Never)

--================================
-- Tier 8 · 大乘 · 领域最高HP敌人伤害
--================================
local function DomainHighestHPDamage(Object)
    if Osi.HasActiveStatus(Object, 'BANXIAN_JJ8_LINGYU_STATUS') ~= 1 then return end
    -- 找到领域内最高HP的敌人
    local enemies = Utils.GetNearbyEnemies(Object, Object, 12)
    if #enemies == 0 then return end
    local maxHP, maxTarget = -1, nil
    for _, enemy in ipairs(enemies) do
        local hp = Osi.GetHitpoints(enemy.guid) or 0
        if hp > maxHP then
            maxHP = hp
            maxTarget = enemy.guid
        end
    end
    if maxTarget then
        local statusName = 'BANXIAN_JJ8_LINGYU_SMITE'
        if Ext.Stats.Get(statusName) == nil then
            local stat = Ext.Stats.Create(statusName, 'StatusData', 'BANXIAN_JJ5_SHENGMIE_EXPLODE')
            stat.OnApplyFunctors = 'DealDamage(3d10,Force,Magical)'
            stat:Sync()
        end
        Osi.ApplyStatus(maxTarget, statusName, 1, 1, Object)
    end
end

-- Tier 8 · 领域绝对光环：纯stat实现（AuraStatuses on ABSOLUTE_STATUS）

--================================
-- Tier 8 · 大乘 · 领域大道共鸣
--================================
-- 当领域激活时，根据当前最高道行的大道应用共鸣效果到施法者身上
-- 共鸣状态通过各自的Passives和TickFunctors影响领域内的敌人
local function ApplyDaoResonance(Object)
    if not Object then return end
    if Osi.HasStatus(Object, 'BANXIAN_JJ8_LINGYU_STATUS') ~= 1 then return end

    -- 找到最高道行的大道
    local maxDays, maxPassive = -1, nil
    for passive, suffix in pairs(DADAO_SUFFIX) do
        if Osi.HasPassive(Object, passive) == 1 then
            local d = Osi.GetStatusTurns(Object, 'BANXIAN_DH_DAY_' .. suffix) or 0
            if d > maxDays then
                maxDays, maxPassive = d, passive
            end
        end
    end

    -- 清除旧共鸣（遍历所有可能的共鸣状态）
    for _, resonanceStatus in pairs(DAO_RESONANCE) do
        if Osi.HasStatus(Object, resonanceStatus) == 1 then
            Osi.RemoveStatus(Object, resonanceStatus)
        end
    end

    -- 应用新共鸣到施法者
    if maxPassive and DAO_RESONANCE[maxPassive] then
        Osi.ApplyStatus(Object, DAO_RESONANCE[maxPassive], -1, 1, Object)

        -- 同时对领域内所有敌人应用共鸣的TickFunctors效果
        -- 通过给敌人施加对应状态实现（由AuraStatuses的DEBUFF状态中处理）
        _P('[境界·大乘] 领域共鸣激活：' .. DADAO_SUFFIX[maxPassive])
    else
        _P('[境界·大乘] 领域展开（无大道共鸣）')
    end
end

-- 领域关闭时清除共鸣
local function RemoveDaoResonance(Object)
    if not Object then return end
    for _, resonanceStatus in pairs(DAO_RESONANCE) do
        if Osi.HasStatus(Object, resonanceStatus) == 1 then
            Osi.RemoveStatus(Object, resonanceStatus)
        end
    end
end

--================================
-- Tier 9 · 渡劫 · 引劫（攻击性AoE）
--================================
-- 引劫：对18m内所有敌人造成（劫气层数 × 3d10）雷霆+光辉伤害
-- 自身承受总伤害25%，存活后获得巨大增益
local function ProcessTribulation(Object)
    if not Object then return end

    local stacks = getJieqi(Object)
    if stacks <= 0 then stacks = 1 end

    -- 计算伤害
    local enemies = Utils.GetNearbyEnemies(Object, Object, 18)
    local totalDamage = 0

    for _, enemy in ipairs(enemies) do
        -- 每层劫气3d10 → 2d10雷霆 + 1d10光辉
        local lightningName = 'BANXIAN_JJ9_YINJIE_L_'..stacks
        local radiantName = 'BANXIAN_JJ9_YINJIE_R_'..stacks
        if Ext.Stats.Get(lightningName) == nil then
            local stat = Ext.Stats.Create(lightningName, 'StatusData', 'BANXIAN_JJ5_SHENGMIE_EXPLODE')
            stat.OnApplyFunctors = 'DealDamage('..(stacks*2)..'d10,Lightning,Magical)'
            stat:Sync()
        end
        if Ext.Stats.Get(radiantName) == nil then
            local stat = Ext.Stats.Create(radiantName, 'StatusData', 'BANXIAN_JJ5_SHENGMIE_EXPLODE')
            stat.OnApplyFunctors = 'DealDamage('..stacks..'d10,Radiant,Magical)'
            stat:Sync()
        end
        Osi.ApplyStatus(enemy.guid, lightningName, 1, 1, Object)
        Osi.ApplyStatus(enemy.guid, radiantName, 1, 1, Object)
        -- 存活者眩晕1回合
        Osi.ApplyStatus(enemy.guid, 'STUNNED', 1, 1, Object)
        totalDamage = totalDamage + stacks * 16 -- 估算avg(3d10)≈16 per stack
    end

    -- 自身承受25%总伤害
    local selfDamage = math.max(1, math.floor(totalDamage / 4))
    Osi.ApplyDamage(Object, math.floor(selfDamage / 2), 'Lightning', Object)
    Osi.ApplyDamage(Object, math.floor(selfDamage / 2), 'Radiant', Object)

    -- 消耗所有劫气
    Osi.RemoveStatus(Object, 'BANXIAN_JJ9_JIEQI')
    setJieqi(Object, 0)

    -- 延迟检查存活
    PersistentVars['TRIBULATION_TARGET'] = Object
    Osi.TimerLaunch('BanXian_Tribulation_Check', 500)
end

-- 引劫存活检查
local function TribulationCheckSurvival(Object)
    if not Object then return end

    local hp = Osi.GetHitpoints(Object) or 0
    if hp > 0 then
        _P('[境界·渡劫] 引劫成功！天劫之力反哺！')

        -- 1回合全伤害免疫
        Osi.ApplyStatus(Object, 'BANXIAN_JJ9_JIEHUO', 1 * 6, 1, Object)

        -- 3回合伤害加成(+Level)
        Osi.ApplyStatus(Object, 'BANXIAN_JJ9_JIEHUO_DAMAGE', 3 * 6, 1, Object)

        -- 恢复全部Ki和神识
        local entity = Ext.Entity.Get(Object)
        if entity and entity.ActionResources and entity.ActionResources.Resources then
            local kiRes = entity.ActionResources.Resources[Utils.ResourceUUID.KiPoint]
            if kiRes and kiRes[1] then
                kiRes[1].Amount = kiRes[1].MaxAmount
            end
            local ssRes = entity.ActionResources.Resources[Utils.ResourceUUID.Shenshi]
            if ssRes and ssRes[1] then
                ssRes[1].Amount = ssRes[1].MaxAmount
            end
            entity:Replicate("ActionResources")
        end

        -- 虚影增幅
        local clone = PersistentVars['XUYING_CLONE_'..Object]
        if clone then
            local cloneHP = Osi.GetHitpoints(clone) or 0
            if cloneHP > 0 then
                Osi.RemoveStatus(Object, 'BANXIAN_JJ9_JIEHUO_DAMAGE')
                Osi.ApplyStatus(Object, 'BANXIAN_JJ9_JIEHUO_DAMAGE', 6 * 6, 1, Object)
                _P('[境界·渡劫] 虚影同渡天劫！增幅翻倍！')
            end
        end
    else
        _P('[境界·渡劫] 引劫失败……以身殉劫！')
    end
end

--================================
-- Tier 9 · 渡劫 · 劫气管理
--================================
-- 劫气层数追踪 + 5层以上无视抗性
local function ManageJieqiPierce(guid)
    local count = getJieqi(guid)
    if count >= 5 then
        if Osi.HasActiveStatus(guid, 'BANXIAN_JJ9_JIEQI_PIERCE') ~= 1 then
            Osi.ApplyStatus(guid, 'BANXIAN_JJ9_JIEQI_PIERCE', -1, 1, guid)
            _P('[境界·渡劫] 劫气贯体！无视一切抗性！')
        end
    else
        if Osi.HasActiveStatus(guid, 'BANXIAN_JJ9_JIEQI_PIERCE') == 1 then
            Osi.RemoveStatus(guid, 'BANXIAN_JJ9_JIEQI_PIERCE')
        end
    end
end

--================================
-- Tier 9 · 渡劫 · 劫雷护体反伤
--================================
local function JieleiHutiCounter(target, attacker)
    if not target or not attacker then return end
    if target == attacker then return end
    if Osi.HasPassive(target, 'BANXIAN_JJ9_DUJIE') ~= 1 then return end
    local stacks = getJieqi(target)
    if stacks <= 0 then return end

    local dice = stacks * 2
    local statusName = 'BANXIAN_JJ9_JIELEI_COUNTER_'..dice
    if Ext.Stats.Get(statusName) == nil then
        local stat = Ext.Stats.Create(statusName, 'StatusData', 'BANXIAN_JJ5_SHENGMIE_EXPLODE')
        stat.OnApplyFunctors = 'DealDamage('..dice..'d6,Lightning,Magical)'
        stat:Sync()
    end
    Osi.ApplyStatus(attacker, statusName, 1, 1, target)
end

--================================
-- Tier 9 · 渡劫 · 逆天改命
--================================
-- 盟友濒死时，代其承受致命伤害
local function NitianmingCheck(dyingAlly, cause1, cause2, cause3)
    -- 遍历所有谪仙角色寻找可以代死的
    local k = 1
    while PersistentVars['BANXIANLIST_NO_'..k] ~= nil do
        local savior = PersistentVars['BANXIANLIST_NO_'..k]
        if savior ~= dyingAlly
            and Osi.HasPassive(savior, 'BANXIAN_JJ9_NITIANMING') == 1
            and Osi.HasActiveStatus(savior, 'BANXIAN_JJ9_NITIANMING_CD') ~= 1
            and Osi.IsDead(savior) == 0 then
            -- 检查距离
            local dist = Osi.GetDistanceTo(savior, dyingAlly)
            if dist and dist <= 12 then
                -- 代受死亡：治愈盟友至1HP
                Osi.SetHitpoints(dyingAlly, 1)
                -- 自身承受巨大伤害
                local allyMaxHP = Osi.GetMaxHitpoints(dyingAlly) or 100
                Osi.ApplyDamage(savior, math.floor(allyMaxHP / 2), 'Psychic', savior)
                -- 施加冷却
                Osi.ApplyStatus(savior, 'BANXIAN_JJ9_NITIANMING_CD', -1, 1, savior)
                _P('[境界·渡劫] 逆天改命！'..tostring(savior)..'代'..tostring(dyingAlly)..'受死！')

                -- 如果代死导致施救者死亡，引爆劫气
                local saviorHP = Osi.GetHitpoints(savior) or 0
                if saviorHP <= 0 then
                    local stacks = getJieqi(savior)
                    if stacks > 0 then
                        local explodeName = 'BANXIAN_JJ9_NITIANMING_EXPLODE_'..stacks
                        if Ext.Stats.Get(explodeName) == nil then
                            local stat = Ext.Stats.Create(explodeName, 'StatusData', 'BANXIAN_JJ5_SHENGMIE_EXPLODE')
                            stat.OnApplyFunctors = 'DealDamage('..(stacks*3)..'d10,Lightning,Magical);DealDamage('..(stacks*2)..'d10,Radiant,Magical)'
                            stat:Sync()
                        end
                        local enemies = Utils.GetNearbyEnemies(savior, savior, 12)
                        for _, enemy in ipairs(enemies) do
                            Osi.ApplyStatus(enemy.guid, explodeName, 1, 1, savior)
                        end
                        _P('[境界·渡劫] 逆天改命者殉爆！劫气引爆天劫！')
                    end
                end
                return true
            end
        end
        k = k + 1
    end
    return false
end

--================================
-- Tier 9 · 渡劫 · 劫雷化身AoE（命中时3m内全体雷+光辉）
--================================
local function AvatarAoEDamage(attacker, target)
    if Osi.HasActiveStatus(attacker, 'BANXIAN_JJ9_AVATAR_STATUS') ~= 1 then return end
    local enemies = Utils.GetNearbyEnemies(target, attacker, 3)
    for _, enemy in ipairs(enemies) do
        if enemy.guid ~= target then
            local statusName = 'BANXIAN_JJ9_AVATAR_AOE_SPLASH'
            if Ext.Stats.Get(statusName) == nil then
                local stat = Ext.Stats.Create(statusName, 'StatusData', 'BANXIAN_JJ5_SHENGMIE_EXPLODE')
                stat.OnApplyFunctors = 'DealDamage(3d8,Lightning,Magical);DealDamage(3d8,Radiant,Magical)'
                stat:Sync()
            end
            Osi.ApplyStatus(enemy.guid, statusName, 1, 1, attacker)
        end
    end
end

--================================
-- Tier 9 · 渡劫 · 劫雷化身消耗劫气
--================================
local function AvatarConsumeJieqi(Object)
    Osi.RemoveStatus(Object, 'BANXIAN_JJ9_JIEQI')
    setJieqi(Object, 0)
    ManageJieqiPierce(Object)
    _P('[境界·渡劫] 劫雷化身！消耗全部劫气！')
end

--================================
-- Tier 10 · 真仙 · 长休重置仙体冷却
--================================
local function ResetXiantiCooldown(Object)
    if Osi.HasStatus(Object, 'BANXIAN_JJ10_XIANTI_CD') == 1 then
        Osi.RemoveStatus(Object, 'BANXIAN_JJ10_XIANTI_CD')
    end
end

-- Tier 10 · 斩仙斩杀：纯stat实现（IF(HasHPPercentageLessThan(25)):DealDamage(40d12)）

--================================
-- Tier 10 · 真仙 · 万法归宗反射
--================================
local function WanfaReflect(defender, attacker, damageAmount)
    if not defender or not attacker then return end
    if defender == attacker then return end
    if Osi.HasPassive(defender, 'BANXIAN_JJ10_WANFA') ~= 1 then return end
    if Osi.HasPassive(defender, 'BANXIAN_JJ10_ZHENXIAN') ~= 1 then return end
    -- 检查CD：CD刚被stat passive施加（3回合=刚触发）
    if Osi.HasActiveStatus(defender, 'BANXIAN_JJ10_WANFA_CD') ~= 1 then return end
    local cdTurns = Osi.GetStatusTurns(defender, 'BANXIAN_JJ10_WANFA_CD') or 0
    if cdTurns ~= 3 then return end -- 只在刚触发时反射

    local reflect = math.max(1, math.floor(damageAmount / 2))
    Osi.ApplyDamage(attacker, reflect, 'Force', defender)
    _P('[境界·真仙] 万法归宗！反射'..reflect..'点伤害！')
end

-- Tier 10 · 天道轮回AoE：纯stat实现（AuraStatuses on TIANDAO_STATUS）
-- Tier 10 · 仙体回复临时HP：纯stat实现（GainTemporaryHitPoints(SELF,Level)）

--================================
-- 境界被动应用：根据境界等级添加/移除被动
--================================
local TIER_PASSIVES = {
    [5] = {'BANXIAN_JJ5_FAZE', 'BANXIAN_JJ5_YINGUO_KILL'},
    [6] = {'BANXIAN_JJ6_XUYING', 'BANXIAN_JJ6_PHASE_SHIFT'},
    [7] = {'BANXIAN_JJ7_FAXIANG', 'BANXIAN_JJ7_JINGANG'},
    [8] = {'BANXIAN_JJ8_LINGYU'},
    [9] = {'BANXIAN_JJ9_DUJIE', 'BANXIAN_JJ9_JIEQI_GAIN', 'BANXIAN_JJ9_JIEQI_NIXING', 'BANXIAN_JJ9_JIELEI_HUTI', 'BANXIAN_JJ9_NITIANMING'},
    [10] = {'BANXIAN_JJ10_ZHENXIAN', 'BANXIAN_JJ10_XIANTI', 'BANXIAN_JJ10_REGEN', 'BANXIAN_JJ10_WANFA', 'BANXIAN_JJ10_SHENZU'},
}

function JingJie.ApplyTierPassives(Object)
    local JJ = Utils.GetBanxianJingjie(Object)
    if not JJ then return end

    for tier, passives in pairs(TIER_PASSIVES) do
        for _, passive in ipairs(passives) do
            if JJ >= tier then
                if Osi.HasPassive(Object, passive) ~= 1 then
                    Utils.AddPassive_Safe(Object, passive)
                end
            end
        end
    end

end

--================================
-- Tier 5 · 化神 · 生灭律系统
--================================
-- 生律：攻击吸取生命（stat passive处理），满血时多余治愈→临时HP→永久CON
-- 灭律：攻击施加死印，击杀爆炸+感染

local SHENGMIE_EXPLODE_RADIUS = 4     -- 爆炸半径

-- 生律：计算当前转化阈值（CON × 20）
-- CON 10 → 200, CON 11 → 220, CON 12 → 240, ...
local function ShengMieGetExcessCap(attacker)
    local entity = Ext.Entity.Get(attacker)
    if entity and entity.Stats then
        return (entity.Stats.Abilities[3] or 10) * 20  -- Abilities[3] = Constitution
    end
    return 200
end

-- 生律：追踪溢出治愈 → 临时HP → 永久CON（无上限，每次+1）
local function ShengMieLifeExcess(attacker)
    local hp = Osi.GetHitpoints(attacker) or 0
    local maxhp = Osi.GetMaxHitpoints(attacker) or 1
    if hp < maxhp then return end -- 没满血，无溢出

    -- 每次满血命中积累溢出值（基于等级）
    local level = Osi.GetLevel(attacker) or 1
    local excessGain = math.max(1, math.floor(level / 2))
    local key = 'SHENGMIE_EXCESS_'..tostring(attacker)
    local excess = (PersistentVars[key] or 0) + excessGain
    PersistentVars[key] = excess

    -- 施加临时生命值（刷新）
    local tempHPName = 'BANXIAN_JJ5_SHENGMIE_THP_'..excess
    if Ext.Stats.Get(tempHPName) == nil then
        local Stats = Ext.Stats.Create(tempHPName, 'StatusData', 'BANXIAN_JJ5_SHENGMIE_EXPLODE')
        Stats.Boosts = 'TemporaryHitPoints('..excess..')'
        Stats:Sync()
    end
    Osi.ApplyStatus(attacker, tempHPName, -1, 1, attacker)

    -- 检查是否达到转化阈值（CON × 20）
    local cap = ShengMieGetExcessCap(attacker)
    if excess >= cap then
        PersistentVars[key] = 0
        -- 移除临时HP状态
        Osi.RemoveStatus(attacker, tempHPName)

        -- 增加永久CON (+1, 无上限)
        local conKey = 'SHENGMIE_CON_'..tostring(attacker)
        local currentCon = (PersistentVars[conKey] or 0) + 1
        PersistentVars[conKey] = currentCon

        -- 动态创建/更新CON加成状态
        local conStatusName = 'BANXIAN_JJ5_SHENGMIE_CON_'..currentCon
        if Ext.Stats.Get(conStatusName) == nil then
            local Stats = Ext.Stats.Create(conStatusName, 'StatusData', 'BANXIAN_JJ5_SHENGMIE_CON')
            Stats.Boosts = 'Ability(Constitution,'..currentCon..')'
            Stats:Sync()
        end
        Osi.ApplyStatus(attacker, conStatusName, -1, 1, attacker)
    end
end

-- 灭律：攻击施加死印（已有死印时不重复施加，防止TickFunctors伤害无限刷新持续时间）
local function ShengMieDeathMark(attacker, target)
    if Osi.HasActiveStatus(target, 'BANXIAN_JJ5_SHENGMIE_DEATH_MARK') == 1 then return end
    Osi.ApplyStatus(target, 'BANXIAN_JJ5_SHENGMIE_DEATH_MARK', 3, 1, attacker)
end

-- 灭律：击杀爆炸（基于死亡目标最大HP造成暗蚀伤害 + 感染死印）
local function ShengMieExplode(attacker, deadTarget)
    local hadMark = Osi.HasActiveStatus(deadTarget, 'BANXIAN_JJ5_SHENGMIE_DEATH_MARK') == 1
    local maxHP = Osi.GetMaxHitpoints(deadTarget) or 20
    local damage = math.max(1, math.floor(maxHP / 4))
    if hadMark then damage = damage * 2 end -- 死印目标爆炸加倍

    -- 获取死亡目标位置
    local enemies = Utils.GetNearbyEnemies(deadTarget, attacker, SHENGMIE_EXPLODE_RADIUS)
    for _, enemy in ipairs(enemies) do
        -- 先感染死印（如果爆炸伤害直接击杀，连锁爆炸时hadMark=true → 2倍伤害）
        Osi.ApplyStatus(enemy.guid, 'BANXIAN_JJ5_SHENGMIE_DEATH_MARK', 3, 1, attacker)
        -- 再造成爆炸伤害（若击杀触发Dying → 连锁ShengMieExplode）
        Osi.ApplyDamage(enemy.guid, damage, 'Necrotic', attacker)
    end
end

--================================
-- 初始化：注册事件监听
--================================
function JingJie.Init()
    -- 注册自身到Utils，避免console命令中require无mod context的问题
    Utils._JingJieModule = JingJie

    -- ===== 施法追踪 =====
    Ext.Osiris.RegisterListener("UsingSpell", 5, "after", function(Caster, Spell, SpellType, SpellElement, StoryActionID)
        -- 因果律：记录最后施放法术
        yinGuoLastSpell[tostring(Caster)] = Spell

        -- Tier 6: 虚实互换
        if Spell == 'Shout_BANXIAN_JJ6_SWAP' then
            SwapWithClone(Caster)
        end
    end)

    -- ===== 攻击事件（因果律 + 五行律）=====
    Ext.Osiris.RegisterListener("AttackedBy", 7, "after", function(Defender, AttackerOwner, Attacker2, DamageType, DamageAmount, DamageCause, StoryActionID)
        -- Tier 5: 因果律 - 攻击命中后对附近敌人造成链式伤害（武器→武器攻击，法术→镜像伤害）
        if Osi.HasStatus(AttackerOwner, 'BANXIAN_JJ5_YINGUO_STATUS') == 1
            and DamageAmount > 0
            and AttackerOwner ~= Defender then
            YinGuoChain(Defender, AttackerOwner, DamageType, DamageAmount)
        end

        -- Tier 5: 五行律 - 五行印标记系统
        if Osi.HasStatus(AttackerOwner, 'BANXIAN_JJ5_WUXING_STATUS') == 1
            and DamageAmount > 0
            and AttackerOwner ~= Defender then
            WuXingOnHit(AttackerOwner, Defender)
        end

        -- Tier 5: 生灭律 - 生律溢出追踪 / 灭律死印施加
        if Osi.HasStatus(AttackerOwner, 'BANXIAN_JJ5_SHENGMIE_STATUS') == 1
            and DamageAmount > 0
            and AttackerOwner ~= Defender then
            if Osi.HasActiveStatus(AttackerOwner, 'BANXIAN_JJ5_SHENGMIE_MIE_MODE') == 1 then
                ShengMieDeathMark(AttackerOwner, Defender)
            else
                ShengMieLifeExcess(AttackerOwner)
            end
        end

        -- Tier 6: 虚空侵蚀/相位游离/虚空断裂传送 → 纯stat实现，无需Lua

        -- Tier 7: 法相法力共振动态伤害（附近敌人数 × 1d6力场）
        if DamageAmount > 0 and AttackerOwner ~= Defender then
            FaxiangDynamicDamage(AttackerOwner, Defender)
        end

        -- Tier 9: 劫雷化身AoE（命中时3m内全体雷+光辉）
        if DamageAmount > 0 and AttackerOwner ~= Defender then
            AvatarAoEDamage(AttackerOwner, Defender)
        end

        -- Tier 9: 劫雷护体反伤（被攻击时反击雷伤 = 劫气层数 × 2d6）
        if DamageAmount > 0 and AttackerOwner ~= Defender then
            JieleiHutiCounter(Defender, AttackerOwner)
        end

        -- Tier 10: 斩仙斩杀 → 纯stat实现（IF(HasHPPercentageLessThan(25)):DealDamage）

        -- Tier 10: 万法归宗50%反射
        if DamageAmount > 0 and AttackerOwner ~= Defender then
            WanfaReflect(Defender, AttackerOwner, DamageAmount)
        end
    end)

    -- ===== 状态应用事件 =====
    Ext.Osiris.RegisterListener("StatusApplied", 4, "after", function(Object, Status, Causee, StoryActionID)
        -- Tier 6: 虚影召唤信号
        if Status == 'BANXIAN_JJ6_XUYING_ACTIVE' then
            SummonShadowClone(Object)
        end

        -- Tier 8: 领域激活时应用大道共鸣
        if Status == 'BANXIAN_JJ8_LINGYU_STATUS' then
            ApplyDaoResonance(Object)
        end

        -- Tier 9: 引劫（攻击性天劫）
        if Status == 'BANXIAN_JJ9_TIANJIE_STRIKE' then
            ProcessTribulation(Object)
        end

        -- Tier 9: 劫气堆叠追踪
        if Status == 'BANXIAN_JJ9_JIEQI' then
            local count = getJieqi(Object) + 1
            if count > 9 then count = 9 end
            setJieqi(Object, count)
            ManageJieqiPierce(Object)
        end

        -- Tier 9: 劫雷化身消耗全部劫气
        if Status == 'BANXIAN_JJ9_AVATAR_STATUS' then
            AvatarConsumeJieqi(Object)
        end

        -- Tier 8: 领域绝对光环 → 纯stat实现（AuraStatuses）
        -- Tier 10: 斩仙斩杀 → 纯stat实现（IF条件）
    end)

    -- ===== 状态移除事件 =====
    Ext.Osiris.RegisterListener("StatusRemoved", 4, "after", function(Object, Status, Causee, StoryActionID)
        -- Tier 6: 虚影激活状态被移除 → 触发召回
        if Status == 'BANXIAN_JJ6_XUYING_ACTIVE' then
            RecallShadowClone(Object)
        end

        -- Tier 8: 领域关闭时清除共鸣
        if Status == 'BANXIAN_JJ8_LINGYU_STATUS' then
            RemoveDaoResonance(Object)
        end

        -- Tier 9: 劫气移除追踪
        if Status == 'BANXIAN_JJ9_JIEQI' then
            setJieqi(Object, 0)
            ManageJieqiPierce(Object)
        end

        -- Tier 5: 五行律关闭时清除所有五行印
        if Status == 'BANXIAN_JJ5_WUXING_STATUS' then
            for _, entity in pairs(Ext.Entity.GetAllEntitiesWithComponent("Health")) do
                if entity.Uuid then
                    local guid = tostring(entity.Uuid.EntityUuid)
                    for _, mark in ipairs(WUXING_MARKS) do
                        if Osi.HasActiveStatus(guid, mark) == 1 then
                            Osi.RemoveStatus(guid, mark)
                        end
                    end
                end
            end
            PersistentVars['WUXING_STAGE_'..Object] = nil
        end
    end)

    -- ===== 死亡事件 =====
    Ext.Osiris.RegisterListener("Dying", 4, "after", function(Object, Cause1, Cause2, Cause3)
        -- Tier 6: 虚影死亡 → 灵魂反噬本体
        if PersistentVars['XUYING_OWNER_'..Object] then
            OnShadowCloneDeath(Object)
        end

        -- Tier 6: 虚空断裂击杀爆炸（检查目标是否有MARK状态）
        if Osi.HasActiveStatus(Object, 'BANXIAN_JJ6_VOID_SUNDER_MARK') == 1 then
            for _, cause in ipairs({Cause1, Cause2, Cause3}) do
                if cause and cause ~= '' and cause ~= Object then
                    VoidSunderKillExplosion(cause, Object)
                    break
                end
            end
        end

        -- Tier 9: 逆天改命 - 友方濒死时代受
        if Osi.IsAlly(Object, Osi.GetHostCharacter()) == 1 then
            NitianmingCheck(Object, Cause1, Cause2, Cause3)
        end

        -- Tier 5: 生灭律·灭 - 击杀爆炸+死印感染
        for _, cause in ipairs({Cause1, Cause2, Cause3}) do
            if cause and cause ~= '' and cause ~= Object
                and Osi.HasStatus(cause, 'BANXIAN_JJ5_SHENGMIE_STATUS') == 1
                and Osi.HasActiveStatus(cause, 'BANXIAN_JJ5_SHENGMIE_MIE_MODE') == 1 then
                ShengMieExplode(cause, Object)
                break
            end
        end
    end)

    -- ===== Timer事件 =====
    Ext.Osiris.RegisterListener("TimerFinished", 1, "after", function(Timer)
        -- Tier 6: 虚影初始化延迟
        if Timer == 'BanXian_XuYing_Setup' then
            SetupShadowClone()
        end

        -- Tier 9: 引劫存活检查
        if Timer == 'BanXian_Tribulation_Check' then
            local target = PersistentVars['TRIBULATION_TARGET']
            PersistentVars['TRIBULATION_TARGET'] = nil
            if target then
                TribulationCheckSurvival(target)
            end
        end
    end)

    -- ===== 回合开始 =====
    -- ===== 回合结束 =====
    Ext.Osiris.RegisterListener("TurnEnded", 1, "after", function(Object)
        -- Tier 7: 法相裂地（移动后3m内敌人DEX豁免否则倒地）
        FaxiangQuakeOnTurnEnd(Object)
    end)

    -- ===== 回合开始 =====
    Ext.Osiris.RegisterListener("TurnStarted", 1, "after", function(Object)
        -- Tier 7: 法相裂地记录起始位置
        FaxiangQuakeOnTurnStart(Object)

        -- Tier 8: 领域每回合对最高HP敌人造成3d10力场
        DomainHighestHPDamage(Object)

        -- Tier 9: 战斗中满血时每回合积累1劫气（最多9层）
        if Osi.HasPassive(Object, 'BANXIAN_JJ9_DUJIE') == 1 then
            local hp = Osi.GetHitpoints(Object) or 0
            local maxhp = Osi.GetMaxHitpoints(Object) or 1
            if hp >= maxhp then
                if getJieqi(Object) < 9 then
                    Osi.ApplyStatus(Object, 'BANXIAN_JJ9_JIEQI', -1, 1, Object)
                end
            end
        end

        -- Tier 10: 天道轮回AoE → 纯stat实现（AuraStatuses）
        -- Tier 10: 仙体回复临时HP → 纯stat实现（GainTemporaryHitPoints）
    end)

    -- ===== 长休事件 =====
    Ext.Osiris.RegisterListener("LongRestFinished", 0, "after", function()
        local k = 1
        while PersistentVars['BANXIANLIST_NO_'..k] ~= nil do
            local Object = PersistentVars['BANXIANLIST_NO_'..k]

            -- Tier 10: 重置仙体不灭冷却
            if Osi.HasPassive(Object, 'BANXIAN_JJ10_ZHENXIAN') == 1 then
                ResetXiantiCooldown(Object)
            end

            -- Tier 9: 每10天长休积累1劫气
            if Osi.HasPassive(Object, 'BANXIAN_JJ9_DUJIE') == 1 then
                local gameDays = PersistentVars['GAME_DAYS'] or 0
                if gameDays % 10 == 0 then
                    if getJieqi(Object) < 9 then
                        Osi.ApplyStatus(Object, 'BANXIAN_JJ9_JIEQI', -1, 1, Object)
                        _P('[境界·渡劫] 天机感应，劫气+1')
                    end
                end
            end

            -- Tier 9: 重置逆天改命冷却
            if Osi.HasActiveStatus(Object, 'BANXIAN_JJ9_NITIANMING_CD') == 1 then
                Osi.RemoveStatus(Object, 'BANXIAN_JJ9_NITIANMING_CD')
            end

            -- Tier 6: 长休时如果虚影还存在，清除（避免跨休虚影残留）
            local clone = PersistentVars['XUYING_CLONE_'..Object]
            if clone then
                RecallShadowClone(Object)
                Osi.RemoveStatus(Object, 'BANXIAN_JJ6_XUYING_ACTIVE')
            end

            k = k + 1
        end
    end)

    -- ===== 战斗开始 =====
    -- Tier 9 劫气战斗初始化由stat passive BANXIAN_JJ9_JIEQI_GAIN (OnCombatStarted) 处理
    -- 不再在Lua中重复，避免Additive双重堆叠

    _P('[谪仙] 境界能力系统已加载 (化神→真仙)')
end

return JingJie
