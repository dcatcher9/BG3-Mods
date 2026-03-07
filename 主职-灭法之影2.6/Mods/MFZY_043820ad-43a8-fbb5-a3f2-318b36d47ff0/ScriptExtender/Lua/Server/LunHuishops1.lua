--///////////////////////////////////
--//                               //
--//       轮回乐园强化系统         //
--//                               //
--///////////////////////////////////


--武器强化


local WQ_QiangHua_1_5_YES = { "WQ_QiangHuaChengGong_1", }
local WQ_QiangHua_1_5_NO = { "WQ_QiangHuaShiBai_1", "WQ_QiangHuaShiBai_12", }
local WQ_QiangHua_1_5_PING = { "WQ_QiangHuaShiBai_1", "WQ_QiangHuaShiBai_12", }


local WQ_QiangHua_6_10_YES = { "WQ_QiangHuaChengGong_1", }
local WQ_QiangHua_6_10_NO = { "WQ_QiangHuaShiBai_1", "WQ_QiangHuaShiBai_3","WQ_QiangHuaShiBai_4","WQ_QiangHuaShiBai_5","WQ_QiangHuaShiBai_6","WQ_QiangHuaShiBai_12", }
local WQ_QiangHua_6_10_PING = { "WQ_QiangHuaShiBai_1", "WQ_QiangHuaShiBai_3","WQ_QiangHuaShiBai_4","WQ_QiangHuaShiBai_5","WQ_QiangHuaShiBai_6","WQ_QiangHuaShiBai_12", }

local WQ_QiangHua_11_15_YES = { "WQ_QiangHuaChengGong_1", }
local WQ_QiangHua_11_15_NO = {  "WQ_QiangHuaShiBai_3","WQ_QiangHuaShiBai_4","WQ_QiangHuaShiBai_5","WQ_QiangHuaShiBai_6","WQ_QiangHuaShiBai_7","WQ_QiangHuaShiBai_11", }
local WQ_QiangHua_11_15_PING = {  "WQ_QiangHuaShiBai_3","WQ_QiangHuaShiBai_4","WQ_QiangHuaShiBai_5","WQ_QiangHuaShiBai_6","WQ_QiangHuaShiBai_7","WQ_QiangHuaShiBai_11", }

local WQ_QiangHua_16_20_YES = { "WQ_QiangHuaChengGong_1", }
local WQ_QiangHua_16_20_NO = {"WQ_QiangHuaShiBai_1", "WQ_QiangHuaShiBai_3","WQ_QiangHuaShiBai_4", "WQ_QiangHuaShiBai_6","WQ_QiangHuaShiBai_7","WQ_QiangHuaShiBai_8","WQ_QiangHuaShiBai_9","WQ_QiangHuaShiBai_10","WQ_QiangHuaShiBai_11", }
local WQ_QiangHua_16_20_PING = { "WQ_QiangHuaShiBai_1", "WQ_QiangHuaShiBai_3","WQ_QiangHuaShiBai_4","WQ_QiangHuaShiBai_6","WQ_QiangHuaShiBai_7","WQ_QiangHuaShiBai_8","WQ_QiangHuaShiBai_9","WQ_QiangHuaShiBai_10","WQ_QiangHuaShiBai_11", }

Ext.Osiris.RegisterListener("StatusApplied", 4, "after", function(object, status, causee, storyActionID)
    --强化等级1-5时
    if status == "WQ_QiangHua_1_5" then
        local QH1_5_YES = 60
        local QH1_5_NO = 40
        local Roll = Random(100)

        --成功
        if Roll <= QH1_5_YES then
            QaingHua_ID = WQ_QiangHua_1_5_YES[Ext.Utils.Random(#WQ_QiangHua_1_5_YES)]
        --失败
        elseif Roll <= 80 then
            QaingHua_ID = WQ_QiangHua_1_5_NO[Ext.Utils.Random(#WQ_QiangHua_1_5_NO)]
        else
            QaingHua_ID = WQ_QiangHua_1_5_PING[Ext.Utils.Random(#WQ_QiangHua_1_5_PING)]
        end
        Osi.ApplyStatus(object, QaingHua_ID, 1, 0, object)
    end
  
    --强化等级6-10时
    if status == "WQ_QiangHua_6_10" then
        local QH6_10_YES = 40
        local QH6_10_NO = 60
        local Roll = Random(100)

        --成功
        if Roll <= QH6_10_YES then
            QaingHua_ID = WQ_QiangHua_6_10_YES[Ext.Utils.Random(#WQ_QiangHua_6_10_YES)]
        --失败
        elseif Roll <= QH6_10_NO then
            QaingHua_ID = WQ_QiangHua_6_10_NO[Ext.Utils.Random(#WQ_QiangHua_6_10_NO)]
        else
            QaingHua_ID = WQ_QiangHua_6_10_PING[Ext.Utils.Random(#WQ_QiangHua_6_10_PING)]
        end
        Osi.ApplyStatus(object, QaingHua_ID, 1, 0, object)
    end
    
    --强化等级11-15时
    if status == "WQ_QiangHua_11_15" then
        local QH11_15_YES = 15
        local QH11_15_NO = 85
        local Roll = Random(100)

        --成功
        if Roll <= QH11_15_YES then
            QaingHua_ID = WQ_QiangHua_11_15_YES[Ext.Utils.Random(#WQ_QiangHua_11_15_YES)]
        --失败
        elseif Roll <= QH11_15_NO then
            QaingHua_ID = WQ_QiangHua_11_15_NO[Ext.Utils.Random(#WQ_QiangHua_11_15_NO)]
        else
            QaingHua_ID = WQ_QiangHua_11_15_PING[Ext.Utils.Random(#WQ_QiangHua_11_15_PING)]
        end
        Osi.ApplyStatus(object, QaingHua_ID, 1, 0, object)
    end
  
    --强化等级15-20时
    if status == "WQ_QiangHua_16_20" then
        local QH16_20_YES = 5
        local QH16_20_NO = 95
        local Roll = Random(100)

        --成功
        if Roll <= QH16_20_YES then
            QaingHua_ID = WQ_QiangHua_16_20_YES[Ext.Utils.Random(#WQ_QiangHua_16_20_YES)]
        --失败
        elseif Roll <= QH16_20_NO then
            QaingHua_ID = WQ_QiangHua_16_20_NO[Ext.Utils.Random(#WQ_QiangHua_16_20_NO)]
        else
            QaingHua_ID = WQ_QiangHua_16_20_PING[Ext.Utils.Random(#WQ_QiangHua_16_20_PING)]
        end
        Osi.ApplyStatus(object, QaingHua_ID, 1, 0, object)
    end





    
end)
