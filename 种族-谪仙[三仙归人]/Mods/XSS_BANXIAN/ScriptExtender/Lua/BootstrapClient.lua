-- Client-side: receive overhead text from server and update loca handle
Ext.RegisterNetListener("BanXian_OverheadText", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    if data and data.handle and data.text then
        Ext.Loca.UpdateTranslatedString(data.handle, data.text)
    end
end)

-- Client-side: track selected character and send to server
local lastSelectedChar = nil
Ext.Events.Tick:Subscribe(function()
    local selected = nil
    for _, entity in pairs(Ext.Entity.GetAllEntitiesWithComponent("ClientControl")) do
        if entity.Uuid then
            selected = tostring(entity.Uuid.EntityUuid)
            break
        end
    end
    if selected and selected ~= lastSelectedChar then
        lastSelectedChar = selected
        Ext.Net.PostMessageToServer('BanXian_SelectedChar', selected)
    end
end)
