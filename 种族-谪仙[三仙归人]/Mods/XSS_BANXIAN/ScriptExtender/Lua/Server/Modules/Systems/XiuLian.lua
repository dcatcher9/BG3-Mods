local XiuLian = {
}
local LingGen = require("Server.Modules.Systems.LingGen")
local Variables = require("Server.Modules.Variables")
local Utils = require("Server.Modules.Utils")



-- 初始化修炼系统
function XiuLian.Init()

    -- 注册事件监听大道相关施法
    Ext.Osiris.RegisterListener("UsingSpell", 5, "after", XiuLian.OnUsingSpell_after)

    _P("[XiuLian] 修炼系统初始化完成！")

end

--吸收灵气
function XiuLian.Ki_Take(Object)
    --获取基础信息
    local Level = Osi.GetLevel(Object)
    local ConstitutionModifier = math.max(0,((Osi.GetAbility(Object, 'Constitution') - 10)/2))
    local WisdomModifier = math.max(0,((Osi.GetAbility(Object, 'Wisdom') - 10)/2))
    local TZ = Osi.GetStatusTurns(Object, 'BANXIAN_LG_TZ')

    --获取灵根
    local LG_H,LG_T,LG_J,LG_S,LG_M,_ = Utils.Get.LingGen(Object)
    local LG_TOTAL = LG_H + LG_T + LG_J + LG_S + LG_M

    if LG_TOTAL == 0 then return end  --灵根尚未觉醒，无法吸收灵气

    --计算灵气区间
    local p = 100/LG_TOTAL
    local CON_H = LG_H*p
    local CON_T = (LG_H + LG_T)*p
    local CON_J = (LG_H + LG_T + LG_J)*p
    local CON_S = (LG_H + LG_T + LG_J + LG_S)*p
    local CON_M = LG_TOTAL*p

    --获取灵气
    local LQ_H,LQ_T,LQ_J,LQ_S,LQ_M = Osi.GetStatusTurns(Object, 'BANXIAN_XIULIAN_LINGQI_H'),Osi.GetStatusTurns(Object, 'BANXIAN_XIULIAN_LINGQI_T'),Osi.GetStatusTurns(Object, 'BANXIAN_XIULIAN_LINGQI_J'),Osi.GetStatusTurns(Object, 'BANXIAN_XIULIAN_LINGQI_S'),Osi.GetStatusTurns(Object, 'BANXIAN_XIULIAN_LINGQI_M')
    local LQ_TOTAL = LQ_H + LQ_T + LQ_J + LQ_S + LQ_M
    local LQ_MAX = 10 + Level + ConstitutionModifier + TZ
    local LQ_AMOUNT = 10 + Level + WisdomModifier + TZ

    --灵气未储存满时，吸收灵气
    if LQ_TOTAL < LQ_MAX then
        local rest_LQ = LQ_MAX - LQ_TOTAL
        local rest = math.min(rest_LQ,LQ_AMOUNT)
        for i = 1, rest, 1 do
            local key = math.random(1,100)
            if key >= 1 and key < CON_H then
                Osi.ApplyStatus(Object,'BANXIAN_XIULIAN_LINGQI_H',6,1,Object)
            elseif key >= CON_H and key < CON_T then
                Osi.ApplyStatus(Object,'BANXIAN_XIULIAN_LINGQI_T',6,1,Object)
            elseif key >= CON_T and key < CON_J then
                Osi.ApplyStatus(Object,'BANXIAN_XIULIAN_LINGQI_J',6,1,Object)
            elseif key >= CON_J and key < CON_S then
                Osi.ApplyStatus(Object,'BANXIAN_XIULIAN_LINGQI_S',6,1,Object)
            elseif key >= CON_S and key < CON_M then
                Osi.ApplyStatus(Object,'BANXIAN_XIULIAN_LINGQI_M',6,1,Object)
            elseif key == 100  then
                Osi.ApplyStatus(Object,'BANXIAN_XIULIAN_LINGQI_JINGLIAN',6,1,Object) --1%概率吸收到精纯灵气
            else
                -- key falls in a gap caused by a zero-weight element; no action
            end
        end
    end

end









-- 事件·大道相关施法后
function XiuLian.OnUsingSpell_after(Caster, Spell)

    if Spell == 'Shout_XIULIAN_Ki_Take' then
        XiuLian.Ki_Take(Caster)
    end

end



return XiuLian