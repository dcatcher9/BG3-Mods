--///////////////////////////////////
--//                               //
--//       轮回乐园商店系统         //
--//                               //
--///////////////////////////////////


--///////////////////////////////////
--//                               //
--//         万能锻造屋             //
--//                               //
--///////////////////////////////////

--新手法师头,XS_FS_T_BOOST
local XS_FS_T = { "05892883-71c2-4b9f-8279-24bfc039ea51", }
--新手法师披风
local XS_FS_PF = { "46831dad-d7c4-40ae-b4f5-05f043e2c4cb", }
--新手法师胸甲
local XS_FS_XJ = { "b206e55b-ae6f-49e1-b8f1-203a2649f7aa", }
--新手法师手套
local XS_FS_ST = { "5565df49-ed18-43b7-b47d-2462b02152e8", }
--新手法师靴子
local XS_FS_XZ = { "fc774a01-b3aa-4ee7-a3a8-88538de80d72", }
--新手法杖
local XS_FS_FZ = { "28ab2aca-0e5e-442a-86ee-85078041d1ea", }

--监听状态
Ext.Osiris.RegisterListener("StatusRemoved", 4, "after", function(object, status, causee, applyStoryActionID)
    --新手法师头
    if status == "XS_FS_T_BOOST" then
        XS_FS_T_ID = XS_FS_T[Ext.Utils.Random(#XS_FS_T)]
        Osi.TemplateAddTo(XS_FS_T_ID, object, 1, 1)
    end
    --新手法师披风
    if status == "XS_FS_PF_BOOST" then
        XS_FS_PF_ID = XS_FS_PF[Ext.Utils.Random(#XS_FS_PF)]
        Osi.TemplateAddTo(XS_FS_PF_ID, object, 1, 1)
    end
    --新手法师胸甲
    if status == "XS_FS_XJ_BOOST" then
        XS_FS_XJ_ID = XS_FS_XJ[Ext.Utils.Random(#XS_FS_XJ)]
        Osi.TemplateAddTo(XS_FS_XJ_ID, object, 1, 1)
    end
    --新手法师手套
    if status == "XS_FS_ST_BOOST" then
        XS_FS_ST_ID = XS_FS_ST[Ext.Utils.Random(#XS_FS_ST)]
        Osi.TemplateAddTo(XS_FS_ST_ID, object, 1, 1)
    end
    --新手法师靴子
    if status == "XS_FS_XZ_BOOST" then
        XS_FS_XZ_ID = XS_FS_XZ[Ext.Utils.Random(#XS_FS_XZ)]
        Osi.TemplateAddTo(XS_FS_XZ_ID, object, 1, 1)
    end
    --新手法杖
    if status == "XS_FS_WQ_BOOST" then
        XS_FS_FZ_ID = XS_FS_FZ[Ext.Utils.Random(#XS_FS_FZ)]
        Osi.TemplateAddTo(XS_FS_FZ_ID, object, 1, 1)
    end
end)

--////////////////////////////////////
--//                                //
--//           宝石商店             //
--//                               //
--///////////////////////////////////
--
--低级力量宝石
local WQ_BS_DJLL = { "a9cd4708-2ad4-40de-a485-c6eb6841ffad", }
--低级敏捷宝石
local WQ_BS_DJMJ = { "2ff013d8-765c-4713-aaf4-5ea6917ef5c7", }
--低级体质宝石
local WQ_BS_DJTZ = { "9847a8f8-3d96-44eb-9fc7-1ec3bacd5ff2", }
--低级智力宝石
local WQ_BS_DJZL = { "94a78f33-6bc3-487d-9dca-a60f4d878527", }
--低级感知宝石
local WQ_BS_DJGZ = { "e5e967ec-8eac-4c43-80e5-603a76cda11c", }
--低级魅力宝石
local WQ_BS_DJML = { "09a741e2-4a9a-4900-9f74-df267c44829b", }
--宝石拆除工具绿色（武器）
local WQ_GJ_CC_LS = { "b428a5ad-c51f-42a7-a329-624f512b8395", }


Ext.Osiris.RegisterListener("StatusRemoved", 4, "after", function(object, status, causee, applyStoryActionID)
    --低级力量宝石
    if status == "WQ_BS_DJLL_BOOST" then
        WQ_BS_DJLL_ID = WQ_BS_DJLL[Ext.Utils.Random(#WQ_BS_DJLL)]
        Osi.TemplateAddTo(WQ_BS_DJLL_ID, object, 1, 1)
    end
    --低级敏捷宝石
    if status == "WQ_BS_DJMJ_BOOST" then
        WQ_BS_DJMJ_ID = WQ_BS_DJMJ[Ext.Utils.Random(#WQ_BS_DJMJ)]
        Osi.TemplateAddTo(WQ_BS_DJMJ_ID, object, 1, 1)
    end
    --低级体质宝石
    if status == "WQ_BS_DJTZ_BOOST" then
        WQ_BS_DJTZ_ID = WQ_BS_DJTZ[Ext.Utils.Random(#WQ_BS_DJTZ)]
        Osi.TemplateAddTo(WQ_BS_DJTZ_ID, object, 1, 1)
    end
    --低级智力宝石
    if status == "WQ_BS_DJZL_BOOST" then
        WQ_BS_DJZL_ID = WQ_BS_DJZL[Ext.Utils.Random(#WQ_BS_DJZL)]
        Osi.TemplateAddTo(WQ_BS_DJZL_ID, object, 1, 1)
    end
    --低级感知宝石
    if status == "WQ_BS_DJGZ_BOOST" then
        WQ_BS_DJGZ_ID = WQ_BS_DJGZ[Ext.Utils.Random(#WQ_BS_DJGZ)]
        Osi.TemplateAddTo(WQ_BS_DJGZ_ID, object, 1, 1)
    end
    --低级魅力宝石
    if status == "WQ_BS_DJML_BOOST" then
        WQ_BS_DJML_ID = WQ_BS_DJML[Ext.Utils.Random(#WQ_BS_DJML)]
        Osi.TemplateAddTo(WQ_BS_DJML_ID, object, 1, 1)
    end
    --宝石拆除工具绿色（武器）
    if status == "WQ_GJ_CC_LS_BOOST" then
        WQ_GJ_CC_LS_ID = WQ_GJ_CC_LS[Ext.Utils.Random(#WQ_GJ_CC_LS)]
        Osi.TemplateAddTo(WQ_GJ_CC_LS_ID, object, 1, 1)
    end
end)


--////////////////////////////////////
--//                                //
--//           职工商店             //
--//                               //
--///////////////////////////////////
--
--黄金炒饭
local ZG_HF_HJCF = { "41c2f574-1fb4-47d9-bf4d-69dfb997375a", }
--益达口香糖
local ZG_HF_YDKXT = { "4d1b61a0-58e2-4268-beb0-412855588ffe", }
Ext.Osiris.RegisterListener("StatusRemoved", 4, "after", function(object, status, causee, applyStoryActionID)
    --黄金炒饭
    if status == "HF_HuangJinChaoFan_BOOST" then
        ZG_HF_WPID = ZG_HF_HJCF[Ext.Utils.Random(#ZG_HF_HJCF)]
        Osi.TemplateAddTo(ZG_HF_WPID, object, 1, 1)
    end

    --益达口香糖
    if status == "HF_YiDaKouXiangTang_BOOST" then
        ZG_HF_WPID = ZG_HF_YDKXT[Ext.Utils.Random(#ZG_HF_YDKXT)]
        Osi.TemplateAddTo(ZG_HF_WPID, object, 1, 1)
    end
end)


--///////////////////////////////////
--//                               //
--//         装备强化机             //
--//                               //
--///////////////////////////////////

--普通强化石
local QH_OT_QiangHuaShi = { "fe2d9e27-0a73-4364-bf16-7d14b5ab27e6", }
Ext.Osiris.RegisterListener("StatusRemoved", 4, "after", function(object, status, causee, applyStoryActionID)
    --普通强化石X1
    if status == "WQ_PT_QaingHuaShi_1" then
        QH_OT_QiangHuaShi_ID = QH_OT_QiangHuaShi[Ext.Utils.Random(#QH_OT_QiangHuaShi)]
        Osi.TemplateAddTo(QH_OT_QiangHuaShi_ID, object, 1, 1)
    end
    --普通强化石X10
    if status == "WQ_PT_QaingHuaShi_10" then
        QH_OT_QiangHuaShi_ID = QH_OT_QiangHuaShi[Ext.Utils.Random(#QH_OT_QiangHuaShi)]
        Osi.TemplateAddTo(QH_OT_QiangHuaShi_ID, object, 10, 1)
    end
    --普通强化石X100
    if status == "WQ_PT_QaingHuaShi_100" then
        QH_OT_QiangHuaShi_ID = QH_OT_QiangHuaShi[Ext.Utils.Random(#QH_OT_QiangHuaShi)]
        Osi.TemplateAddTo(QH_OT_QiangHuaShi_ID, object, 100, 1)
    end
end)

--///////////////////////////////////
--//                               //
--//            黑市               //
--//                               //
--///////////////////////////////////

--灵魂结晶（小）
local CL_LingHunJieJing_Xiao = { "8775cab3-da03-4e5e-a93c-7fdbfe720ef6", }
--灵魂结晶（中）
local CL_LingHunJieJing_Zhong = { "8c7e488d-ad50-4d89-af2d-e9d48523e274", }
--灵魂结晶（大）
local CL_LingHunJieJing_Da = { "b9b0885c-e7f8-4ea9-b312-82b19360ee1f", }
--灵魂结晶（完整）
local CL_LingHunJieJing_WanZheng = { "026b2899-a283-4672-8961-c26131fa67ce", }
--灵魂晶核
local CL_LingHunJingHe = { "7f4c5c78-098e-4777-a123-bada34186102", }
--灵魂精魄
local CL_LingHunJingPo = { "d6d4d134-9179-47fd-87ce-8471eef4a2d9", }

Ext.Osiris.RegisterListener("StatusRemoved", 4, "after", function(object, status, causee, applyStoryActionID)
    --灵魂结晶（小）
    if status == "CL_LingHunJieJing_Xiao_BOOST" then
        CL_LingHunJieJing_Xiao_ID = CL_LingHunJieJing_Xiao[Ext.Utils.Random(#CL_LingHunJieJing_Xiao)]
        Osi.TemplateAddTo(CL_LingHunJieJing_Xiao_ID, object, 1, 1)
    end
    --灵魂结晶（中）
    if status == "CL_LingHunJieJing_Zhong_BOOST" then
        CL_LingHunJieJing_Zhong_ID = CL_LingHunJieJing_Zhong[Ext.Utils.Random(#CL_LingHunJieJing_Zhong)]
        Osi.TemplateAddTo(CL_LingHunJieJing_Zhong_ID, object, 1, 1)
    end
    --灵魂结晶（大）
    if status == "CL_LingHunJieJing_Da_BOOST" then
        CL_LingHunJieJing_Da_ID = CL_LingHunJieJing_Da[Ext.Utils.Random(#CL_LingHunJieJing_Da)]
        Osi.TemplateAddTo(CL_LingHunJieJing_Da_ID, object, 1, 1)
    end
    --灵魂结晶（完整）
    if status == "CL_LingHunJieJing_WanZheng_BOOST" then
        CL_LingHunJieJing_WanZheng_ID = CL_LingHunJieJing_WanZheng[Ext.Utils.Random(#CL_LingHunJieJing_WanZheng)]
        Osi.TemplateAddTo(CL_LingHunJieJing_WanZheng_ID, object, 1, 1)
    end
    --灵魂晶核
    if status == "CL_LingHunJingHe_BOOST" then
        CL_LingHunJingHe_ID = CL_LingHunJingHe[Ext.Utils.Random(#CL_LingHunJingHe)]
        Osi.TemplateAddTo(CL_LingHunJingHe_ID, object, 1, 1)
    end
    --灵魂精魄
    if status == "CL_LingHunJingPo_BOOST" then
        CL_LingHunJingPo_ID = CL_LingHunJingPo[Ext.Utils.Random(#CL_LingHunJingPo)]
        Osi.TemplateAddTo(CL_LingHunJingPo_ID, object, 1, 1)
    end
end)
