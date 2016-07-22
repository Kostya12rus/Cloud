Script

Functions
Disable():                                              ���������� �������� ���� ����� ���� �� �������������.
Enable():                                               ��������� �������� ��������.
RegisterEvent(eventType, function[, optionalParameter): ������������ ������� � �������� ������ �������.�������������� �������� ����� ���� ���������� ��������������.������ ������� ����� ����� �� Global_constants.
Reload():                                               ������������ ��������.
Unload():                                               �������� �������� ���������.
UnregisterEvent(function[, optionaParameter):           ������� ������ ������� �� ������� �������.

Attributes
disabled:   ���������� true, ���� Disable() ���� ������� ������.
filename:   ���������� ������ ���� � ����� ��������.
name:       ���������� ��� �������.
tablename:  ���������� ��� ������� ���������� ����� ��������.

ScriptEngine

Functions
script GetScript(name):                                       ���������� ������ � �������� ������.
boolean IsLoaded(name):                                       ���������� true, ���� ������ � �������� ������ ����� ��������.
RegisterLibEvent(eventType, function[, optionalParameter):   
������������ ������� � �������� ������ �������. 
����������� ��� ������� ������ ��� ���������, ��� ��� ��� �� ������� �� ��������, ������� ���������� ������� � ������ �������.
�������������� �������� ����� ���� ���������� ��������������.������ ������� ����� ����� �� Global_constants.
UnregisterLibEvent(eventType, function[, optionalParameter):  ������� ������ ������� �� ������� �������.

Attributes
count:  ���������� ���������� ����������� ���������.

Client
����� ������ ����� ��� �������, ����������� ��� ������� � ������ �� Dota, ������� ��������������� �� ��������� � ������ � ��������.
  
Constants
  GameMode
Client.MODE_ALL_PICK
Client.MODE_ALL_CAPTAINS_MODE
Client.MODE_RANDOM_DRAFT
Client.MODE_SINGLE_DRAFT
Client.MODE_ALL_RANDOM
Client.MODE_DIRETIDE
Client.MODE_REVERSE_CAPTAINS
Client.MODE_GREEVILING
Client.MODE_TUTORIAL
Client.MODE_MID_ONLY
Client.MODE_LEAST_PLAYED
Client.MODE_LIMITED_HEROES
Client.MODE_COMPENDIUM
Client.MODE_CAPTAINS_DRAFT
Client.MODE_BALANCED_DRAFT
Client.MODE_ABILITY_DRAFT
  GameState
Client.STATE_NOGAME
Client.STATE_LOADED
Client.STATE_PICK
  PingTypes
Client.PING_NORMAL
Client.PING_DANGER
  ShopType
Client.SHOP_NONE
Client.SHOP_BASE
Client.SHOP_SIDE
Client.SHOP_SECRET

 Functions
CloseShop():                                       ��������� �������� ��������, ���� �� ������ � ��������� �����.
ExecuteCmd(command):                               ��������� ����� ��������� ������� DOTA. ��������� ����� ���� ������� ����� Dota2 Wiki.
string Localize(text): 
���������� ������ �����. ���� ��� �����������, ����� ������������� ���, �� �� ����� ������ ������� ������ ������. 
�� ������ � �������� ���������� ����� | ���, �� �� ����� ������ ��������������� ������ �������� ������ ����������, ��� ��������.

AbilityData GetItemData(itemName):                 �������� ������ �������� ��� ������� �����. ����� ����� ���� ������� � "items.txt" � ����������, ��� "item_energy_booster"
boolean GetGroundPosition(position):               ���������� true, ���� ������� ��������� ��������� �� ����� � ��������� z-���������� ����� � z-���������� ����� ������.
number GetGylphCooldown(team):                     �������� �������������� �����. ���� �� ��������, �� ����� �������������� �� ������ ���������� 0. ������� ����� ���� ������� � LuaEntity # ��������.
string GetKeyBinding(binding):                     ���������� ��� ����� ��� ���������� ����. (��������, "dota_ability_execute 0").
OpenShop(shopType):                                ��������� �������� �������� ��� �������� ������.
Ping(pingType,position):                           ping ������������ ����� (������� ��� ������ �������).
Say(text):                                         ������� ���-�� ��� ���� �������.
SayTeam(text):                                     ������� ���-�� � ���� �������.
boolean, screenPosition ScreenPosition(position):  ���������� ��������� ������ ��� ��������� � ����.������ ���������� �������� ���������� true, ���� ���� ����� �� ������.
ToggleShop():                                      ������������ �������� ��������.

Attributes
avgLatency:                                        ���������� ������� � ���� �������� / Ping.
chat:                                              ���������� true, ���� ��� ������.
connected:                                         ���������� true, ���� �� ��������� � ���� (� ��� ����� ����� ��������).
console:                                           ���������� ������, ���� ������� � ��������� ����� �������� �� �������.
expectedPlayers:                                   ���������� ���������� ������� � ���� ���������.
gameDirectory:                                     ���������� ���� ������� Dota2.
gameMode:                                          ���������� ������� ����� ����. ��������� ����������.
gameState:                                         �� ����������.
gameTime:                                          ���������� ����� �������������.
gameWinner:                                        ���������� �������-���������� ������� ����.
language:                                          ���������� ����, ������������ � Dota2. ��������: "English".
latency:                                           ���������� ������� � ���� �������� / Ping.
levelName:                                         ���������� ������� / �������� ����� ������������ � ������ ������ ����.
loadedPlayers:                                     ���������� ���������� ����������� �������.
loading:                                           ���������� ������, ���� � ��������� ����� ����������� � ����, � ��-�������� � ������ ��������.
maxClients:                                        ���������� ���������� ����������� ���������� ��������.
mousePosition:                                     ���������� ������� ������������� ����� ����.
mouseScreenPosition:                               ���������� ��������� ������ ����� ����.
nsNight:                                           ���������� ������, ���� �������� NIGHTSTALKER �������.
paused:                                            ���������� ������, ���� ���� � ��������� ����� ��������������.
pauseTeam:                                         ���������� �������, ������� ����� ����.
uiLanguage:                                        ��������� �� ����� Dota2 ��� �������� ������. ��������: "EN".
screenSize:                                        ���������� ������ ������ � ����.
screenRatio:                                       ���������� ������ ������. � �������� ������ ��� / ����� ������.
shopOpen - boolean:                                ���������� ������, ���� � ������ ������ ������������ �������� ��������.
shopTypeOpen - shopType:                           ���������� ��� �������, ���� �� � ��������� ����� ������.
totalGameTime:                                     ���������� ����� ����� ����. (����� ���� ����������� ��� ��������� calulations ��� ����� �������)
viewAngles:                                        ���������� ���� ������ ������.

LuaEntity
LuaEntities �������� ������ ��� ���� entites � ����. 
��� �� ��� ���������� �� ������ ������� ���� LuaEntity, ����������� ��� ��������� ��� ��������� ������������������ �������.

LuaEntity
������-����� ��� ���� ���, �� ��������� �� ��� ���������� LuaEntity ��� ������ ������ ���������������.

Constants
  EntityType
LuaEntity.TYPE_PLAYER
LuaEntity.TYPE_BASE
LuaEntity.TYPE_HERO
LuaEntity.TYPE_NPC
LuaEntity.TYPE_ABILITY
LuaEntity.TYPE_RUNE
LuaEntity.TYPE_ITEM
LuaEntity.TYPE_ITEM_POWER_TREADS
LuaEntity.TYPE_ITEM_BOTTLE
LuaEntity.TYPE_COURIER
LuaEntity.TYPE_MEEPO
LuaEntity.TYPE_CREEP
LuaEntity.TYPE_ITEM_PHYSICAL
  Team
LuaEntity.TEAM_NONE
LuaEntity.TEAM_OBSERVER
LuaEntity.TEAM_RADIANT
LuaEntity.TEAM_DIRE
LuaEntity.TEAM_NEUTRAL
LuaEntity.TEAM_UNDEFINED

Functions
boolean __eq(LuaEntity):                                         ������� ���������. ��������� ���� ���� � ��������� � "==" ��� "~ ="
number/string GetProperty(ClassName[, TableName], PropertyName): ���������� �������� �������, ������� ����� ��� �� �����������������.
EmitSound(soundFile[, target):                                   ��������������� �������� ����.
StopSound(soundFile):                                            ������������� �������� ���� (� ������ ������������).

Attributes
ability:      ������������� ������������. ���������� true, ���� ���� ����������� � LuaEntityAbility, false � ��������� ������.
alive:        ���������� true, ���� ���� �������� �����.
bottle:       ������������� ������������. ���������� true, ���� ���� ����������� � LuaEntityItemBottle, false � ��������� ������.
classId:      ���������� �������� ������������� ������ ��������. ��� ������� ����� ID ������� ������������� �� ������� ClassIDs.
courier:      ������������� ������������. ���������� true, ���� ���� ����������� � LuaEntityCourier, false � ��������� ������.
creep:        ������������� ������������. ���������� true, ���� ���� ����������� � LuaEntityCreep, false � ��������� ������.
handle:       ���������� ���������� ������������� ����.
hero:         ������������� ������������. ���������� true, ���� ���� ����������� � LuaEntityHero, false � ��������� ������.
item:         ������������� ������������. ���������� true, ���� ���� ����������� � LuaEntityItem, false � ��������� ������.
itemPhysical: ������������� ������������. ���������� true, ���� ���� ����������� � LuaEntityItemPhysical, false � ��������� ������.
name:         ���������� ��� �������.
npc:          ������������� ������������. ���������� true, ���� ���� ����������� � LuaEntityNPC, false � ��������� ������.
owner:        ���������� ��������� �������� � ��������.
position:     ���������� ������, ������� ����
powerTreads:  ������������� �������������. ���������� true, ���� ���� ����������� � LuaEntityItemPowerTreads, false � ��������� ������.
rot:          ���������� �������� ���� �� XY ��������� � ���� �������.
rotR:         ���������� �������� ���� �� XY ��������� � ���� ������.
rune:         ������������� �������������. ���������� true, ���� ���� ����������� � LuaEntityRune, false � ��������� ������.
team:         ���������� �������� �������� ������� �����������.
type:
visible:      ���������� true, ���� ���� �����, false � ��������� ������

Player
����� ������� ����� LuaEntity. ��� ��� ��� ������� ����� ���������, ��� ������� ���, �� ������ ����� ��� �����: Player.

LuaEntityNPC
LuaEntityNPC �������� ������� ����� LuaEntity. 
����� ����, ������� �������� ���� � ���� ��������� ��� ����� ������. 
�� ������ � ������ ������ � ������� ��� ���������� ���� ����� ����� ��� ��������.

Constants
  Shop
LuaEntityNPC.SHOP_BASE
LuaEntityNPC.SHOP_NONE
LuaEntityNPC.SHOP_SECRET
LuaEntityNPC.SHOP_SIDE
  Activity
LuaEntityNPC.ACTIVITY_ATTACK
LuaEntityNPC.ACTIVITY_ATTACK1
LuaEntityNPC.ACTIVITY_ATTACK2
LuaEntityNPC.ACTIVITY_ATTACK_NONE
LuaEntityNPC.ACTIVITY_ATTACK_MELEE
LuaEntityNPC.ACTIVITY_ATTACK_RANGED
LuaEntityNPC.ACTIVITY_IDLE
LuaEntityNPC.ACTIVITY_IDLE1
LuaEntityNPC.ACTIVITY_CAST1
LuaEntityNPC.ACTIVITY_CAST2
LuaEntityNPC.ACTIVITY_CAST3
LuaEntityNPC.ACTIVITY_CAST4
LuaEntityNPC.ACTIVITY_CRIT
LuaEntityNPC.ACTIVITY_MOVE
  AttackCapabilities
LuaEntityNPC.ATTACK_NONE
LuaEntityNPC.ATTACK_MELEE
LuaEntityNPC.ATTACK_RANGED
  UnitState
LuaEntityNPC.STATE_ROOTED
LuaEntityNPC.STATE_SOFT_DISARMED
LuaEntityNPC.STATE_DISARMED
LuaEntityNPC.STATE_ATTACK_IMMUNE
LuaEntityNPC.STATE_SILENCED
LuaEntityNPC.STATE_MUTED
LuaEntityNPC.STATE_STUNNED
LuaEntityNPC.STATE_HEXED
LuaEntityNPC.STATE_INVISIBLE
LuaEntityNPC.STATE_INVULNERABLE
LuaEntityNPC.STATE_MAGIC_IMMUNE
LuaEntityNPC.STATE_PROVIDES_VISION
LuaEntityNPC.STATE_NIGHTMARED
LuaEntityNPC.STATE_BLOCK_DISABLED
LuaEntityNPC.STATE_EVADE_DISABLED
LuaEntityNPC.STATE_UNSELECTABLE
LuaEntityNPC.STATE_CANNOT_MISS
LuaEntityNPC.STATE_SPECIALLY_DENIABLE
LuaEntityNPC.STATE_FROZEN
LuaEntityNPC.STATE_COMMAND_RESTRICTED
LuaEntityNPC.STATE_NOT_ON_MINIMAP_FOR_ENEMIES
LuaEntityNPC.STATE_NOT_ON_MINIMAP
LuaEntityNPC.STATE_LOW_ATTACK_PRIORITY
LuaEntityNPC.STATE_NO_HEALTHBAR
LuaEntityNPC.STATE_FLYING
LuaEntityNPC.STATE_NO_COLLISION
LuaEntityNPC.STATE_NO_TEAM_MOVE_TO
LuaEntityNPC.STATE_NO_TEAM_SELECT
LuaEntityNPC.STATE_PASSIVES_DISABLED
LuaEntityNPC.STATE_DOMINATED
LuaEntityNPC.STATE_BLIND
LuaEntityNPC.STATE_OUT_OF_GAME

Functions
ability GetAbility(slot):         ���������� ����������� � ��������� �����.
item GetItem(slot):               ���������� ������� � ��������� �����.
boolean HasItem(slot):            ���������� ������, ���� ���� ����� � ��������� �����, ����� ����.
boolean IsControllable(playerId): ���������� ������, ���� ����� � ������ playerId ����� �������������� ��� ��������.


Attributes
activity:          ���������� �������� ������������ ����������� ���������. ��������� ������ ���������� ����� ���� ������� � ����������.
abilities:
ancient:           ���������� ������, ���� ���� �������� �������, ���� � ��������� ������.
armor:             ���������� ������� ����� ����.
attackBaseTime:
attackRange:       ���������� �������� ����� ��������.
attackSpeed:       ���������� �������� �������� ����� ��������.
attackType:        ���������� �������� ��� ����� ��������. ��������� ������ ���� ����� ����� ���� ������� � ����������
bonusArmor:        ���������� ����� ����� ����.
canBeDominated:
controllable:      ���������� ������, ���� ������ ����� ���� ��� ��������� ������.
dmgBonus:          ���������� ���� �� ����.
dmgMax:            ���������� ������������ ����������� ����� ��������������� ��������� � �������� �� ��������� �����������.
dmgMin:            ���������� ����������� ����������� ����� ��������������� ��������� � �������� �� ��������� �����������.
dayVision:         ���������� �������� ������� entitiy � ������� ����� .
dmgResist:         ���������� ������� ���������� ����������� ����������� �� �����.
health:            ���������� ������� HP ��������.
healthbarOffset:
healthRegen:       ���������� ������� HP ����� �� ����.
items:
level:
magicDmgResist:    ���������� ������� ���������� ���� ����������� �� ������������� �����.
mana:              ���������� ������� ���� ����.
manaRegen:         ���������� ������� ����������� ���� � �����������.
maxHealth:         ���������� ������������ HP ��������.
maxMana:           ���������� ������������ ���� ����.
modifierCount:     ���������� ���������� ������������ � ������� ������������ ����������.
modifiers:
movespeed:         ���������� �������� �������� �������.
neutral:           ���������� ������, ���� ���� �������� ����������� �����, ���� � ��������� ������.
nightVision:       ���������� �������� ������� entitiy � ������ �����.
shop:              ���������� �������� �������� ������� ��������, ������ � ������� ����. ��������� ������ �������� ����� ���� ������� � ����������.
stashItems:
stolenScepter:     ���������� ������, ���� ������ ����� ������������ �������� ������� Aghanim ��� ���������� ����� �������.
summoned:
totalArmor:        ���������� ����� ����� (���� ����� + ����� �����) �� ����.
unitState:         ���������� �������� �������� ��������������� ������ �����.
upgradeableAbilities:
visibleToEnemy:

LuaEntityCreep     
LuaEntityCreep �������� ������� ����� LuaEntityNPC. 
����� ����, ������� �������� ���������� � ���� ��������� ��� ����� ������. 
��� �������� �������, �������, ������� �������� ������� � ����������� ������� �������� ������� ����� ������.

Attributes
spawned:   ����������, ���� ������ ������� ���, ���� � ��������� ������.

Constants
LuaEntityCourier.STATE_IDLE
LuaEntityCourier.STATE_B2BASE
LuaEntityCourier.STATE_DELIVER
LuaEntityCourier.STATE_SECRETSHOP
LuaEntityCourier.STATE_DEAD

Attributes
courState:        ���������� �������� ��������� �������. ��������� ��������������� ������ ����� ���� ������� � ����������.
courStateEntity:  ���������� ������, ������� ��������, ����� �������� / �������� ��������. (���� ����)
flying:           ���������� ������, ���� ������ �����.
respawnTime:      ���������� ����� ���������� ������� �������� (� ����� ������ �������). ���������� 0, ���� ������ ��� �� ����.
spawned:          ���������� ������, ���� ���� ���������

LuaEntityHero
LuaEntityHero �������� ������� ����� LuaEntityNPC. 
����� ����, ������� �������� ����� � ���� ������. 
��� �����, ������� ��� �� �������� ������� ����� ������.

Constants
  Attributes
LuaEntityHero.ATTRIBUTE_STRENGTH
LuaEntityHero.ATTRIBUTE_AGILITY
LuaEntityHero.ATTRIBUTE_INTELLIGENCE

  Attributes
abilityPoints:     Returns the number of not used ability points hero has.
agility:           Returns the base agility of the hero.
agilityTotal:      Returns the total agility of the hero.
currentXP:         Returns the current experience of the hero.
illusion:          Returns true if hero is an illusion, false otherwise.
intellect:         Returns the base intelligence of the hero.
intellectTotal:    Returns the total intelligence of the hero.
playerId:          Returns the player ID of the player that owns the hero.
primaryAttribute:  Returns the primary attribute of the hero.
recentDamage:
reincarnating:
respawnTime:
respawnTimePenalty:
spawnedAt:         Returns when the hero is spawned (in
strength:          Returns the base strengt hof the hero.
strengthTotal:     Returns the total strength of the hero.

