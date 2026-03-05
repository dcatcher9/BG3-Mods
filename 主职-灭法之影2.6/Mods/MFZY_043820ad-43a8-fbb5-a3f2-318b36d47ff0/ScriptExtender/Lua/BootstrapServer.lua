--Ext.Require("Server/Dotashops.lua")
--Ext.Require("Server/Dotashopszhongli.lua")
Ext.Require("Server/LunHuishops.lua")
Ext.Require("Server/LunHuishops1.lua")
Ext.Require("Server/LunHuishops2.lua")

local LunHui_WuPin_ID = nil
local DugouPool = {}
local LiBaoPool = {}
local waiting_SoulFire = {}
local SFx, SFy, SFz = nil
local PersistentVars_SoulFire = {}
local Meteor_SlashX, Meteor_SlashY, Meteor_SlashZ = nil


--开箱脚本


--垃圾
LunHui_WuPin_LaJi = { "34df8770-06c5-4752-a7b6-25d4f64d64dc", "1849ce97-45ac-43ea-9518-9f80aaa0c005",
    "63400c5f-cc10-4009-8d8f-b01dbb47060a", "75808952-29b8-4840-81e1-fcdd93155ddd",
    "440f4817-5d30-4867-a982-5b8094ace403", "07f03f85-7eba-4f4e-ab8f-e51979a45ce7",
    "d9b9ce80-5ed0-44f1-8494-6f835f9b2859", "4b7c07ef-1f95-478d-859f-32f1ad98687b",
    "8c17a2e5-e742-4fac-a0d6-10289be28c72", "7d9a414b-2b5a-4672-87c5-65dd8cebe598",
    "de2bb388-5863-4504-95aa-dd694f11f1a6", "d8356714-c76c-4fb3-a556-da69b6ed43bd",
    "18303ee3-884d-41ed-8bf9-3a1742f27a75", "e028bac5-f393-4d6a-9873-670241d721ac",
    "231afb29-b79c-4efd-af23-2e433dea313d", "876c66a6-018c-48fe-8406-d90561d3db23",
    "c2a14b56-9dca-4ad1-bcea-71204365f6a9", "25c73ac0-8be2-4781-b5cf-f644ef94e40e",
    "158682d3-4b6a-4952-aa88-af74a256f880", "66ee4e64-a517-4570-8c37-dd7b42cab6ee",
    "2add6f00-eb1c-4f86-bf7f-73e2c68ad5de", "31d47753-7713-461f-a65b-da4339939cf2",
    "5d1731b3-1fd3-48db-bf48-eb5e57b4c1c9", "9ab9c085-4d24-4b78-85ac-e16b19107ba7",
    "ba3d12de-3dbe-4417-8009-d4b0fe3e7f7f", "17e92565-b2aa-4e53-b3ff-a4691a0fa69f",
    "308cd520-49df-4164-8b22-66e61d76d135", "84764003-f9e7-48d6-a07b-6cf095d6c8de",
    "a3b41509-297e-4cd9-9af2-adb42ff81919", "50d62849-db3d-43e3-ad39-601922cf7aec",
    "3f2fc28f-a00e-460a-a5ed-23887173c9b6", "cfa3fe45-b54d-4c52-aa5d-d79bc80b398e",
    "af808d7c-c8d6-4924-94a9-35bffd450803", "af808d7c-c8d6-4924-94a9-35bffd450803",
    "ce68be09-f359-45de-9fb6-adbfce59935a", "cbb98d74-68e9-4d0f-a4ff-6fa92cfcea13",
    "913341fe-1edc-4782-992f-606a3c3a493c", "56813fb8-5862-4de7-9a11-5cc5b4160753",
    "36dcf965-68c7-44a2-84ef-30df8323dc6e", "c2408cda-c9e6-42b4-8d41-47072acd0571",
    "c8664f59-dcae-4717-833d-8c964c10d16f", "5b386575-5836-40cd-8548-e5c27fd105a1",
    "44f47718-9769-4c0e-af75-7789d2f2913d", "5d6162a4-f592-ae73-67cc-8b392e09ebe0",
    "66719d7c-7731-a7ac-bad3-a80f4416ca4f", "bf6d9682-47cd-460c-972c-7a5d22514fdc",
    "5ba9303c-0675-4c99-b07d-e8eb53a3f8ad", "1bc6f492-e3d0-49a3-b50c-31595947cbc9",
    "ea72d3da-9eed-4791-8875-c93e24316b07", "fd0497e6-4f0a-40cb-87b4-0a58a53bbfdc",
    "7276e6f8-0928-4352-b186-162c03097a21", "3cc28d1f-4279-45df-946c-0b09d934a7c1",
    "1ce2aa0b-30b0-4f60-827a-56a1448e2969", "98f13cd0-0069-466f-bb6e-5b8964b46e66",
    "4e0647d7-baec-46c2-bca2-86596ecbf1ed", "b0f10499-4e01-462f-894f-5b0fe9043b25",
    "560e773d-6825-4cbd-83c1-9d8e4f53a704", "6cbbe9f6-c346-4d6c-b1f1-4cbe6aaf99ef",
    "a92ee8db-142f-4a2a-af64-78e3aec36832", "31d1a9c1-bac0-4738-87ef-23f67b492051",
    "0371fa33-7dae-4980-8468-6d8e99824af6", "b085e96d-e199-467f-b6a8-5d9d44e3cb21",
    "7b1ce21b-809f-4965-b52f-53fe10de6b30", "1ac45157-d063-4314-8832-c50062a885dd",
    "e8bbe73a-e1dc-4d2e-910f-318db7aee382",
}


