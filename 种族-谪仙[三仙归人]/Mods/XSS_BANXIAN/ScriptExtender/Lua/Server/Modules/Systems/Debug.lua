local Debug = {}
local Variables = require("Server.Modules.Variables")
local Utils = require("Server.Modules.Utils")

-- 境界名称 → 所需总道行天数（最低阈值）
local JingjieThresholds = {
    ['练气'] = 0,       -- < 5 year
    ['筑基'] = 5 * 365,
    ['结丹'] = 20 * 365,
    ['元婴'] = 60 * 365,
    ['化神'] = 150 * 365,
    ['炼虚'] = 400 * 365,
    ['合体'] = 1000 * 365,
    ['大乘'] = 3000 * 365,
    ['渡劫'] = 8000 * 365,
    ['真仙'] = 20000 * 365,
}

-- 境界索引 → 名称
local JingjieNames = {'练气','筑基','结丹','元婴','化神','炼虚','合体','大乘','渡劫','真仙'}

-- 大道名称 → 被动ID映射（中文名→passive）
local DaDaoByName = {}
for passive, name in pairs(Variables.Constants.DaDao) do
    DaDaoByName[name] = passive
end

-- 功法名称 → passive ID
local GongFaByName = {
    ['弄焰诀'] = 'BANXIAN_GONGFA_FireMixer',
    ['怒血诀'] = 'BANXIAN_GONGFA_RageBlood',
    ['灵目诀'] = 'BANXIAN_GONGFA_DarkEyes',
    ['焚诀']   = 'BANXIAN_GONGFA_FenJue',
    ['仙门奇术'] = 'BANXIAN_GONGFA_QiShu',
}

-- 百脉锻宝诀被动列表
local BaiMaiPassives = {
    'FABAO_BAIMAI_1','FABAO_BAIMAI_2','FABAO_BAIMAI_3',
    'FABAO_BAIMAI_4','FABAO_BAIMAI_5','FABAO_BAIMAI_6',
}

-- 灵根名称 → 状态ID
local LingGenByName = {
    ['火'] = 'BANXIAN_LG_H',
    ['土'] = 'BANXIAN_LG_T',
    ['金'] = 'BANXIAN_LG_J',
    ['水'] = 'BANXIAN_LG_S',
    ['木'] = 'BANXIAN_LG_M',
}

-- 大道后缀映射
local DADAO_SUFFIX = {
    ['BanXian_DH_Tian']='TIAN', ['BanXian_DH_XiuLuo']='XIULUO',
    ['BanXian_DH_RenJian']='RENJIAN', ['BanXian_DH_ChuSheng']='CHUSHENG',
    ['BanXian_DH_EGui']='EGUI', ['BanXian_DH_DiYu']='DIYU',
    ['BanXian_DH_Jian']='JIAN', ['BanXian_DH_Li']='LI',
    ['BanXian_DH_HeHuan']='HEHUAN', ['BanXian_DH_Yi']='YI',
}

-- 当前选中角色（由客户端通过net message更新）
local selectedChar = nil

-- 获取当前操作目标：优先使用选中角色，回退到主角
local function GetHost()
    return selectedChar or Osi.GetHostCharacter()
end

-- 找到角色道行最高的大道后缀（用于设置道行时同步path day）
local function GetMaxDaoSuffix(target)
    local maxDays, maxSuffix = -1, nil
    for passive, suffix in pairs(DADAO_SUFFIX) do
        if Osi.HasPassive(target, passive) == 1 then
            local d = Osi.GetStatusTurns(target, 'BANXIAN_DH_DAY_' .. suffix) or 0
            if d > maxDays then
                maxDays, maxSuffix = d, suffix
            end
        end
    end
    return maxSuffix
end

