--[[
Broodking AI
]]

require( "ai/ai_core" )
function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
	thisEntity.moment = thisEntity:FindAbilityByName("boss_moment_of_courage")
	thisEntity.odds = thisEntity:FindAbilityByName("boss_overwhelming_odds")
	thisEntity.press = thisEntity:FindAbilityByName("boss_press_the_attack")
	thisEntity.call = thisEntity:FindAbilityByName("boss_call_reinforcements")
	if GetMapName() == "epic_boss_fight_challenger" then
		thisEntity.moment:SetLevel(4)
		thisEntity.press:SetLevel(4)
		thisEntity.odds:SetLevel(4)
	elseif GetMapName() == "epic_boss_fight_impossible" then
		thisEntity.moment:SetLevel(3)
		thisEntity.press:SetLevel(3)
		thisEntity.odds:SetLevel(3)
	elseif GetMapName() == "epic_boss_fight_hard" or GetMapName() == "epic_boss_fight_boss_master" then
		thisEntity.moment:SetLevel(2)
		thisEntity.press:SetLevel(2)
		thisEntity.odds:SetLevel(2)
		thisEntity:SetMaxHealth(thisEntity:GetMaxHealth()*0.9)
		thisEntity:SetBaseDamageMin(thisEntity:GetBaseDamageMin()*0.8)
		thisEntity:SetBaseDamageMax(thisEntity:GetBaseDamageMax()*0.8)
	else
		thisEntity.moment:SetLevel(1)
		thisEntity.press:SetLevel(1)
		thisEntity.odds:SetLevel(1)
		thisEntity:SetMaxHealth(thisEntity:GetMaxHealth()*0.8)
		thisEntity:SetBaseDamageMin(thisEntity:GetBaseDamageMin()*0.7)
		thisEntity:SetBaseDamageMax(thisEntity:GetBaseDamageMax()*0.7)
	end
	thisEntity:SetHealth(thisEntity:GetMaxHealth())
end


function AIThink()
	if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
		if thisEntity.odds:IsFullyCastable() then
			local radius = thisEntity.odds:GetSpecialValueFor("radius")
			local range = thisEntity.odds:GetCastRange() + radius
			if AICore:TotalEnemyHeroesInRange( thisEntity, radius ) ~= 0 then
				local position = AICore:OptimalHitPosition(thisEntity, range, radius)
				if position and RollPercentage(25) then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = position,
						AbilityIndex = thisEntity.odds:entindex()
					})
					return 0.25
				end
			end
		end
		if thisEntity.press:IsFullyCastable() then
			local hpregen = thisEntity.press:GetSpecialValueFor("hp_regen") *  thisEntity.press:GetSpecialValueFor("duration")
			if thisEntity:IsAttacking() or thisEntity:GetHealthDeficit() > hpregen and RollPercentage(5) then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
					TargetIndex = thisEntity:entindex(),
					AbilityIndex = thisEntity.press:entindex()
				})
				return 0.25
			elseif AICore:TotalAlliedUnitsInRange( thisEntity, thisEntity.press:GetCastRange() ) then
				local ally = AICore:WeakestAlliedUnitInRange( thisEntity, thisEntity.press:GetCastRange() , false)
				if ally and ally:GetHealthDeficit() > hpregen then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
						TargetIndex = ally:entindex(),
						AbilityIndex = thisEntity.press:entindex()
					})
					return 0.25
				end
			end
		end
		if thisEntity.call:IsFullyCastable() and AICore:SpecificAlliedUnitsAlive( thisEntity, "npc_dota_boss5b" ) < 6 then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = thisEntity.call:entindex()
			})
			return thisEntity.call:GetChannelTime()
		end
		AICore:AttackHighestPriority( thisEntity )
		return 0.25
	else return 0.25 end
end