-- Client-side: receive overhead text from server and update loca handle
Ext.RegisterNetListener("BanXian_OverheadText", function(channel, payload)
    local data = Ext.Json.Parse(payload)
    if data and data.handle and data.text then
        Ext.Loca.UpdateTranslatedString(data.handle, data.text)
    end
end)
