local EventHandlers = {}
local Variables = require("Server.Modules.Variables")
local Utils = require("Server.Modules.Utils")
local Systems

function EventHandlers.Init(systems)
    Systems = systems

    Ext.Osiris.RegisterListener("SavegameLoaded", 0, "after", EventHandlers.SavegameLoaded)
    Ext.Osiris.RegisterListener("StatusApplied", 4, "after", EventHandlers.OnStatusApplied)
    Ext.Osiris.RegisterListener("TimerFinished", 1, "after", EventHandlers.OnTimerFinished)
    Ext.Osiris.RegisterListener("LongRestFinished", 0, "after", EventHandlers.OnLongRestFinished)
    Ext.Osiris.RegisterListener("LeveledUp", 1, "after", EventHandlers.OnLeveledUp)
    Ext.Osiris.RegisterListener("CharacterJoinedParty", 1, "after", EventHandlers.OnCharacterJoinedParty)
    Ext.Osiris.RegisterListener("EnteredCombat", 2, "after", EventHandlers.OnEnteredCombat)
end

function EventHandlers.SavegameLoaded()
    Osi.TimerLaunch('XiuXian_Init', 3000)
end

function EventHandlers.OnStatusApplied(object, status, causee, _)
    if Variables.DEBUG_MODE then
        if status == 'XIUXIAN_DEBUG' then
            _D(Ext.Entity.Get(object):GetAllComponents())
        end
    end
end

function EventHandlers.OnCharacterJoinedParty(object)
    Utils.GrantXiuXian(object)
end

-- 进入战斗时授予被动（覆盖敌人）
function EventHandlers.OnEnteredCombat(object, combatGuid)
    Utils.GrantXiuXian(object)
end

-- 扫描队伍授予被动
function EventHandlers.ScanParty()
    for _, entity in pairs(Ext.Entity.GetAllEntitiesWithComponent("PartyMember")) do
        if entity.Uuid then
            local guid = tostring(entity.Uuid.EntityUuid)
            Utils.GrantXiuXian(guid)
        end
    end
end

function EventHandlers.OnTimerFinished(timer)
    if timer == "XiuXian_Init" then
        EventHandlers.ScanParty()
        _P("[修仙] 初始化完成")
    end
end

function EventHandlers.OnLongRestFinished()
    EventHandlers.ScanParty()
end

function EventHandlers.OnLeveledUp(object)
    Utils.GrantXiuXian(object)
end

return EventHandlers
