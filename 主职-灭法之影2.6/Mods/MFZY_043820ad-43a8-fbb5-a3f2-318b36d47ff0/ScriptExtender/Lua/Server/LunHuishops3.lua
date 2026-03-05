local Single_Wolf_Caster = nil
local Single_Wolf_Target = nil
local Target_Current_Hp = nil



-- Ext.Osiris.RegisterListener("StatusRemoved", 4, "after", function(object, status, causee, applyStoryActionID)
--     --水晶剑/大炮--
--     if status == "Boost_Wolf_Strike_Full" then
--         Osi.ApplyDamage(Single_Wolf_Target,2*Single_Wolf_Target_Current_Hp/5,"Necrotic",Single_Wolf_Caster)
--     end
--     if status == "Boost_Wolf_Strike_Half" then
--         Osi.ApplyDamage(Single_Wolf_Target,Target_Current_Hp/5,"Necrotic",Single_Wolf_Caster)
--     end
-- end)

-- Ext.Osiris.RegisterListener("StatusApplied", 4, "after", function(object, status, causee, applyStoryActionID)
-- 	if status == "Boost_SoulTaker_Fate_Reaper_Self" and Fate_Reaper_Target then

--     end





-- end)

-- Ext.Osiris.RegisterListener("StatusApplied", 4, "after", function(object, status, causee, storyActionID)
-- 	if status == "Boost_SoulTaker_Fate_Reaper" then  ---获得状态时获取目标 与释放者
-- 		Fate_Reaper_Target = object
-- 		Fate_Reaper_Caster = causee
-- 	end

-- 	if status == "Boost_SoulFire_Reaper_Ability" then  ---获得状态附加状态
-- 		local SoulFire_Ability = AbilityPool[Ext.Utils.Random(#AbilityPool)]
-- 		Osi.ApplyStatus(object, SoulFire_Ability, -1, 0, object)
-- 	end

-- 	if status == "Boost_SoulFire_Mark" then   ---获得状态 召唤
-- 		table.insert(PersistentVars_SoulFire, spawnSoulFire('562e21be-5fe7-4fa8-8d15-6fa69134b07b', SFx,SFy,SFz))
-- 	end

-- end)
local Feat_HuiYin_Caster = nil
local Feat_HuiYin_Target = nil
local Scwuli = nil
local CopySpellwuli = nil
local CopySpellfashu = nil
local Feat_XueJin_Target = nil
local Feat_XueJin_Caster = nil
local Number1 = 0
local Number2 = 0

local Dianjin_Target_Current_Hp = nil

-------测试-----------
---
---

--------监听 使用技能
Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", function (caster, target, spell, spellType, spellElement, storyActionID)
    if  Osi.HasPassive(caster,"passive_SCwuli") == 1  then

        CopySpellwuli = spell
        Feat_HuiYin_Target = target
        Feat_HuiYin_Caster = caster
    

    elseif  Osi.HasPassive(caster,"passive_SCfashu") == 1 then

        CopySpellfashu = spell
        Feat_XueJin_Target = target
        Feat_XueJin_Caster = caster
    end

    if spell == "Target_Spell_dianjin" then
        Dianjin_Caster = caster
		Dianjin_Target = target
        Dianjin_Target_Current_Hp = Osi.GetHitpoints(Dianjin_Target)


    end
end)


Ext.Osiris.RegisterListener("StatusApplied", 4, "after", function(object, status, causee, storyActionID)
	if status == "Boost_wuli_Target"  then
		if  Osi.HasActiveStatus(Feat_HuiYin_Target,"Boost_wuli_Target") == 1 then

            for i = 0, 0 do
                Osi.UseSpell(Feat_HuiYin_Caster, CopySpellwuli, Feat_HuiYin_Target)
                
            end
    
            Osi.RemoveStatus(Feat_HuiYin_Target,"Boost_wuli_Target",Feat_HuiYin_Caster)
            Osi.RemoveStatus(Feat_HuiYin_Caster,"Boost_wuli_Self",Feat_HuiYin_Target)
        end
    elseif status == "Boost_fashu_Target" then
        if  Osi.HasActiveStatus(Feat_XueJin_Target,"Boost_fashu_Target") == 1  then
            for j = 0, 0 do
                Osi.UseSpell(Feat_XueJin_Caster, CopySpellfashu, Feat_XueJin_Target)
                
            end
            Osi.RemoveStatus(Feat_XueJin_Target,"Boost_fashu_Target",causee)
            
            Osi.RemoveStatus(causee,"Boost_fashu_Self",Feat_XueJin_Target)
        end
	end

    if status == "Boost_Dianjin_mk" then
        local DianjinCount = Dianjin_Target_Current_Hp * 3 
        Osi.ApplyStatus(object, "Boosts_jinbi", DianjinCount, 0, object)
    end
end)



--------监听 状态移除
---
-- Ext.Osiris.RegisterListener("StatusRemoved", 4, "after", function(object, status, causee, applyStoryActionID)
-- 	if status == "Boost_fashu_Target" and Feat_XueJin_Target then
--         Number1 = 0
-- 		-- Osi.RemoveStatus(Feat_HuiYin_Target, "Boost_wuli_Target", Feat_HuiYin_Caster)
-- 	end

-- end)

-- Ext.Osiris.RegisterListener("AttackedBy", 7, "after", function(defender, attackerOwner, attacker2, damageType, damageAmount, damageCause, storyActionID)
-- 	if Osi.HasActiveStatus(defender, "Boost_SoulTaker_Fate_Reaper_Self") == 1 and Fate_Reaper_Target then
-- 		Osi.ApplyDamage(Fate_Reaper_Target, damageAmount, damageType, defender)
-- 	end

-- 	if Osi.HasPassive(attacker2,"Passive_SoulTaker_Deep_Hatred") == 1 then
-- 		Hatred_Damage = damageAmount*3
-- 		Hatred_Damage_Type = damageType
-- 	end
-- end)