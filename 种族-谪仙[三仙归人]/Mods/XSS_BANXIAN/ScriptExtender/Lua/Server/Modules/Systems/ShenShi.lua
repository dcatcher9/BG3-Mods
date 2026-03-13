local ShenShi = {}
local DaoHeng = require("Server.Modules.Systems.DaoHeng")
local LingGen = require("Server.Modules.Systems.LingGen")
local Utils = require("Server.Modules.Utils")
local Variables = require("Server.Modules.Variables")

local SHENSHI_RESOURCE_UUID = '0032115b-77c3-43c8-9385-630e657b2fcc'
local SHENSHI_DC_MAX = 30

local removingControl = false
local dismissingCaster = {}

-- 清除掌日控制记录
local function ClearControlVars(caster, target)
    PersistentVars['ShenShi_Control_Caster_' .. caster] = nil
    PersistentVars['ShenShi_Control_Target_' .. target] = nil
end

-- 初始化神识系统
function ShenShi.Init()
    Ext.Osiris.RegisterListener("StatusApplied", 4, "after", ShenShi.OnStatusApplied_after)
    Ext.Osiris.RegisterListener("StatusRemoved", 4, "after", ShenShi.OnStatusRemoved_after)

    -- 创建动态SpellSaveDC状态（神识点数 → 法术DC加值）
    for i = 1, SHENSHI_DC_MAX do
        local name = 'BANXIAN_SHENSHI_DC_' .. i
        local ok, existing = pcall(Ext.Stats.Get, name)
        if not ok or not existing then
            local stat = Ext.Stats.Create(name, 'StatusData')
            stat.StatusType = 'BOOST'
            stat.StackId = 'BANXIAN_SHENSHI_DC'
            stat.StackType = 'Overwrite'
            stat.Boosts = 'SpellSaveDC(' .. i .. ')'
            stat.StatusPropertyFlags = {'DisableOverhead', 'DisableCombatlog', 'DisablePortraitIndicator', 'IgnoreResting', 'ApplyToDead'}
            Ext.Stats.Sync(name)
        end
    end
end

-- 更新神识DC加值（根据当前神识点数）
function ShenShi.UpdateDCBoost(Object)
    local amount = Utils.Get.ActionResource(Object, SHENSHI_RESOURCE_UUID)
    local oldAmount = PersistentVars['ShenShi_DC_' .. Object] or 0

    -- 移除旧状态
    if oldAmount > 0 then
        Osi.RemoveStatus(Object, 'BANXIAN_SHENSHI_DC_' .. oldAmount)
    end

    -- 应用新状态
    if amount > 0 then
        amount = math.min(amount, SHENSHI_DC_MAX)
        Osi.ApplyStatus(Object, 'BANXIAN_SHENSHI_DC_' .. amount, -1, 1, Object)
    end
    PersistentVars['ShenShi_DC_' .. Object] = amount
end

--事件·分身术内观
function ShenShi.OpenMessage(Object, Causee)
    if (Osi.GetStatusTurns(Object, 'BANXIAN_LG_TZ') or 0) == 0 then
        Osi.OpenMessageBox(Causee, "灵根尚未觉醒，请稍候片刻再行内观。")
        return
    end
    Utils.ShenShi.Check(Object)

    local JingJieNames = {'练气','筑基','结丹','元婴','化神','炼虚','合体','大乘','渡劫','真仙'}
    local JJ = Utils.GetBanxianJingjie(Object)
    local RESULT_JJ = "[境界]: "..(JingJieNames[JJ] or '未知')

    local ZZ,RESULT_ZZ = Utils.Get.ZiZhi(Object)
    local _,_,_,_,_,RESULT_LG = Utils.Get.LingGen(Object)
    DaoHeng.Check(Object)
    local _,_,_,_,RESULT_DD = Utils.Get.Dao(Object)

    local _, RESULT_YH = Utils.Get.YiHuo(Object)
    local Message = RESULT_JJ.."\n"..RESULT_ZZ.."\n"..RESULT_LG.."\n"..RESULT_DD
    if RESULT_YH then
        Message = Message.."\n"..RESULT_YH
    end

    Osi.OpenMessageBox(Causee, Message)

end

