local DanYao = {
    Drop = {},
    Function = {}
}
local Variables = require("Server.Modules.Variables")

-- 初始化物品系统
function DanYao.Init()
    _P("[DanYao] 初始化物品系统...")

    -- 注册事件监听丹药相关状态
    Ext.Osiris.RegisterListener("StatusApplied", 4, "after", DanYao.OnStatusApplied_after)
    _P("[DanYao] 物品系统初始化完成！")
end





-- 掉落药材
function DanYao.Drop.YaoCai(Object)
    local Level = Osi.GetLevel(Object)
    local YaoCai_Probabilities = Variables.Constants.DanYao.DropProbabilities.YaoCai
    local BaoCai_Probabilities = Variables.Constants.DanYao.DropProbabilities.BaoCai
    --_P("[DanYao.Drop.YaoCai] 当前对象等级：", Level)  --DEBUG

    -- 药材掉落逻辑
    for _, item in ipairs(YaoCai_Probabilities) do
        local Amount = 1
        local id = item.id
        local factor = item.factor
        local Level_Ex = math.random(1, (Level + 4) * 20)
        Level_Ex = Level_Ex * math.random(factor[1], factor[2])

        -- 如果是植物类怪物，概率翻倍，数量随机
        if Osi.IsTagged(Object, '125b3d94-3997-4fc4-8211-1768b67dbe4a') == 1 then
            Level_Ex = Level_Ex / 2
            Amount = math.random(1, 3)
            --_P("[DanYao.Drop.YaoCai] 植物类怪物，概率翻倍，数量随机：", Amount)  --DEBUG
        end

        -- 判断是否掉落
        if Level_Ex <= Level then
            local templateID = id < 10 and '987e1e7e-9656-4fdf-a0d2-e745ccb00a0'..id or '987e1e7e-9656-4fdf-a0d2-e745ccb00a'..id
            Osi.TemplateAddTo(templateID, Object, Amount, 1)
            --_P("[DanYao.Drop.YaoCai] 掉落药材：ID=", id, ", 数量=", Amount)  --DEBUG
        end
    end

    -- 宝材掉落逻辑
    for _, item in ipairs(BaoCai_Probabilities) do
        local Amount = 1
        local id = item.id
        local tag = item.tag
        local factor = item.factor
        local droplevel = item.droplevel
        local Level_Ex = math.random(1, (Level + 4) * 40)

        -- 根据宝材 ID 和对象标签调整概率
        if tag then
            if type(tag) == 'table' then
                local tagged = false
                for _, t in ipairs(tag) do
                    if Osi.IsTagged(Object, t) == 1 then
                        Level_Ex = Level_Ex / factor[1]
                        tagged = true
                        break
                    end
                end
                if not tagged then
                    Level_Ex = Level_Ex * 100
                end
            else
                if Osi.IsTagged(Object, tag) == 1 then
                    Level_Ex = Level_Ex / factor[1]
                else
                    Level_Ex = Level_Ex * 100
                end
            end
        end

        -- 判断是否掉落
        if Level_Ex <= Level and (not droplevel or Level >= droplevel) then
            local templateID = id < 10 and '987e1e7e-9656-4fdf-a0d2-e745bca00a0'..id or '987e1e7e-9656-4fdf-a0d2-e745bca00a'..id
            Osi.TemplateAddTo(templateID, Object, Amount, 1)
            --_P("[DanYao.Drop.YaoCai] 掉落宝材：ID=", id, ", 数量=", Amount)  --DEBUG
        end
    end
end

