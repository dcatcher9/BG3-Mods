-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
--
--                              乐园币钱袋掉落随机金额
--
--乐园币（白色）
local LeYuanBi_BaiSe = { "BOOST_LeYuanBi5","BOOST_LeYuanBi15","BOOST_LeYuanB30", "BOOST_LeYuanBi50", "BOOST_LeYuanBi100", "BOOST_LeYuanBi150",
    "BOOST_LeYuanBi200", "BOOST_LeYuanBi300", }


--                              监听状态

Ext.Osiris.RegisterListener("StatusApplied", 4, "after", function(object, status, causee, storyActionID)
    --乐园币钱袋（白色）
    if status == "BaiSe_LeYuanBiQianDai" then
        local LeYuanBi_BaiSe_ID = LeYuanBi_BaiSe[Ext.Utils.Random(#LeYuanBi_BaiSe)]

        Osi.ApplyStatus(object, LeYuanBi_BaiSe_ID, 1, 0, object)
    end
end)