--事件·洞观扫描目标（收集结果，延迟合并显示）
function ShenShi.ScanTarget(Object, Causee)
    local JingJieNames = {'练气','筑基','结丹','元婴','化神','炼虚','合体','大乘','渡劫','真仙'}

    -- 境界
    local JJ = Utils.GetBanxianJingjie(Object)
    local jjName = JingJieNames[JJ] or '未知'

    -- 灵根
    local lgParts = {}
    for LG, NAME in pairs(Variables.Constants.LingGen) do
        local val = Osi.GetStatusTurns(Object, LG) or 0
        if val >= 1 then
            lgParts[#lgParts+1] = NAME .. val
        end
    end
    local lgText = #lgParts > 0 and table.concat(lgParts, ' ') or '无灵根'

    -- 资质
    local ZZ = Osi.GetStatusTurns(Object, 'BANXIAN_LG_TZ') or 0
    local zzText = ZZ > 0 and ('资质' .. ZZ) or ''

    -- 大道
    local daoName = nil
    for ID, NAME in pairs(Variables.Constants.DaDao) do
        if Osi.HasPassive(Object, ID) == 1 then
            daoName = NAME
            break
        end
    end

    -- Build scan line for this target
    local nameHandle = Osi.GetDisplayName(Object) or ''
    local resolvedName = Ext.Loca.GetTranslatedString(nameHandle) or nameHandle
    if resolvedName == '' then resolvedName = '???' end
    local line = resolvedName .. ': ' .. jjName .. ' · ' .. lgText
    if zzText ~= '' then line = line .. ' ' .. zzText end
    if daoName then line = line .. ' · ' .. daoName end

    _P('[ShenShi.ScanTarget] ' .. line) --DEBUG

    -- 更新loca用于头顶显示
    local handle = 'stringsofmodmadebyxss20250312sc_disp'
    Ext.Loca.UpdateTranslatedString(handle, line)
    Ext.Net.BroadcastMessage('BanXian_OverheadText', Ext.Json.Stringify({
        handle = handle,
        text = line
    }))

    -- 应用头顶显示状态
    Osi.ApplyStatus(Object, 'BANXIAN_SCAN_DISPLAY', 5 * 6, 1, Object)
end

-- 事件·神识状态监听
function ShenShi.OnStatusApplied_after(Object, Status, Causee)

    if Status == "SIGNAL_SS_CHECK" then
        Utils.ShenShi.Check(Object)
        ShenShi.UpdateDCBoost(Object)
    end

    if Status == "SIGNAL_SS_CHECK_TARGET" then
        ShenShi.OpenMessage(Object, Causee)
    end

    if Status == "SIGNAL_SS_SCAN_TARGET" then
        ShenShi.ScanTarget(Object, Causee)
    end

    -- 掌日：记录施法者↔傀儡配对 / 再次施放则解除
    if Status == "BANXIAN_SHENSHICONTROL_TARGET" then
        local existingCaster = PersistentVars['ShenShi_Control_Target_' .. Object]
        if existingCaster == Causee then
            -- 同一施法者对同一目标再次施放 → 解除控制
            dismissingCaster[Causee] = true
            removingControl = true
            Osi.RemoveStatus(Object, 'BANXIAN_SHENSHICONTROL_TARGET')
            Osi.RemoveStatus(Causee, 'BANXIAN_SHENSHICONTROL_CASTER')
            removingControl = false
            ClearControlVars(Causee, Object)
            Ext.Timer.WaitFor(100, function() dismissingCaster[Causee] = nil end)
            return
        end
        -- 新控制
        PersistentVars['ShenShi_Control_Caster_' .. Causee] = Object
        PersistentVars['ShenShi_Control_Target_' .. Object] = Causee
    end

    -- 掌日：解除中阻止SpellSuccess重新施加施法者状态
    if Status == "BANXIAN_SHENSHICONTROL_CASTER" and dismissingCaster[Object] then
        Osi.RemoveStatus(Object, 'BANXIAN_SHENSHICONTROL_CASTER')
        return
    end

end

-- 掌日：状态移除时清理配对
function ShenShi.OnStatusRemoved_after(Object, Status, Causee, StoryActionID)
    if removingControl then return end

    if Status == "BANXIAN_SHENSHICONTROL_CASTER" then
        local controlled = PersistentVars['ShenShi_Control_Caster_' .. Object]
        if controlled then
            removingControl = true
            Osi.RemoveStatus(controlled, 'BANXIAN_SHENSHICONTROL_TARGET')
            removingControl = false
            ClearControlVars(Object, controlled)
        end
    end

    if Status == "BANXIAN_SHENSHICONTROL_TARGET" then
        local caster = PersistentVars['ShenShi_Control_Target_' .. Object]
        if caster then
            removingControl = true
            Osi.RemoveStatus(caster, 'BANXIAN_SHENSHICONTROL_CASTER')
            removingControl = false
            ClearControlVars(caster, Object)
        end
    end
end

return ShenShi
