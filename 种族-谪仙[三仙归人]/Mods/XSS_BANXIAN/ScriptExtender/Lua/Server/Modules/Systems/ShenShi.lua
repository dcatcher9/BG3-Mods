local ShenShi = {}
local DaoHeng = require("Server.Modules.Systems.DaoHeng")
local LingGen = require("Server.Modules.Systems.LingGen")
local Utils = require("Server.Modules.Utils")

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
    local name = Osi.GetDisplayName(Object) or "未知"
    local level = Osi.GetLevel(Object) or "??"
    local lines = { "【"..name.."】  Lv."..level }

    -- 境界
    local JJ = Utils.GetBanxianJingjie(Object)
    lines[#lines+1] = "[境界]: "..(JingJieNames[JJ] or '未知')

    -- 灵根资质
    local _, RESULT_ZZ = Utils.Get.ZiZhi(Object)
    local _, _, _, _, _, RESULT_LG = Utils.Get.LingGen(Object)
    lines[#lines+1] = RESULT_ZZ
    lines[#lines+1] = RESULT_LG

    -- 大道与修为
    local _, _, _, _, RESULT_DD = Utils.Get.Dao(Object)
    lines[#lines+1] = RESULT_DD

    -- 异火和掉落预报仅对非队友显示
    if Osi.IsAlly(Object, Causee) == 0 then
        local _, RESULT_YH = Utils.Get.YiHuo(Object)
        if RESULT_YH then
            lines[#lines+1] = RESULT_YH
        end

        local RESULT_DROP = Utils.Get.DropHint(Object)
        if RESULT_DROP then
            lines[#lines+1] = RESULT_DROP
        end
    end

    if #lines == 1 then
        lines[#lines+1] = "（未感知到特殊信息）"
    end

    Osi.OpenMessageBox(Causee, table.concat(lines, "\n"))
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
