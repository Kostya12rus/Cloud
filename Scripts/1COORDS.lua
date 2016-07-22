require("libs.ScriptConfig")
require("libs.Utils")

local config = ScriptConfig.new()
config:SetParameter("coord", "D", config.TYPE_HOTKEY)
config:Load()

function Tick()
	if IsKeyDown(config.coord) then
		client:ExecuteCmd("say_team X = "..client.mousePosition.x.. " Y = "..client.mousePosition.y)
	end
end
script:RegisterEvent(EVENT_TICK,Tick)