-- 设置道行天数（同时更新path day + shared day + 境界）
local function SetDaoHengDays(target, days)
    local suffix = GetMaxDaoSuffix(target)
    if suffix then
        -- 设置第一个大道的path day，让UpdateSharedDay能同步
        Osi.ApplyStatus(target, 'BANXIAN_DH_DAY_' .. suffix, days * 6, 1, target)
        Utils.DaDao.UpdateSharedDay(target)
    else
        -- 无大道，直接设共享day（UpdateSharedDay会覆盖，所以不调用它）
        Osi.ApplyStatus(target, 'BANXIAN_DH_DAY', days * 6, 1, target)
    end
    Utils.BanXian.JingjieBoost(target)
end

-- 打印帮助
local function PrintHelp()
    _P('=== 谪仙·调试指令 ===')
    _P('!bx help                    -- 显示此帮助')
    _P('!bx info                    -- 显示当前主角全部修仙信息')
    _P('!bx info <uuid>             -- 显示指定角色信息')
    _P('')
    _P('--- 灵根 ---')
    _P('!bx linggen set 火 100      -- 设置火灵根为100')
    _P('!bx linggen set 全 200      -- 设置五灵根各200')
    _P('!bx linggen tz 5            -- 设置资质为5')
    _P('!bx linggen clear           -- 清除全部灵根')
    _P('')
    _P('--- 道行 ---')
    _P('!bx daoheng set 1000        -- 设置总道行天数为1000')
    _P('!bx daoheng add 365         -- 增加365天道行')
    _P('')
    _P('--- 境界（快捷设道行） ---')
    _P('!bx jingjie 化神            -- 直接设为化神境界（设道行到阈值）')
    _P('')
    _P('--- 大道 ---')
    _P('!bx dadao add 剑道          -- 添加剑道')
    _P('!bx dadao remove 剑道       -- 移除剑道')
    _P('!bx dadao list              -- 列出可用大道')
    _P('!bx dadao days 剑道 1000    -- 设置剑道道行天数为1000')
    _P('')
    _P('--- 神识 ---')
    _P('!bx shenshi set 20          -- 设置神识点数为20')
    _P('!bx shenshi max 30          -- 设置神识最大值为30')
    _P('')
    _P('--- 功法 ---')
    _P('!bx gongfa add 弄焰诀       -- 添加功法被动')
    _P('!bx gongfa remove 弄焰诀    -- 移除功法被动')
    _P('!bx gongfa list             -- 列出可用功法')
    _P('')
    _P('--- 法宝（百脉锻宝诀） ---')
    _P('!bx fabao add 1             -- 添加百脉锻宝第1阶被动')
    _P('!bx fabao addall            -- 添加全部百脉锻宝被动')
    _P('!bx fabao remove 1          -- 移除百脉锻宝第1阶被动')
    _P('!bx fabao clear             -- 移除全部百脉锻宝被动')
    _P('')
    _P('--- 刷新 ---')
    _P('!bx refresh                 -- 刷新全部增益（境界/道行/神识/灵根/大道）')
end

