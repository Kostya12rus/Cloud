--<< Тестовый скрипт на Necra от Kostya12rus 0.9 >>
require("libs.ScriptConfig")
require("libs.Utils")
require("libs.SideMessage")

local config = ScriptConfig.new()
config:SetParameter("GO", "D", config.TYPE_HOTKEY)
config:SetParameter("ONOFF", "T", config.TYPE_HOTKEY)
config:SetParameter("minHP", 200)
config:SetParameter("VIDNOleave", true)
config:Load()

local me = entityList:GetMyHero()
local pl = entityList:GetMyPlayer()
local courier = entityList:FindEntities({classId = CDOTA_Unit_Courier,team = me.team,alive = true})
local neutrals = entityList:GetEntities({team=LuaEntity.TEAM_NEUTRAL})
local allies = entityList:GetEntities({type = LuaEntity.TYPE_HERO, team = me.team, alive=true})
local enemies = entityList:FindEntities({type=LuaEntity.TYPE_HERO,alive=true,illusion=false,team = (5-me.team),visible=true})

local ON = false
local start = false
local leave = false
local necr = false
local alhim = true
local timestack = 48
local soulring = me:FindItem("item_soul_ring")
local Brizg = me:GetAbility(1)

--                   (1:     Место лагеря ,  2:      Место отвода    ,3:     Место ожидания, 4:     Фонтан            5:     Блинк       6:     Брызг         )
mest_rad =           {Vector(-3025,47,256),  Vector(-3560,-1438,256), Vector(-2351,-434,256), Vector(-7008,-7072,397), Vector(-3017,-392,397) }  
mest_dire =          {Vector(3969,-698,127), Vector(2169,-596,127),   Vector(3615,-155,256),  Vector(7008,6816,383),   Vector(3692,-1329,397) }  

function Tick()
	if PlayingGame() and me.alive and not client.paused then
			if pl.team == LuaEntity.TEAM_DIRE then
				mest = mest_dire
				mestB = Vector(3686,-680,127)
				mestALH = Vector(3607,-147,256)
				local Dire = true
			elseif pl.team == LuaEntity.TEAM_RADIANT then
				mest = mest_rad
				mestB = Vector(-2982,-172,127)
				mestALH = Vector(-3711,-354,127)
			end
			
			if me.classId == CDOTA_Unit_Hero_Necrolyte then
				local necr = true
				local alhim = false
			elseif me.classId == CDOTA_Unit_Hero_Alchemist then
				local alhim = true
				local necr = false
			end
		
			if (client.gameTime <= 0) then
				pl:Move(mest[2])
				start = true
			end
			if (client.gameTime <= 30 and client.gameTime >= 0) then
				if alhim then
					pl:Move(mestALH)
				elseif necr then
					pl:Move(mest[3])
				end
			end
			
		if necr then
			if (client.gameTime % 60 >= timestack and client.gameTime % 60 <= timestack + 0.1) then
				pl:Move(mest[1], false)
				pl:Move(mest[2], true)
				if me.health <= config.minHP then
					pl:Move(mest[4], true)
				end
				pl:Move(mest[3], true)
			end
		end
		if alhim then
			if (client.gameTime % 60 >= 52 and client.gameTime % 60 <= 52.2) or (client.gameTime % 60 >= 22 and client.gameTime % 60 <= 22.2) then
				entityList:GetMyPlayer():UseAbility(Brizg, mestB)
			end
			if (client.gameTime % 60 >= 45 and client.gameTime % 60 <= 46) or (client.gameTime % 60 >= 15 and client.gameTime % 60 <= 16) and soulring then
				me:CastAbility(soulring)
			end
			if (client.gameTime % 60 >= 55 and client.gameTime % 60 <= 56) or (client.gameTime % 60 >= 25 and client.gameTime % 60 <= 26) then
				pl:Move(mestALH)
			end
		end
		
		if IsKeyDown(config.ONOFF) then
			me:SafeCastAbility(soulring, true)
			entityList:GetMyPlayer():UseAbility(Brizg, mestB)
			pl:move(mestALH)
		end
		
		if VIDNOleave then
			if me.visibleToEnemy then
				local blink = me:FindItem("item_blink")
				if blink:CanBeCasted() then
					me:SafeCastAbility(Blink, mest[5])
				else
					pl:Move(mest[4])
				end
			end
		end
	end
end
	



function Load()
	if PlayingGame() then
		play = true
		script:RegisterEvent(EVENT_TICK,Tick)
		script:UnregisterEvent(Load)
	end
end

function Close()
	collectgarbage("collect")
	if play then
		script:UnregisterEvent(Tick)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
end

script:RegisterEvent(EVENT_CLOSE,Close)
script:RegisterEvent(EVENT_TICK,Load)