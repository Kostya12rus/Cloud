--<< Тестовый скрипт от Kostya12rus 0.2 >>
require("libs.ScriptConfig")
require("libs.Utils")

local config = ScriptConfig.new()
config:SetParameter("knopka", "D", config.TYPE_HOTKEY)
config:SetParameter("bay", "T", config.TYPE_HOTKEY)
config:SetParameter("StartTime", 1)
config:Load()

local me = entityList:GetMyHero()
local pl = entityList:GetMyPlayer()
local knopka = config.knopka
local buy = {29, 16}

local x,y = 5, 55
local monitor = client.screenSize.x/1600
local ScreenX = client.screenSize.x
local ScreenY = client.screenSize.y
local Font = drawMgr:CreateFont("Font","Tahoma",0.02071875*ScreenY,0.4375*ScreenX)

function Key(msg,code)
	if msg ~= KEY_UP and code == config.Hotkey and not client.chat and not client.console then
		if not activated then
			activated = true
			statusText = drawMgr:CreateText(x*monitor,y*monitor,0x9CB7F7CC,"Necr skript on",Font) statusText.visible = true
		else
			activated = false
			statusText = drawMgr:CreateText(x*monitor,y*monitor,0x9CB7F7CC,"Necr skript off",Font) statusText.visible = true
		end
	end
end

function Tick()
    if IsKeyDown(config.bay) and activated then
		pl:Move(client.mousePosition)
	end

	if client.chat or client.console or client.loading then
		return 
	end
	
	if IsKeyDown(config.knopka) and activated then
		client:ExecuteCmd("say_team  X="..client.mousePosition.x.." Y="..client.mousePosition.y.." Team="..me.team)
	end
	
end

function Load()
	if PlayingGame() and me.classId ~= CDOTA_Unit_Hero_necrolyte then
		play = true
		script:RegisterEvent(EVENT_TICK,Tick)
		script:UnregisterEvent(Load)
	else
		script:Disable()
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

script:RegisterEvent(EVENT_Key,Key)
script:RegisterEvent(EVENT_CLOSE,Close)
script:RegisterEvent(EVENT_TICK,Load)