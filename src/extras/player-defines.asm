AreaTransitioned_Invuln = $7603
CustomSolid = $77a0
CharacterLock_Variable = $7610
PlayerIntermediateValue = $76cd

Level_Bit_Flags = $7300
World_Bit_Flags = $73D2
Level_Count_Discovery = $73E0
Level_Count_MushCount = $73E1
Level_Count_Coins = $73E2
Level_Count_1ups = $73E3
Level_Count_SubspaceVisits = $73E4
Level_Count_Unlocks = $73E5
Level_Count_BigKill = $73E6
Level_Count_KillCnt = $73E6
Level_Count_LivesLost = $73E7
Level_Count_Crystals = $73E8
Level_Count_Cherries = $73E9
World_Count_Bosses = $73EF
CurrentLevelAreaIndex = $73F0
StatPrintOffset = $73F1
StatPrintCurOffset = $73F2
StatPrintDec = $73F3
StatPrintDecRow = $73F4

PlayerIndependentLives = $73F8
PlayerIndependentMaxHealth = $73FC

CustomBitFlag_Boss_Defeated = %00000010

CustomBitFlag_Visited = %00000001
CustomBitFlag_Mush1 = %00000010
CustomBitFlag_Mush2 = %00000100
CustomBitFlag_1up = %00001000
CustomBitFlag_Sub1 = %00010000
CustomBitFlag_Sub2 = %00100000
CustomBitFlag_Key = %01000000
CustomBitFlag_Crystal = %10000000

CustomCharFlag_Shrinking = %00000001
CustomCharFlag_Running = %00000010
CustomCharFlag_Fluttering = %00000100
CustomCharFlag_PeachWalk = %00001000
CustomCharFlag_WeaponCherry = %00010000
CustomCharFlag_StoreCherry = %00100000
CustomCharFlag_AirControl = %01000000
CustomCharFlag_WideSprite = %10000000

CustomCharFlag_StandStill = %00000001


PlayerLevelPowerup_1 = $7600
PlayerLevelPowerup_2 = $7601
PlayerLevelPowerup_3 = $7602 ; change these slots to only read once, store variable into mushroom
Is_Player_Projectile = $7610 ; combined with hits
Enemy_Fireball_Hits = $7610
MushroomEffect = $7620
Enemy_Champion = $7620
MoreEnemyInfo = $7D20
PlayerModStats = $7630
Independent_Player_Stats = $7691
Player_Bit_Flags = $76E0
Player_Bit_Flags_2 = $76E4
Player_Bit_Flags_3 = $76E8
Player_Luck = $76EC
Player_Cursed = $76ED
Player_CursedPersistence = $76EE
Player_ChampionChance = $76EF
RandomDropType = $76F0
ProjectileType = $76F1
ProjectileNumber = $76F2
ProjectileTimer = $76F3
StoredItem = $76F4
Boss_HP = $76F6
CrushTimer = $76F7
MushroomFragments = $76F8
SpriteTableCustom1 = $7700
SpriteTableCustom2 = $7780
PlayerInventory = $7D00
ReplaceItemSlot = $7D0F
ShopInfo = $7D10
WarpDestinationRam = $76cd

PlayerState_Nothing = $9 

SpriteAnimation_CustomFrame1 = #SpriteAnimation_Climbing + 1 ; can't reorganize this since not the entire disasm is compiled right
SpriteAnimation_GroundPound = #SpriteAnimation_Climbing + 1 ; can't reorganize this since not the entire disasm is compiled right

GameMode_JustCharacter = #GameMode_Warp + 1
GameMode_Shop = #GameMode_Warp + 2

CustomBitFlag_PowerThrow = %00000001
CustomBitFlag_PowerCharge = %00000010
CustomBitFlag_PowerGrip = %00000100
CustomBitFlag_StoreItem = %00001000
CustomBitFlag_FallDefense = %00010000
CustomBitFlag_ImmuneFire = %00100000
CustomBitFlag_ImmuneElec = %01000000
CustomBitFlag_Secret = %10000000

CustomBitFlag_AllTerrain = %00000001
CustomBitFlag_HiJumpBoot = %00000010
CustomBitFlag_FloatBoots = %00000100
CustomBitFlag_MasterKey = %00001000
CustomBitFlag_AirHop = %00010000
CustomBitFlag_BombGlove = %00100000
CustomBitFlag_EggGlove = %01000000
CustomBitFlag_Map = %10000000

CustomBitFlag_KirbyJump = %00000001
CustomBitFlag_Grapple = %00000010
CustomBitFlag_SpaceJump = %00000100
CustomBitFlag_BounceJump = %00001000
CustomBitFlag_BounceAll = %00010000
CustomBitFlag_GroundPound = %00100000
CustomBitFlag_WallCling = %01000000
CustomBitFlag_WallJump = %10000000