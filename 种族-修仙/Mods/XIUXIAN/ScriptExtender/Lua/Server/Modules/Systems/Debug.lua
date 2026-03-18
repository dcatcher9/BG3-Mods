local Debug = {}
local Variables = require("Server.Modules.Variables")
local Utils = require("Server.Modules.Utils")

function Debug.Init()
    -- 注册控制台命令
    Ext.RegisterConsoleCommand("xiuxian", function(cmd, subcmd, ...)
        local args = {...}

        if subcmd == "debug" then
            Variables.DEBUG_MODE = not Variables.DEBUG_MODE
            _P("[修仙] Debug mode: " .. tostring(Variables.DEBUG_MODE))

        elseif subcmd == "info" then
            -- 显示所有队伍成员的修仙状态
            local count = 0
            for _, entity in pairs(Ext.Entity.GetAllEntitiesWithComponent("PartyMember")) do
                if entity.Uuid then
                    local guid = tostring(entity.Uuid.EntityUuid)
                    local hasPassive = Osi.HasPassive(guid, 'XIUXIAN_Racial_Passive') == 1
                    count = count + 1
                    _P("[修仙] #" .. count .. ": " .. guid .. (hasPassive and " [已修仙]" or " [未修仙]"))
                end
            end
            if count == 0 then
                _P("[修仙] 无队伍成员")
            end

        elseif subcmd == "distance" then
            -- 测试五行距离: !xiuxian distance 木 火
            local from = args[1]
            local to = args[2]
            if from and to then
                local d = Utils.EdgeDistance(from, to)
                local name = Utils.GetEdgeEffectName(from, to)
                _P(from .. "→" .. to .. ": d=" .. tostring(d)
                    .. " (" .. (Variables.REACTION_NAMES[d] or "?") .. ")"
                    .. " 效果=" .. (name or "无"))
            end

        else
            _P("[修仙] 命令: !xiuxian debug | info | distance <元素> <元素>")
        end
    end)

    _P("[修仙] Debug module loaded. Use !xiuxian in console.")
end

return Debug