--物品(白色)
local LunHui_WuPin_BaiSe = {
    --道具消耗品
    --恢复类
    "41c2f574-1fb4-47d9-bf4d-69dfb997375a",
    "3804254f-1e53-47f3-ab64-2d031dd5d08d", "49a4171c-9464-4863-adfb-f684442c9718",
    "81f0d891-cf16-4025-b98e-5b5c1ece0dd7", "9be6aca2-b7d9-4795-9fa2-e3209ed47af5",
    "cb21a0eb-4a1e-442a-8f1e-6020c93a9a73", "4d1b61a0-58e2-4268-beb0-412855588ffe",
    --道具投掷物类
    --装备
    --护甲类
    "bf0c4d5d-eac4-44c5-a816-f730a7f3fdbe","b560fba0-445e-40c7-9309-888ab5dbcfa1",
    "430d5028-70dd-45c0-af11-c268373994a6","0f7533ac-6066-4a70-a9af-5fd560d0e91b",
    "61365e0f-ccef-40aa-a4c9-6fb1b51457a3","3a54dc03-4ce5-492a-8b55-c0b55b5e9040",
    "92e4d68d-4a7c-4744-8dc9-09c96252c61b","49274d5f-d49d-4a8d-a42a-5374d8e6fc8b",
    "b8c9b174-c8e5-4f1e-9e40-c6d688c2af2f",
    --武器类
    "111f7503-bd3a-43db-9cc3-b41925fa74b7", "c3fc0a8e-6a5d-4c9d-a44b-5bbaf5b3161f",
    "d68d1400-2deb-451e-81fc-71b8d9faf052", "6be98366-561e-4bd1-9321-1938dccdade6",
    "33bb42e5-a279-4674-aac5-e03c2951d683", "9720ecfd-87e1-4fe2-88ec-84759c0ad0ec",
    "3f50cf6d-ff35-48c8-bfd2-2bb808b0b9a5", "7071707a-9a9b-4f5c-93eb-eba51ec880c2",
    "8fd0c935-d56f-40d8-8de9-9ec3ecb53f89", "55d9804b-7ed5-43f3-b55d-b0412f72b541",
    "51f0c360-b394-4c1c-a20f-0ff12ac7334c", "e25f391d-c5e0-4903-9266-e372aa633987",
    "ce36f3f0-216e-4795-b93c-8e509241b4b9"

    --饰品类
    --材料类
    --宝石

}

--乐园币钱袋(白色)
local LunHui_WuPin_BaiSe_LeYuanBi = { "fed485f9-e1d8-4b40-8a31-8f2511e0779b", }

--宝箱碎片(白色)
local LunHui_WuPin_BaiSe_BaoXiangSuiPian = { "b0677ea6-a46f-4645-9b03-cdfdd6686261", }

--宝箱(白色)
local LunHui_WuPin_BaiSe_BaoXiang = { "e7fc89a3-3cc1-4e13-a8ba-b95b167ef2e7", }

--青铜勋章
local LunHui_WuPin_XunZhang_QingTongXunZhang = { "3ac9f199-c990-45c1-975c-2f95f9ccdd26", }

--物品(绿色)
local LunHui_WuPin_LvSe = {
    --道具消耗品
    --恢复类
    "accef253-4e6c-45f0-977e-bb4d653d5a34", "88a58e59-469f-4c5c-8a78-133b081cd848",
    "6d66ba70-cc6d-416c-9be0-8fd079a54053", "5c478a19-8140-4eb5-87a9-afdcf27fa899",
    "9a14cc44-867f-403a-b0f1-7b161554921c",
    --投掷物类

    --装备
    --护甲类
    --武器类
    --饰品类
    --宝石
    "a9cd4708-2ad4-40de-a485-c6eb6841ffad", "2ff013d8-765c-4713-aaf4-5ea6917ef5c7",
    "9847a8f8-3d96-44eb-9fc7-1ec3bacd5ff2", "94a78f33-6bc3-487d-9dca-a60f4d878527",
    "e5e967ec-8eac-4c43-80e5-603a76cda11c", "09a741e2-4a9a-4900-9f74-df267c44829b",
    "b428a5ad-c51f-42a7-a329-624f512b8395",
    --强化石类
    "fe2d9e27-0a73-4364-bf16-7d14b5ab27e6",
    --材料类
    --灵魂结晶（小）
    "8775cab3-da03-4e5e-a93c-7fdbfe720ef6",
    

}




