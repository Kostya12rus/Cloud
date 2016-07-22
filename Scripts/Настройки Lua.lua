Script

Functions
Disable():                                              Отключение сценарий пока новая игра не присоединился.
Enable():                                               Позволяет включить сценарий.
RegisterEvent(eventType, function[, optionalParameter): Регистрирует событие и вызывает данную функцию.Необязательный параметр может быть переменной самостоятельно.Список событий можно найти на Global_constants.
Reload():                                               Перезагрузка сценарии.
Unload():                                               Выгрузка сценарий полностью.
UnregisterEvent(function[, optionaParameter):           Удаляет данную функцию из системы событий.

Attributes
disabled:   Возвращает true, если Disable() была вызвана прежде.
filename:   Возвращает полный путь к файлу сценария.
name:       Возвращает имя скрипта.
tablename:  Возвращает имя таблицы окружающей среды сценария.

ScriptEngine

Functions
script GetScript(name):                                       Возвращает скрипт с заданным именем.
boolean IsLoaded(name):                                       Возвращает true, если скрипт с заданным именем будет загружен.
RegisterLibEvent(eventType, function[, optionalParameter):   
Регистрирует событие и вызывает данную функцию. 
Используйте эту функцию только для библиотек, так что они не зависят от сценария, который использует требует в первую очередь.
Необязательный параметр может быть переменной самостоятельно.Список событий можно найти на Global_constants.
UnregisterLibEvent(eventType, function[, optionalParameter):  Удаляет данную функцию из системы событий.

Attributes
count:  Возвращает количество загруженных сценариев.

Client
Класс клиент имеет все функции, необходимые для доступа к данным из Dota, которые непосредственно не связанных с лицами и рисунков.
  
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
CloseShop():                                       Закрывает страницу магазина, если он открыт в настоящее время.
ExecuteCmd(command):                               Выполняет любую возможную команду DOTA. Некоторые могут быть найдены здесь Dota2 Wiki.
string Localize(text): 
Локализует данный текст. Если нет возможности, чтобы преобразовать его, то он будет просто вернуть данную строку. 
Вы можете в основном используют имена | лиц, но вы также можете отформатировать строку получить больше информации, как описание.

AbilityData GetItemData(itemName):                 Получает данные элемента для данного имени. Имена могут быть найдены в "items.txt" и посмотреть, как "item_energy_booster"
boolean GetGroundPosition(position):               Возвращает true, если позиция действует Положение на карте и заполняет z-координату ввода с z-координата карте высоты.
number GetGylphCooldown(team):                     Получает восстановления глифа. Если он выключен, то время восстановления он просто возвращает 0. Команды могут быть найдены в LuaEntity # констант.
string GetKeyBinding(binding):                     Возвращает код ключа для связывания дано. (Например, "dota_ability_execute 0").
OpenShop(shopType):                                Открывает страницу магазина для текущего игрока.
Ping(pingType,position):                           ping определенном месте (видимым для других игроков).
Say(text):                                         Говорит что-то для всех игроков.
SayTeam(text):                                     Говорит что-то в вашу команду.
boolean, screenPosition ScreenPosition(position):  Возвращает положение экрана для положения в игре.Первый логический параметр возвращает true, если лицо видно на экране.
ToggleShop():                                      Переключение страницу магазина.

Attributes
avgLatency:                                        Возвращает среднюю в игре задержка / Ping.
chat:                                              Возвращает true, если чат открыт.
connected:                                         Возвращает true, если он подключен к игре (в том числе экран загрузки).
console:                                           Возвращает истину, если консоль в настоящее время показано на рисунке.
expectedPlayers:                                   Возвращает количество игроков в игре ожидается.
gameDirectory:                                     Возвращает игры каталог Dota2.
gameMode:                                          Возвращает текущий режим игры. Проверьте постоянные.
gameState:                                         См постоянные.
gameTime:                                          Возвращает время внутриигровой.
gameWinner:                                        Возвращает Команда-победитель текущей игры.
language:                                          Возвращает язык, используемый в Dota2. Например: "English".
latency:                                           Возвращает текущую в игре задержка / Ping.
levelName:                                         Возвращает уровень / название карты загруженного в данный момент игры.
loadedPlayers:                                     Возвращает количество загруженных игроков.
loading:                                           Возвращает истину, если в настоящее время подключения к игре, и по-прежнему в экране загрузки.
maxClients:                                        Возвращает количество максимально допустимых клиентов.
mousePosition:                                     Возвращает позицию внутриигровой вашей мыши.
mouseScreenPosition:                               Возвращает положение экрана вашей мыши.
nsNight:                                           Возвращает истину, если конечная NIGHTSTALKER активна.
paused:                                            Возвращает истину, если игра в настоящее время приостановлена.
pauseTeam:                                         Возвращает команду, которая паузу игру.
uiLanguage:                                        Вернуться на языке Dota2 как короткой строки. Например: "EN".
screenSize:                                        Возвращает размер экрана в игре.
screenRatio:                                       Возвращает своего экрана. В основном экране вес / экран высоты.
shopOpen - boolean:                                Возвращает истину, если в данный момент отображается страница магазина.
shopTypeOpen - shopType:                           Возвращает тип магазин, если он в настоящее время открыт.
totalGameTime:                                     Возвращает общее время игры. (Может быть использован для некоторых calulations или метку времени)
viewAngles:                                        Возвращает углы зрения камеры.

LuaEntity
LuaEntities являются классы для всех entites в игре. 
Все из них происходит от класса мастера лицо LuaEntity, большинство лиц находится под некоторых специализированных классов.

LuaEntity
Мастер-класс для всех лиц, но некоторые из лиц использует LuaEntity как своего класса непосредственно.

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
boolean __eq(LuaEntity):                                         Функция равенства. Позволяет двух лицо в сравнении с "==" или "~ ="
number/string GetProperty(ClassName[, TableName], PropertyName): Возвращает свойства объекта, которые могут еще не документированным.
EmitSound(soundFile[, target):                                   Воспроизведение звуковой файл.
StopSound(soundFile):                                            Останавливает звуковой файл (в случае проигрывания).

Attributes
ability:      Идентификатор недвижимости. Возвращает true, если лицо принадлежит к LuaEntityAbility, false в противном случае.
alive:        Возвращает true, если лицо является живым.
bottle:       Идентификатор недвижимости. Возвращает true, если лицо принадлежит к LuaEntityItemBottle, false в противном случае.
classId:      Возвращает числовой идентификатор класса сущности. Все глобалы Класс ID которые документально по крайней ClassIDs.
courier:      Идентификатор недвижимости. Возвращает true, если лицо принадлежит к LuaEntityCourier, false в противном случае.
creep:        Идентификатор недвижимости. Возвращает true, если лицо принадлежит к LuaEntityCreep, false в противном случае.
handle:       Возвращает уникальный идентификатор лица.
hero:         Идентификатор недвижимости. Возвращает true, если лицо принадлежит к LuaEntityHero, false в противном случае.
item:         Идентификатор недвижимости. Возвращает true, если лицо принадлежит к LuaEntityItem, false в противном случае.
itemPhysical: Идентификатор недвижимости. Возвращает true, если лицо принадлежит к LuaEntityItemPhysical, false в противном случае.
name:         Возвращает имя объекта.
npc:          Идентификатор недвижимости. Возвращает true, если лицо принадлежит к LuaEntityNPC, false в противном случае.
owner:        Возвращает владельца сущность к сущности.
position:     Возвращает вектор, позиция лица
powerTreads:  Идентификатор собственности. Возвращает true, если лицо принадлежит к LuaEntityItemPowerTreads, false в противном случае.
rot:          Возвращает вращение лица на XY плоскости в виде степени.
rotR:         Возвращает вращение лица на XY плоскости в виде радиан.
rune:         Идентификатор собственности. Возвращает true, если лицо принадлежит к LuaEntityRune, false в противном случае.
team:         Возвращает числовое значение команды предприятия.
type:
visible:      Возвращает true, если лицо видно, false в противном случае

Player
Игрок ребенок класс LuaEntity. Так как это немного более особенным, чем обычные лиц, вы можете найти его здесь: Player.

LuaEntityNPC
LuaEntityNPC является ребенок класс LuaEntity. 
Любое лицо, которое является блок в игре находится под этого класса. 
Из Рошана и героев вызову и ползает все использует этот класс прямо или косвенно.

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
ability GetAbility(slot):         Возвращает способности в указанном слоте.
item GetItem(slot):               Возвращает элемент в указанном слоте.
boolean HasItem(slot):            Возвращает истину, если есть пункт в указанном слоте, иначе ложь.
boolean IsControllable(playerId): Возвращает истину, если игрок с данной playerId может контролировать эту сущность.


Attributes
activity:          Возвращает числовое деятельность предприятие выполняет. Известные номера активности могут быть найдены в постоянных.
abilities:
ancient:           Возвращает истину, если лицо является древней, ложь в противном случае.
armor:             Возвращает базовый броню лица.
attackBaseTime:
attackRange:       Возвращает диапазон атаки субъекта.
attackSpeed:       Возвращает значение скорости атаки субъекта.
attackType:        Возвращает числовой тип атаки субъекта. Известные номера типа атаки могут быть найдены в постоянных
bonusArmor:        Возвращает бонус броню лица.
canBeDominated:
controllable:      Возвращает истину, если объект может быть под контролем игрока.
dmgBonus:          Возвращает урон от лица.
dmgMax:            Возвращает максимальное повреждение может рассматриваться компанией в качестве их основного повреждения.
dmgMin:            Возвращает минимальное повреждение может рассматриваться компанией в качестве их основного повреждения.
dayVision:         Возвращает диапазон видения entitiy в дневное время .
dmgResist:         Возвращает сколько физическое повреждение уменьшается на брони.
health:            Возвращает текущее HP сущности.
healthbarOffset:
healthRegen:       Возвращает текущую HP реген от лица.
items:
level:
magicDmgResist:    Возвращает сколько магический урон уменьшается на сопротивление магии.
mana:              Возвращает текущую ману лица.
manaRegen:         Возвращает текущую восполнение маны в организации.
maxHealth:         Возвращает максимальное HP сущности.
maxMana:           Возвращает максимальное ману лица.
modifierCount:     Возвращает количество модификатора в таблице модификатора устройства.
modifiers:
movespeed:         Возвращает скорость движения объекта.
neutral:           Возвращает истину, если лицо является нейтральным лицом, ложь в противном случае.
nightVision:       Возвращает диапазон видения entitiy в ночное время.
shop:              Возвращает числовое значение текущих магазины, доступ к которым лица. Известные номера магазина могут быть найдены в постоянных.
stashItems:
stolenScepter:     Возвращает истину, если объект может использовать обновить скипетр Aghanim без проведения самой скипетр.
summoned:
totalArmor:        Возвращает общее броню (база брони + бонус брони) от лица.
unitState:         Возвращает числовое значение государственных флагов блока.
upgradeableAbilities:
visibleToEnemy:

LuaEntityCreep     
LuaEntityCreep является ребенок класс LuaEntityNPC. 
Любое лицо, которое является ползучести в игре находится под этого класса. 
Все переулок ползает, ползает, осадных джунглей ползает и специальных ползает являются членами этого класса.

Attributes
spawned:   Возвращает, если объект породил еще, ложь в противном случае.

Constants
LuaEntityCourier.STATE_IDLE
LuaEntityCourier.STATE_B2BASE
LuaEntityCourier.STATE_DELIVER
LuaEntityCourier.STATE_SECRETSHOP
LuaEntityCourier.STATE_DEAD

Attributes
courState:        Возвращает числовое состояние курьера. Известные государственные номера могут быть найдены в постоянных.
courStateEntity:  Возвращает объект, который приказал, чтобы получить / Доставка элементы. (Если есть)
flying:           Возвращает истину, если курьер летит.
respawnTime:      Возвращает время последнего времени респауна (в форме общего времени). Возвращает 0, если курьер еще не умер.
spawned:          Возвращает истину, если крип появились

LuaEntityHero
LuaEntityHero является ребенок класс LuaEntityNPC. 
Любое лицо, которое является герой в этом классе. 
Все герои, иллюзия или не являются членами этого класса.

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

