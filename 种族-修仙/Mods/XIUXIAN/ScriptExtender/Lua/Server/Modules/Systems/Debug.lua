local Debug = {}
local Variables = require("Server.Modules.Variables")
local Utils = require("Server.Modules.Utils")
local LingGen = require("Server.Modules.Systems.LingGen")
local DanTian = require("Server.Modules.Systems.DanTian")
local JingMai = require("Server.Modules.Systems.JingMai")

-- 获取角色显示名（优先用名字，没有则用GUID）
local function GetDisplayName(guid)
    local entity = Ext.Entity.Get(guid)
    if entity and entity.DisplayName and entity.DisplayName.NameKey then
        local name = Ext.Loca.GetTranslatedString(entity.DisplayName.NameKey.Handle.Handle)
        if name and name ~= "" then return name end
    end
    return tostring(guid)
end

-- 获取阵营标签：友/敌/中
local function GetFactionTag(guid)
    local host = Osi.GetHostCharacter()
    if not host then return "[?]" end
    if Osi.IsAlly(guid, host) == 1 then return "[友]" end
    if Osi.IsEnemy(guid, host) == 1 then return "[敌]" end
    return "[中]"
end

function Debug.Init()
    Ext.RegisterConsoleCommand("xx", function(cmd, subcmd, ...)
        local args = {...}

        if subcmd == "debug" then
            Variables.DEBUG_MODE = not Variables.DEBUG_MODE
            _P("[修仙] Debug mode: " .. tostring(Variables.DEBUG_MODE))

        elseif subcmd == "info" then
            local count = 0
            for _, entity in pairs(Ext.Entity.GetAllEntitiesWithComponent("PartyMember")) do
                if entity.Uuid then
                    local guid = tostring(entity.Uuid.EntityUuid)
                    local hasPassive = Osi.HasPassive(guid, 'XIUXIAN_Racial_Passive') == 1
                    count = count + 1
                    _P("[修仙] #" .. count .. ": " .. GetDisplayName(guid) .. (hasPassive and " [已修仙]" or " [未修仙]"))
                end
            end
            if count == 0 then
                _P("[修仙] 无队伍成员")
            end

        elseif subcmd == "distance" then
            local from = args[1]
            local to = args[2]
            if from and to then
                local d = Utils.EdgeDistance(from, to)
                local name = Utils.GetEdgeEffectName(from, to)
                _P(from .. "→" .. to .. ": d=" .. tostring(d)
                    .. " (" .. (Variables.REACTION_NAMES[d] or "?") .. ")"
                    .. " 效果=" .. (name or "无"))
            end

        elseif subcmd == "linggen" then
            for _, entity in pairs(Ext.Entity.GetAllEntitiesWithComponent("PartyMember")) do
                if entity.Uuid then
                    local guid = tostring(entity.Uuid.EntityUuid)
                    _P("[修仙] " .. GetDisplayName(guid))
                    LingGen.PrintInfo(guid)
                end
            end

        elseif subcmd == "scan" then
            local count = 0
            for _, entity in pairs(Ext.Entity.GetAllEntitiesWithComponent("Health")) do
                if entity.Uuid then
                    local guid = tostring(entity.Uuid.EntityUuid)
                    if Osi.HasPassive(guid, 'XIUXIAN_Racial_Passive') == 1 then
                        local total = LingGen.GetTotal(guid)
                        if total > 0 then
                            count = count + 1
                            _P("[修仙] " .. GetFactionTag(guid) .. " " .. GetDisplayName(guid))
                            LingGen.PrintInfo(guid)
                        end
                    end
                end
            end
            if count == 0 then
                _P("[修仙] 未找到有灵根的角色（敌人需先进入战斗触发）")
            end

        elseif subcmd == "setlg" then
            local elem = args[1]
            local value = tonumber(args[2])
            if elem and value then
                local host = Osi.GetHostCharacter()
                LingGen.Set(host, elem, value)
                _P("[修仙] " .. GetDisplayName(host) .. " 设置 " .. elem .. " 灵根 = " .. value)
                LingGen.PrintInfo(host)
            else
                _P("[修仙] 用法: !xx setlg <元素> <值>")
            end

        elseif subcmd == "dantian" then
            for _, entity in pairs(Ext.Entity.GetAllEntitiesWithComponent("PartyMember")) do
                if entity.Uuid then
                    local guid = tostring(entity.Uuid.EntityUuid)
                    _P("[修仙] " .. GetDisplayName(guid))
                    DanTian.PrintInfo(guid)
                end
            end

        elseif subcmd == "setdt" then
            local field = args[1]  -- "qi" or "ss"
            local value = tonumber(args[2])
            if field and value then
                local host = Osi.GetHostCharacter()
                if field == "qi" then
                    DanTian.SetQiMax(host, value)
                    DanTian.SyncResources(host)
                    _P("[修仙] " .. GetDisplayName(host) .. " 丹田=" .. value)
                elseif field == "ss" then
                    DanTian.SetShenshiMax(host, value)
                    DanTian.SyncResources(host)
                    _P("[修仙] " .. GetDisplayName(host) .. " 识海=" .. value)
                else
                    _P("[修仙] 用法: !xx setdt qi|ss <值>")
                end
            else
                _P("[修仙] 用法: !xx setdt qi|ss <值>")
            end

        elseif subcmd == "jingmai" then
            local host = Osi.GetHostCharacter()
            _P("[修仙] " .. GetDisplayName(host))
            JingMai.PrintInfo(host)

        elseif subcmd == "open" then
            local elemA = args[1]
            local elemB = args[2]
            if elemA and elemB then
                local host = Osi.GetHostCharacter()
                if JingMai.IsOpen(host, elemA, elemB) then
                    _P("[修仙] 经脉 " .. elemA .. "─" .. elemB .. " 已开通")
                elseif JingMai.Open(host, elemA, elemB) then
                    _P("[修仙] " .. GetDisplayName(host) .. " 开通 " .. elemA .. "─" .. elemB)
                else
                    _P("[修仙] 开脉失败")
                end
                JingMai.PrintInfo(host)
            else
                _P("[修仙] 用法: !xx open <元素A> <元素B>")
            end

        elseif subcmd == "close" then
            local elemA = args[1]
            local elemB = args[2]
            if elemA and elemB then
                local host = Osi.GetHostCharacter()
                JingMai.Close(host, elemA, elemB)
                _P("[修仙] " .. GetDisplayName(host) .. " 关闭 " .. elemA .. "─" .. elemB)
                JingMai.PrintInfo(host)
            else
                _P("[修仙] 用法: !xx close <元素A> <元素B>")
            end

        else
            _P("[修仙] 命令: !xx debug|info|distance|linggen|scan|setlg|dantian|setdt|jingmai|open|close")
        end
    end)

    _P("[修仙] Debug loaded. Use !xx in console.")
end

return Debug
