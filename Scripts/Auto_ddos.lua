require("libs.ScriptConfig")

local config = ScriptConfig.new()
config:SetParameter("DDOS", "O", config.TYPE_HOTKEY)
config:SetParameter("PAUSEcrach", "P", config.TYPE_HOTKEY)
config:Load()

local registered = false


function Load()
  local me = entityList:GetMyHero()

  if PlayingGame() then
    registered = true
    script:RegisterEvent(EVENT_TICK,Tick)
    script:UnregisterEvent(Load)
  end
end

function Tick(tick)
	if IsKeyDown(config.DDOS) then
		client:ExecuteCmd ("status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;status;")
	end
	if IsKeyDown(config.PAUSEcrach) then
		client:ExecuteCmd ("dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;dota_pause;")
	end
end

end

function Close()
  collectgarbage("collect")
  if registered then
    script:UnregisterEvent(Tick)
    script:RegisterEvent(EVENT_TICK,Load)
    registered = false
  end
end

script:RegisterEvent(EVENT_CLOSE,Close)
script:RegisterEvent(EVENT_TICK,Load)
