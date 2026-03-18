local XiuXian = {
    Modules = {
        Systems = {}
    }
}

function XiuXian.Init()

    -- 加载并初始化各个子系统
    XiuXian.Modules.Systems = {
        LingGen = require("Server.Modules.Systems.LingGen"),
        DanTian = require("Server.Modules.Systems.DanTian"),
        JingMai = require("Server.Modules.Systems.JingMai"),
        Debug = require("Server.Modules.Systems.Debug")
    }

    XiuXian.Modules.Systems.LingGen.Init()
    XiuXian.Modules.Systems.DanTian.Init()
    XiuXian.Modules.Systems.JingMai.Init()
    XiuXian.Modules.Systems.Debug.Init()

    -- 注入系统引用到 Utils，供 Osiris 回调使用
    local Utils = require("Server.Modules.Utils")
    Utils._Systems = XiuXian.Modules.Systems

    -- 初始化事件处理器
    local EventHandlers = require("Server.Modules.EventHandlers")
    EventHandlers.Init(XiuXian.Modules.Systems)

end

XiuXian.Init()
return XiuXian
