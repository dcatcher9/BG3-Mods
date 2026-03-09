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

    local ZZ,RESULT_ZZ = Utils.Get.ZiZhi(Object)
    local _,_,_,_,_,RESULT_LG = Utils.Get.LingGen(Object)
    DaoHeng.Check(Object)
    local _,_,_,_,RESULT_DD = Utils.Get.Dao(Object)

    local Message = RESULT_ZZ.."\n"..RESULT_LG.."\n"..RESULT_DD

    Osi.OpenMessageBox(Causee, Message)
    LingGen.ApplyAllChecks(Object)

end




--事件·洞观扫描目标
function ShenShi.ScanTarget(Object, Causee)
    local name = Osi.GetDisplayName(Object)
    local level = Osi.GetLevel(Object)
    local lines = { "【"..name.."】  Lv."..level }

    -- 境界标签
    if Osi.HasActiveStatus(Object, 'BANXIAN_TAG_TIANXIAN') == 1 then
        lines[#lines+1] = "[境界]: 天仙"
    elseif Osi.HasActiveStatus(Object, 'BANXIAN_TAG_RENXIAN') == 1 then
        lines[#lines+1] = "[境界]: 人仙"
    end

    -- 灵根资质
    local ZZ = Osi.GetStatusTurns(Object, 'BANXIAN_LG_TZ')
    if ZZ and ZZ > 0 then
        local _, RESULT_ZZ = Utils.Get.ZiZhi(Object)
        local _, _, _, _, _, RESULT_LG = Utils.Get.LingGen(Object)
        lines[#lines+1] = RESULT_ZZ
        lines[#lines+1] = RESULT_LG
    end

    -- 大道与修为
    local _, _, DH_YEAR, DH_DAY, RESULT_DD = Utils.Get.Dao(Object)
    if DH_YEAR ~= 0 or DH_DAY ~= 0 then
        lines[#lines+1] = RESULT_DD
    end

    -- 异火
    local _, RESULT_YH = Utils.Get.YiHuo(Object)
    if RESULT_YH then
        lines[#lines+1] = RESULT_YH
    end

    -- 掉落预报
    local RESULT_DROP = Utils.Get.DropHint(Object)
    if RESULT_DROP then
        lines[#lines+1] = RESULT_DROP
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
