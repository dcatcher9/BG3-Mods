local ShenShi = {}
local DaoHeng = require("Server.Modules.Systems.DaoHeng")
local LingGen = require("Server.Modules.Systems.LingGen")
local Utils = require("Server.Modules.Utils")
local Variables = require("Server.Modules.Variables")

local ScanDisplayQueue = 0

-- 初始化神识系统
function ShenShi.Init()
    Ext.Osiris.RegisterListener("StatusApplied", 4, "after", ShenShi.OnStatusApplied_after)

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

--事件·洞观扫描目标
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

    -- Build overhead message
    local overhead = jjName .. ' · ' .. lgText
    if zzText ~= '' then overhead = overhead .. ' ' .. zzText end
    if daoName then overhead = overhead .. ' · ' .. daoName end

    -- Send overhead text to client, then apply status with staggered timing
    ScanDisplayQueue = ScanDisplayQueue + 1
    local delay = (ScanDisplayQueue - 1) * 200
    local target = Object
    Ext.Timer.WaitFor(delay, function()
        Ext.Net.BroadcastMessage('BanXian_OverheadText', Ext.Json.Stringify({
            handle = 'stringsofmodmadebyxss20250312sc_disp',
            text = overhead
        }))
        Ext.Timer.WaitFor(50, function()
            Osi.ApplyStatus(target, 'BANXIAN_SCAN_DISPLAY', 30 * 6, 1, target)
            ScanDisplayQueue = math.max(0, ScanDisplayQueue - 1)
        end)
    end)
end

-- 事件·神识状态监听
function ShenShi.OnStatusApplied_after(Object, Status, Causee)

    if Status == "SIGNAL_SS_CHECK" then
        Utils.ShenShi.Check(Object)
    end

    if Status == "SIGNAL_SS_CHECK_TARGET" then
        ShenShi.OpenMessage(Object, Causee)
    end

    if Status == "SIGNAL_SS_SCAN_TARGET" then
        ShenShi.ScanTarget(Object, Causee)
    end

end

return ShenShi
