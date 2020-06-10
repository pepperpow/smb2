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
LastWarpLoc = $7D0E
LastMusicChoice = $7D0F
ShopInfo = $7D10
WarpDestinationRam = $76cd

PlayerState_Nothing = $9 

SpriteAnimation_CustomFrame1 = #SpriteAnimation_Climbing + 1 ; can't reorganize this since not the entire disasm is compiled right
SpriteAnimation_GroundPound = #SpriteAnimation_Climbing + 1 ; can't reorganize this since not the entire disasm is compiled right

GameMode_JustCharacter = #GameMode_Warp + 1
GameMode_Shop = #GameMode_Warp + 2

CustomBitFlag_PowerThrow = %00000001
CustomBitFlag_PowerCharge = %00000010
CustomBitFlag_PowerWalk = %00000100
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
CustomBitFlag_WarpWhistle = %00100000
CustomBitFlag_WarpSigil = %00100000
CustomBitFlag_Map = %10000000

CustomBitFlag_KirbyJump = %00000001
CustomBitFlag_Grapple = %00000010
CustomBitFlag_SpaceJump = %00000100
CustomBitFlag_BounceJump = %00001000
CustomBitFlag_BounceAll = %00010000
CustomBitFlag_GroundPound = %00100000
CustomBitFlag_WallCling = %01000000
CustomBitFlag_WallJump = %10000000
