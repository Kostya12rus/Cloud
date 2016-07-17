﻿//Автостилл спелов
try{
	Game.Panels.EnemyChat.DeleteAsync(0)
	GameEvents.Unsubscribe( parseInt(Game.Subscribes.EnemyChatOnMsg) )
}catch(e){}

function EnemyChatCreatePanel(){
	Game.Panels.EnemyChat = $.CreatePanel( 'Panel', Game.GetMainHUD(), 'EnemyChatPanel' )
	Game.Panels.EnemyChat.BLoadLayoutFromString( '<root><Panel style="border: 1px solid #000;background-color:#000000EE;width:220px;overflow: squish scroll;height: 300px;flow-children: down;"></Panel></root>', false, false )
	GameUI.MovePanel(Game.Panels.EnemyChat,function(p){
		var position = p.style.position.split(' ')
		Config.MainPanel.x = position[0]
		Config.MainPanel.y = position[1]
		Game.SaveConfig('enemychat/config.conf', Config)
	})
	Game.GetConfig('enemychat/config.conf',function(a){
		Config = a
		Game.Panels.EnemyChat.style.position = Config.MainPanel.x + ' ' + Config.MainPanel.y + ' 0'
	})
	Game.Subscribes.EnemyChatOnMsg = GameEvents.Subscribe("player_chat", function(a){
		if(Players.GetTeam(Players.GetLocalPlayer())==Players.GetTeam(a.playerid))
			return
		var text = a.text
		var heroname = Players.GetPlayerSelectedHero(a.playerid)
		var message = $.CreatePanel( 'Panel', Game.Panels.EnemyChat, 'EnemyChatMessage' )
		message.BLoadLayoutFromString( '<root><Panel style="border: 1px solid #000;width:100%;flow-children: right;"><DOTAHeroImage style="height:20px;width:33px;"/><Label style="font-size:15px;text-shadow:0px 0px 4px 1.2 #0F0 33;color:#0F0;"/></Panel></root>', false, false )
		message.Children()[0].heroname = heroname
		message.Children()[1].text = text
		message.DeleteAsync(9)
		Game.AnimatePanel( message, {"opacity": "0;"}, 4, "linear", 5)
	})
}

var EnemyChatOnCheckBoxClick = function(){
	if ( !EnemyChat.checked ){
		try{
			Game.Panels.EnemyChat.DeleteAsync(0)
			GameEvents.Unsubscribe( parseInt(Game.Subscribes.EnemyChatOnMsg) )
		}catch(e){}
		Game.ScriptLogMsg('Script disabled: EnemyChat', '#ff0000')
		return
	}
	EnemyChatCreatePanel()
	Game.ScriptLogMsg('Script enabled: EnemyChat', '#00ff00')
}

//шаблонное добавление чекбокса в панель
var Temp = $.CreatePanel( "Panel", $('#trics'), "EnemyChat" )
Temp.SetPanelEvent( 'onactivate', EnemyChatOnCheckBoxClick )
Temp.BLoadLayoutFromString( '<root><styles><include src="s2r://panorama/styles/dotastyles.vcss_c" /><include src="s2r://panorama/styles/magadan.vcss_c" /></styles><Panel><ToggleButton class="CheckBox" id="EnemyChat" text="EnemyChat"/></Panel></root>', false, false)  
var EnemyChat = $.GetContextPanel().FindChildTraverse( 'EnemyChat' ).Children()[0]