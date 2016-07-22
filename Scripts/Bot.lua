--<< Тестовый скрипт от Kostya12rus 0.2 >>
require("libs.ScriptConfig")
require("libs.Utils")

local config = ScriptConfig.new()
config:SetParameter("gold", "T", config.TYPE_HOTKEY)
config:SetParameter("go", "D", config.TYPE_HOTKEY)
config:SetParameter("lvl", "U", config.TYPE_HOTKEY)
config:SetParameter("refresh", "K", config.TYPE_HOTKEY)
config:SetParameter("respawn", "O", config.TYPE_HOTKEY)
config:SetParameter("wtf", "P", config.TYPE_HOTKEY)
config:SetParameter("PointGold", 99999)
config:SetParameter("Pointlvl", 24)
config:Load()

local me = entityList:GetMyHero()
local pl = entityList:GetMyPlayer()
local knopka = config.knopka
local buy = {29, 16}


function Tick()
    if IsKeyDown(config.go) then
		pl:Move(client.mousePosition)
	end

	if client.chat or client.console or client.loading then
		return 
	end
	
	if IsKeyDown(config.gold) then
		client:ExecuteCmd("say " ..me.Position)
	end
end

function Load()
	if PlayingGame() then
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

script:RegisterEvent(EVENT_CLOSE,Close)
script:RegisterEvent(EVENT_TICK,Load)