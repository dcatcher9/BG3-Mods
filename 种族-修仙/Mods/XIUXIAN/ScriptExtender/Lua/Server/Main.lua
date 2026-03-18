local XiuXian = {
    Modules = {
        Systems = {}
    }
}

function XiuXian.Init()

    -- 加载并初始化各个子系统
    XiuXian.Modules.Systems = {
        Debug = require("Server.Modules.Systems.Debug")
    }

    XiuXian.Modules.Systems.Debug.Init()

    -- 初始化事件处理器
    local EventHandlers = require("Server.Modules.EventHandlers")
    EventHandlers.Init(XiuXian.Modules.Systems)

end

XiuXian.Init()
return XiuXian