-- 显示角色信息
local function ShowInfo(target)
    _P('=== 修仙信息 ===')

    -- 境界
    local JJ = Utils.GetBanxianJingjie(target)
    _P('[境界] ' .. (JingjieNames[JJ] or '未知') .. ' (等级' .. JJ .. ')')

    -- 道行
    local totalDays = Osi.GetStatusTurns(target, 'BANXIAN_DH_DAY') or 0
    local years = math.floor(totalDays / 365)
    local days = totalDays - years * 365
    _P('[道行] ' .. years .. '年' .. days .. '日 (总' .. totalDays .. '天)')

    -- 灵根
    local lgParts = {}
    for LG, NAME in pairs(Variables.Constants.LingGen) do
        local val = Osi.GetStatusTurns(target, LG) or 0
        if val >= 1 then
            lgParts[#lgParts+1] = NAME .. val
        end
    end
    local TZ = Osi.GetStatusTurns(target, 'BANXIAN_LG_TZ') or 0
    _P('[灵根] ' .. (#lgParts > 0 and table.concat(lgParts, ' ') or '无') .. '  资质=' .. TZ)

    -- 大道
    local daoParts = {}
    for ID, NAME in pairs(Variables.Constants.DaDao) do
        if Osi.HasPassive(target, ID) == 1 then
            local suffix = DADAO_SUFFIX[ID]
            local d = suffix and (Osi.GetStatusTurns(target, 'BANXIAN_DH_DAY_' .. suffix) or 0) or 0
            daoParts[#daoParts+1] = NAME .. '(' .. d .. '天)'
        end
    end
    _P('[大道] ' .. (#daoParts > 0 and table.concat(daoParts, ' ') or '未领悟'))

    -- 神识
    local SHENSHI_UUID = '0032115b-77c3-43c8-9385-630e657b2fcc'
    local ssAmount = Utils.Get.ActionResource(target, SHENSHI_UUID)
    local ssMax = Utils.Get.ActionResourceMax(target, SHENSHI_UUID)
    _P('[神识] ' .. ssAmount .. '/' .. ssMax)

    -- 功法
    local gfParts = {}
    for name, passive in pairs(GongFaByName) do
        if Osi.HasPassive(target, passive) == 1 then
            gfParts[#gfParts+1] = name
        end
    end
    _P('[功法] ' .. (#gfParts > 0 and table.concat(gfParts, ' ') or '无'))

    -- 百脉锻宝
    local bmParts = {}
    for i, passive in ipairs(BaiMaiPassives) do
        if Osi.HasPassive(target, passive) == 1 then
            bmParts[#bmParts+1] = tostring(i)
        end
    end
    _P('[百脉] ' .. (#bmParts > 0 and table.concat(bmParts, ',') or '无'))
end

-- 刷新全部增益
local function RefreshAll(target)
    Utils.DaDao.UpdateSharedDay(target)
    Utils.DaDao.Hehuan(target)
    Utils.DaDao.Li(target)
    Utils.ShenShi.Check(target)
    Utils.BanXian.JingjieBoost(target)
    Osi.ApplyStatus(target, 'SIGNAL_YLG_CHECK', 100, 0)
    _P('[刷新] 全部增益已刷新')
end

-- 设置神识资源点
local function SetActionResource(target, uuid, amount)
    local entity = Ext.Entity.Get(target)
    if not entity then _P('[错误] 无法获取实体') return end
    local res = entity.ActionResources.Resources[uuid]
    if res and res[1] then
        res[1].Amount = amount
        entity:Replicate("ActionResources")
    end
end

-- 设置神识最大资源点
local function SetActionResourceMax(target, uuid, amount)
    local entity = Ext.Entity.Get(target)
    if not entity then _P('[错误] 无法获取实体') return end
    local res = entity.ActionResources.Resources[uuid]
    if res and res[1] then
        res[1].MaxAmount = amount
        res[1].Amount = math.min(res[1].Amount, amount)
        entity:Replicate("ActionResources")
    end
end

function Debug.Init()

    -- 接收客户端选中角色更新
    Ext.RegisterNetListener('BanXian_SelectedChar', function(_, payload)
        if payload and payload ~= '' then
            selectedChar = payload
        end
    end)

    Ext.RegisterConsoleCommand('bx', function(_, cmd, ...)
        local args = {...}
        cmd = cmd or 'help'
        local target = GetHost()

        if cmd == 'help' then
            PrintHelp()

        elseif cmd == 'info' then
            local t = args[1] or target
            ShowInfo(t)

        elseif cmd == 'refresh' then
            RefreshAll(target)

        elseif cmd == 'linggen' then
            local sub = args[1]
            if sub == 'set' then
                local elem = args[2]
                local val = tonumber(args[3])
                if not val then _P('[错误] 需要数值') return end
                if elem == '全' or elem == 'all' then
                    for _, statusId in pairs(LingGenByName) do
                        Osi.ApplyStatus(target, statusId, val * 6, 1, target)
                    end
                    _P('[灵根] 五灵根各设为 ' .. val)
                else
                    local statusId = LingGenByName[elem]
                    if not statusId then _P('[错误] 未知灵根: ' .. tostring(elem) .. ' (可用: 火/土/金/水/木/全)') return end
                    Osi.ApplyStatus(target, statusId, val * 6, 1, target)
                    _P('[灵根] ' .. elem .. '灵根设为 ' .. val)
                end
                Osi.ApplyStatus(target, 'SIGNAL_YLG_CHECK', 100, 0)

            elseif sub == 'tz' then
                local val = tonumber(args[2])
                if not val then _P('[错误] 需要数值') return end
                Osi.ApplyStatus(target, 'BANXIAN_LG_TZ', val * 6, 1, target)
                _P('[灵根] 资质设为 ' .. val)

            elseif sub == 'clear' then
                for _, statusId in pairs(LingGenByName) do
                    Osi.RemoveStatus(target, statusId)
                end
                Osi.RemoveStatus(target, 'BANXIAN_LG_TZ')
                _P('[灵根] 已清除全部灵根和资质')
            else
                _P('[错误] 未知子命令: linggen ' .. tostring(sub))
            end

        elseif cmd == 'daoheng' then
            local sub = args[1]
            if sub == 'set' then
                local val = tonumber(args[2])
                if not val then _P('[错误] 需要数值') return end
                SetDaoHengDays(target, val)
                _P('[道行] 总道行设为 ' .. val .. ' 天')

            elseif sub == 'add' then
                local val = tonumber(args[2])
                if not val then _P('[错误] 需要数值') return end
                local cur = Osi.GetStatusTurns(target, 'BANXIAN_DH_DAY') or 0
                SetDaoHengDays(target, cur + val)
                _P('[道行] 增加 ' .. val .. ' 天，现为 ' .. (cur + val) .. ' 天')
            else
                _P('[错误] 未知子命令: daoheng ' .. tostring(sub))
            end

        elseif cmd == 'jingjie' then
            local name = args[1]
            if not name then
                _P('[境界] 可用: ' .. table.concat(JingjieNames, '/'))
                return
            end
            local threshold = JingjieThresholds[name]
            if not threshold then _P('[错误] 未知境界: ' .. name) return end
            local days = threshold > 0 and threshold or 1
            SetDaoHengDays(target, days)
            _P('[境界] 已设为 ' .. name .. ' (' .. days .. '天)')

        elseif cmd == 'dadao' then
            local sub = args[1]
            if sub == 'list' then
                _P('[大道] 可用:')
                for passive, name in pairs(Variables.Constants.DaDao) do
                    local has = Osi.HasPassive(target, passive) == 1 and ' ✓' or ''
                    _P('  ' .. name .. ' (' .. passive .. ')' .. has)
                end

            elseif sub == 'add' then
                local name = args[2]
                if not name then _P('[错误] 需要大道名称') return end
                local passive = DaDaoByName[name]
                if not passive then _P('[错误] 未知大道: ' .. name .. '  用 !bx dadao list 查看') return end
                Utils.AddPassive_Safe(target, passive)
                _P('[大道] 已添加 ' .. name)

            elseif sub == 'remove' then
                local name = args[2]
                if not name then _P('[错误] 需要大道名称') return end
                local passive = DaDaoByName[name]
                if not passive then _P('[错误] 未知大道: ' .. name) return end
                if Osi.HasPassive(target, passive) == 1 then
                    Osi.RemovePassive(target, passive)
                end
                _P('[大道] 已移除 ' .. name)

            elseif sub == 'days' then
                local name = args[2]
                local val = tonumber(args[3])
                if not name or not val then _P('[错误] 用法: !bx dadao days <大道名> <天数>') return end
                local passive = DaDaoByName[name]
                if not passive then _P('[错误] 未知大道: ' .. name) return end
                local suffix = DADAO_SUFFIX[passive]
                if not suffix then _P('[错误] 无法找到大道后缀') return end
                Osi.ApplyStatus(target, 'BANXIAN_DH_DAY_' .. suffix, val * 6, 1, target)
                Utils.DaDao.UpdateSharedDay(target)
                Utils.BanXian.JingjieBoost(target)
                _P('[大道] ' .. name .. ' 道行设为 ' .. val .. ' 天')
            else
                _P('[错误] 未知子命令: dadao ' .. tostring(sub))
            end

        elseif cmd == 'shenshi' then
            local SHENSHI_UUID = '0032115b-77c3-43c8-9385-630e657b2fcc'
            local sub = args[1]
            if sub == 'set' then
                local val = tonumber(args[2])
                if not val then _P('[错误] 需要数值') return end
                SetActionResource(target, SHENSHI_UUID, val)
                Utils.ShenShi.Check(target)
                _P('[神识] 点数设为 ' .. val)

            elseif sub == 'max' then
                local val = tonumber(args[2])
                if not val then _P('[错误] 需要数值') return end
                SetActionResourceMax(target, SHENSHI_UUID, val)
                Utils.ShenShi.Check(target)
                _P('[神识] 最大值设为 ' .. val)
            else
                _P('[错误] 未知子命令: shenshi ' .. tostring(sub))
            end

        elseif cmd == 'gongfa' then
            local sub = args[1]
            if sub == 'list' then
                _P('[功法] 可用:')
                for name, passive in pairs(GongFaByName) do
                    local has = Osi.HasPassive(target, passive) == 1 and ' ✓' or ''
                    _P('  ' .. name .. ' (' .. passive .. ')' .. has)
                end

            elseif sub == 'add' then
                local name = args[2]
                if not name then _P('[错误] 需要功法名称') return end
                local passive = GongFaByName[name]
                if not passive then _P('[错误] 未知功法: ' .. name .. '  用 !bx gongfa list 查看') return end
                Utils.AddPassive_Safe(target, passive)
                _P('[功法] 已添加 ' .. name)

            elseif sub == 'remove' then
                local name = args[2]
                if not name then _P('[错误] 需要功法名称') return end
                local passive = GongFaByName[name]
                if not passive then _P('[错误] 未知功法: ' .. name) return end
                if Osi.HasPassive(target, passive) == 1 then
                    Osi.RemovePassive(target, passive)
                end
                _P('[功法] 已移除 ' .. name)
            else
                _P('[错误] 未知子命令: gongfa ' .. tostring(sub))
            end

        elseif cmd == 'fabao' then
            local sub = args[1]
            if sub == 'add' then
                local idx = tonumber(args[2])
                if not idx or idx < 1 or idx > 6 then _P('[错误] 需要1-6') return end
                Utils.AddPassive_Safe(target, BaiMaiPassives[idx])
                _P('[法宝] 已添加百脉锻宝第' .. idx .. '阶')

            elseif sub == 'addall' then
                for i, passive in ipairs(BaiMaiPassives) do
                    Utils.AddPassive_Safe(target, passive)
                end
                _P('[法宝] 已添加全部百脉锻宝被动')

            elseif sub == 'remove' then
                local idx = tonumber(args[2])
                if not idx or idx < 1 or idx > 6 then _P('[错误] 需要1-6') return end
                if Osi.HasPassive(target, BaiMaiPassives[idx]) == 1 then
                    Osi.RemovePassive(target, BaiMaiPassives[idx])
                end
                _P('[法宝] 已移除百脉锻宝第' .. idx .. '阶')

            elseif sub == 'clear' then
                for _, passive in ipairs(BaiMaiPassives) do
                    if Osi.HasPassive(target, passive) == 1 then
                        Osi.RemovePassive(target, passive)
                    end
                end
                _P('[法宝] 已清除全部百脉锻宝被动')
            else
                _P('[错误] 未知子命令: fabao ' .. tostring(sub))
            end

        else
            _P('[错误] 未知命令: ' .. cmd .. '  用 !bx help 查看帮助')
        end
    end)

    _P('[谪仙] 调试指令已加载，输入 !bx help 查看帮助')
end

return Debug
