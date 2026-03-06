local ShenShi = {}
local DaoHeng = require("Server.Modules.Systems.DaoHeng")
local LingGen = require("Server.Modules.Systems.LingGen")
local Utils = require("Server.Modules.Utils")

-- 初始化神识系统
function ShenShi.Init()
    Ext.Osiris.RegisterListener("StatusApplied", 4, "after", ShenShi.OnStatusApplied_after)

    _P("[ShenShi] 神识系统初始化完成！")
end

--事件·分身术内观
function ShenShi.OpenMessage(Object, Causee)
    if (Osi.GetStatusTurns(Object, 'BANXIAN_LG_TZ') or 0) == 0 then
        Osi.OpenMessageBox(Causee, "灵根尚未觉醒，请稍候片刻再行内观。")
        return
    end
    Utils.ShenShi.Check(Object)

    local ZZ,RESULT_ZZ = Utils.Get.ZiZhi(Object)
    local LG_H,LG_T,LG_J,LG_S,LG_M,RESULT_LG = Utils.Get.LingGen(Object)
    DaoHeng.Check(Object)
    local DaDAO,DaDao_Name,DH_YEAR,DH_DAY,DaoHen,DaoHen_Name,DaoHen_Year,RESULT_DD = Utils.Get.Dao(Object)

    local Message = RESULT_ZZ.."\n"..RESULT_LG.."\n"..RESULT_DD

    Osi.OpenMessageBox(Causee, Message)
    LingGen.ApplyAllChecks(Object)

end




-- 事件·神识状态监听
function ShenShi.OnStatusApplied_after(Object, Status, Causee)

    if Status == "SIGNAL_SS_CHECK" then
        Utils.ShenShi.Check(Object)
    end

    if Status == "SIGNAL_SS_CHECK_TARGET" then
        ShenShi.OpenMessage(Object, Causee)
    end

end



return ShenShi
