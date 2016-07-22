require("libs.ScriptConfig")
require("libs.Utils")

local config = ScriptConfig.new()
config:SetParameter("PINGUI", "D", config.TYPE_HOTKEY)
config:Load()

local me = entityList:GetMyHero()
local pl = entityList:GetMyPlayer()
local allies = entityList:GetEntities({type = LuaEntity.TYPE_HERO, team = me.team})

function Tick()
	if PlayingGame() then
		for i = 1, #allies do
		local tima = allies[i]
			if IsKeyDown(config.PINGUI) then
				client:Ping(Client.PING_DANGER,tima.position)
			end
		end
	end
end

script:RegisterEvent(EVENT_TICK,Tick)