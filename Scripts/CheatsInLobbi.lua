--<<Читы для Лобби от Kostya12rus v2.5>>
require("libs.ScriptConfig")
require("libs.Utils")
require("libs.SideMessage")

local config = ScriptConfig.new()
config:SetParameter("gold", "T", config.TYPE_HOTKEY)
config:SetParameter("lvl", "U", config.TYPE_HOTKEY)
config:SetParameter("refresh", "K", config.TYPE_HOTKEY)
config:SetParameter("respawn", "O", config.TYPE_HOTKEY)
config:SetParameter("wtf", "P", config.TYPE_HOTKEY)
config:SetParameter("PointGold", 99999)
config:SetParameter("Pointlvl", 24)
config:Load()

local me = entityList:GetMyHero()
local pl = entityList:GetMyPlayer()
local wtf = false

local x,y = 5, 55
local monitor = client.screenSize.x/1600
local ScreenX = client.screenSize.x
local ScreenY = client.screenSize.y
local Font = drawMgr:CreateFont("Font","Arial",20,10)
local statusText = drawMgr:CreateText(x*monitor,(y)*monitor,0x9CB7F7CC,"To get the GOLD in the press "..string.char(config.gold),Font) statusText.visible = true
local statusText2 = drawMgr:CreateText(x*monitor,(y+20)*monitor,0x9CB7F7CC,"To get the LVL in the press "..string.char(config.lvl),Font) statusText.visible = true
local statusText3 = drawMgr:CreateText(x*monitor,(y+40)*monitor,0x9CB7F7CC,"To make REFRESH press "..string.char(config.refresh),Font) statusText.visible = true
local statusText4 = drawMgr:CreateText(x*monitor,(y+60)*monitor,0x9CB7F7CC,"To RESPAWN press "..string.char(config.respawn),Font) statusText.visible = true
local statusText5 = drawMgr:CreateText(x*monitor,(y+80)*monitor,0x9CB7F7CC,"On WTF mod press "..string.char(config.wtf),Font) statusText.visible = true


do
	sideMessage:CreateMessage(300,40):AddElement( drawMgr:CreateText(5,10,-1,"Welcome to my first script",drawMgr:CreateFont("sideMsg","Arial",20,10) ))
end


function Tick()
	if not client.connected or client.console or client.loading or client.chat then
		return
	end
	
	if IsKeyDown(config.gold) then
		client:ExecuteCmd("dota_give_gold " ..config.PointGold)
		do
			sideMessage:CreateMessage(300,40):AddElement( drawMgr:CreateText(5,10,-1,"You given " ..math.floor(config.PointGold).. " golds",drawMgr:CreateFont("sideMsg","Arial",20,10) ))
		end
	end
	
	if IsKeyDown(config.lvl) then
		client:ExecuteCmd("dota_hero_level " ..config.Pointlvl)
		do
			sideMessage:CreateMessage(300,40):AddElement( drawMgr:CreateText(5,10,-1,"You given " ..math.floor(config.Pointlvl).. " lvl",drawMgr:CreateFont("sideMsg","Arial",20,10) ))
		end
	end
	
	if IsKeyDown(config.refresh) then
		client:ExecuteCmd("dota_hero_refresh")
		do
			sideMessage:CreateMessage(300,40):AddElement( drawMgr:CreateText(5,10,-1,"You skill refresh",drawMgr:CreateFont("sideMsg","Arial",20,10) ))
		end
	end
	
	if IsKeyDown(config.respawn) then
		client:ExecuteCmd("dota_hero_respawn")
		do
			sideMessage:CreateMessage(300,40):AddElement( drawMgr:CreateText(5,10,-1,"You respawn",drawMgr:CreateFont("sideMsg","Arial",20,10) ))
		end
	end
	
	if IsKeyDown(config.wtf) then
    wtf = not wtf
		if wtf == true then
			client:ExecuteCmd("dota_ability_debug_enable")
			do
				sideMessage:CreateMessage(300,40):AddElement( drawMgr:CreateText(5,10,-1,"WTF mod ON",drawMgr:CreateFont("sideMsg","Arial",20,10) ))
			end
		else
			client:ExecuteCmd("dota_ability_debug_disable")
			do
				sideMessage:CreateMessage(300,40):AddElement( drawMgr:CreateText(5,10,-1,"WTF mod OFF",drawMgr:CreateFont("sideMsg","Arial",20,10) ))
			end
		end
	end
end
	
end

function Load()
	if PlayingGame() then
		play = true		
		statusText.visible = true
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
		statusText.visible = false
		active = false
	end
end

script:RegisterEvent(EVENT_CLOSE,Close)
script:RegisterEvent(EVENT_TICK,Load)