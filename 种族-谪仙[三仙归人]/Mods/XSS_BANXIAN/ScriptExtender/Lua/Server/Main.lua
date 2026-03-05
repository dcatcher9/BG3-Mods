local BanXian = {
    Modules = {
        Systems = {}
    }
}

function BanXian.Init()
    _P("[BanXian] 初始化 BanXian 模块...")

    -- 加载并初始化各个子系统
    BanXian.Modules.Systems = {
        LingGen = require("Server.Modules.Systems.LingGen"),
        DaoHeng = require("Server.Modules.Systems.DaoHeng"),
        ZhenFa = require("Server.Modules.Systems.ZhenFa"),
        ShenShi = require("Server.Modules.Systems.ShenShi"),
        GongFa = require("Server.Modules.Systems.GongFa"),
        DanYao = require("Server.Modules.Systems.DanYao"),
        Difficulty = require("Server.Modules.Systems.Difficulty"),
        XiuLian = require("Server.Modules.Systems.XiuLian"),
        FaBao = require("Server.Modules.Systems.FaBao"),
        Base = require("Server.Modules.Systems.Base")
    }

    BanXian.Modules.Systems.LingGen.Init()
    BanXian.Modules.Systems.DaoHeng.Init()
    BanXian.Modules.Systems.ZhenFa.Init()
    BanXian.Modules.Systems.ShenShi.Init()
    BanXian.Modules.Systems.GongFa.Init()
    BanXian.Modules.Systems.DanYao.Init()
    BanXian.Modules.Systems.Difficulty.Init()
    BanXian.Modules.Systems.XiuLian.Init()
    BanXian.Modules.Systems.FaBao.Init()
    BanXian.Modules.Systems.Base.Init()

    -- 初始化事件处理器
    local EventHandlers = require("Server.Modules.EventHandlers")
    EventHandlers.Init()

    _P("[BanXian] BanXian 模块初始化完成！")
    
end



BanXian.Init()
return BanXian