--宝箱（白色）内容占比：垃圾40%、白色物品25%、乐园币钱袋15%、宝箱碎片（白色）10%、绿色物品5%、宝箱（白色）5%
Ext.Osiris.RegisterListener("StatusRemoved", 4, "after", function(object, status, causee, applyStoryActionID)
    --  if status == "BaiSe_BaoXiang_BOOST" then
    --local LaJI = 40
    -- local BaiSe = 25
    --local LeYuanBi_BaiSe = 15
    -- local BaoXiangSuiPian_BaiSe = 10
    -- local LvSe = 5
    --local BaoXiang_BaiSe = 5
    -- local LootRoll = Random(100)
    --  local ShuLiang = Random(4)

    -- if LootRoll <= LaJI then
    --     LunHui_WuPin_ID = LunHui_WuPin_LaJi[Ext.Utils.Random(#LunHui_WuPin_LaJi)]
    -- elseif LootRoll <= BaiSe  then
    --     LunHui_WuPin_ID = LunHui_WuPin_BaiSe[Ext.Utils.Random(#LunHui_WuPin_BaiSe)]
    -- elseif LootRoll <= LeYuanBi_BaiSe then
    --     LunHui_WuPin_ID = LunHui_WuPin_BaiSe_LeYuanBi[Ext.Utils.Random(#LunHui_WuPin_BaiSe_LeYuanBi)]
    -- elseif LootRoll <= BaoXiangSuiPian_BaiSe then
    --     LunHui_WuPin_ID = LunHui_WuPin_BaiSe_BaoXiangSuiPian[Ext.Utils.Random(#LunHui_WuPin_BaiSe_BaoXiangSuiPian)]
    -- elseif LootRoll <= LvSe then
    --     LunHui_WuPin_ID = LunHui_WuPin_LvSe[Ext.Utils.Random(#LunHui_WuPin_LvSe)]
    -- elseif LootRoll <= BaoXiang_BaiSe then
    --     LunHui_WuPin_ID = LunHui_WuPin_BaiSe_BaoXiang[Ext.Utils.Random(#LunHui_WuPin_BaiSe_BaoXiang)]
    --  end
    --     Osi.TemplateAddTo(LunHui_WuPin_ID, object, 1, 1)
    --  end

    --垃圾
    if status == "LaJi_BOOST" then
        LunHui_WuPin_ID = LunHui_WuPin_LaJi[Ext.Utils.Random(#LunHui_WuPin_LaJi)]
        Osi.TemplateAddTo(LunHui_WuPin_ID, object, 1, 1)
    end
    --白色物品
    if status == "BaiSe_WuPin_BOOST" then
        LunHui_WuPin_ID = LunHui_WuPin_BaiSe[Ext.Utils.Random(#LunHui_WuPin_BaiSe)]
        Osi.TemplateAddTo(LunHui_WuPin_ID, object, 1, 1)
    end
    --白色乐园币钱袋
    if status == "BaiSe_LeYuanBi_BOOST" then
        LunHui_WuPin_ID = LunHui_WuPin_BaiSe_LeYuanBi[Ext.Utils.Random(#LunHui_WuPin_BaiSe_LeYuanBi)]
        Osi.TemplateAddTo(LunHui_WuPin_ID, object, 1, 1)
    end
    --白色宝箱碎片
    if status == "BaiSe_BaoXiang_SuiPian_BOOST" then
        LunHui_WuPin_ID = LunHui_WuPin_BaiSe_BaoXiangSuiPian[Ext.Utils.Random(#LunHui_WuPin_BaiSe_BaoXiangSuiPian)]
        Osi.TemplateAddTo(LunHui_WuPin_ID, object, 1, 1)
    end
    --白色宝箱
    if status == "BaiSe_BaoXiang_BOOST" then
        LunHui_WuPin_ID = LunHui_WuPin_BaiSe_BaoXiang[Ext.Utils.Random(#LunHui_WuPin_BaiSe_BaoXiang)]
        Osi.TemplateAddTo(LunHui_WuPin_ID, object, 1, 1)
    end
    --绿色物品
    if status == "LvSe_WuPin_BOOST" then
        LunHui_WuPin_ID = LunHui_WuPin_LvSe[Ext.Utils.Random(#LunHui_WuPin_LvSe)]
        Osi.TemplateAddTo(LunHui_WuPin_ID, object, 1, 1)
    end
    --青铜勋章
    if status == "QingTongXunZhang_BOOST_KX" then
        LunHui_WuPin_ID = LunHui_WuPin_XunZhang_QingTongXunZhang
            [Ext.Utils.Random(#LunHui_WuPin_XunZhang_QingTongXunZhang)]
        Osi.TemplateAddTo(LunHui_WuPin_ID, object, 1, 1)
    end
end)