-- 掉落宝材
function DanYao.Drop.BaoCai(Object)
    --_P("[DanYao.Drop.BaoCai] 处理对象：", Object)  --DEBUG

    local MaxHP = Osi.GetMaxHitpoints(Object)
    --_P("[DanYao.Drop.BaoCai] 对象最大生命值：", MaxHP)  --DEBUG

    if Osi.HasActiveStatus(Object, 'BANXIAN_DH_YEAR') == 1 then
        local DH_YEAR = Osi.GetStatusTurns(Object, 'BANXIAN_DH_YEAR')
        _P("[DanYao.Drop.BaoCai] 当前对象道行：", DH_YEAR)  --DEBUG

        if Osi.IsTagged(Object, '7fbed0d4-cabc-4a9d-804e-12ca6088a0a8') == 1 then  -- 类人生物
            if math.random(1, (DH_YEAR + 9) * (DH_YEAR + 9) * 10) <= DH_YEAR then
                Osi.TemplateAddTo('987e1e7e-9656-4fdf-a0d2-e745bca00a05', Object, 1, 1)
                _P("[DanYao.Drop.BaoCai] 类人生物掉落宝材：ID=5")  --DEBUG
            end
        else  -- 非类人生物
            if math.random(1, (DH_YEAR + 9) * (DH_YEAR + 9) * 2) <= DH_YEAR then
                Osi.TemplateAddTo('987e1e7e-9656-4fdf-a0d2-e745bca00a06', Object, 1, 1)
                _P("[DanYao.Drop.BaoCai] 非类人生物掉落宝材：ID=6")  --DEBUG
            end
        end
    else  -- 无道行状态
        if Osi.IsTagged(Object, '7fbed0d4-cabc-4a9d-804e-12ca6088a0a8') == 1 then  -- 类人生物
            if math.random(1, (MaxHP + 99) * 10) <= MaxHP then
                Osi.TemplateAddTo('987e1e7e-9656-4fdf-a0d2-e745bca00a05', Object, 1, 1)
                --_P("[DanYao.Drop.BaoCai] 类人生物掉落宝材：ID=5")  --DEBUG
            end
        else  -- 非类人生物
            if math.random(1, (MaxHP + 99) * 5) <= MaxHP then
                Osi.TemplateAddTo('987e1e7e-9656-4fdf-a0d2-e745bca00a06', Object, 1, 1)
                --_P("[DanYao.Drop.BaoCai] 非类人生物掉落宝材：ID=6")  --DEBUG
            end
        end
    end
end


--五蕴丹
function DanYao.Function.WuYunDan(Object)
    local LG_TZ = Osi.GetStatusTurns(Object, 'BANXIAN_LG_TZ') or 0
    _P('[五蕴丹]重塑资质：原资质'..LG_TZ)
    local r = 20

    --确定提升系数,移除资质被动
    if LG_TZ == 1 then
        LG_TZ = 2
        r = 50
    elseif LG_TZ == 2 then
        LG_TZ = math.random(3,5)
        r = 20
    elseif LG_TZ >= 3 and LG_TZ < 5 then
        LG_TZ = math.max(math.min(LG_TZ+1,5),math.random(3,5))
        r = 20
    elseif LG_TZ >= 5 then
        LG_TZ = math.max(math.min(LG_TZ+1,10),math.random(6,10))
        r = 10
    end
    _P('[五蕴丹]重塑资质：现资质'..LG_TZ)

    Osi.ApplyStatus(Object,'BANXIAN_LG_TZ', LG_TZ * 6)
    
end





-- 事件·生物死亡
function DanYao.OnStatusApplied_after(Object, Status, Causee)

    if Status == 'DYING' then
        DanYao.Drop.YaoCai(Object)
        DanYao.Drop.BaoCai(Object)
    elseif Status == 'DT_WUYUN_DAN' then
        if Osi.HasPassive(Object, 'BanXian_LingGen_T0') == 0 then
            DanYao.Function.WuYunDan(Object)
        else
            _P('先天道体 无需提升')
        end
    end

    if Status == 'BANXIAN_FABAO_FIREBREATH_BURNING' then
        local DisplayName = Osi.GetDisplayName(Object)
        local Empty = Osi.IsInventoryEmpty(Object)
        _P(DisplayName) --DEBUG
        _P(Empty) --DEBUG
    end

end

return DanYao
