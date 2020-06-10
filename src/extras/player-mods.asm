;; future proof this file by adding extended tables and space for external abilities
;; place "ability checks" in places where applicable, as easy injection sites
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

CheckMaxHealth:
    LDA PlayerMaxHealth
    SEC
    BMI +
    ASL
    ASL
    ASL
    ASL
    CLC
    ADC #$0F
    CMP PlayerHealth
+   RTS

Player_PowerCharge:
    LDX #CustomBitFlag_PowerCharge
    LDA #$0
    JSR ChkFlagPlayer
    BNE +
    INC CrouchJumpTimer
    INC CrouchJumpTimer
+   RTS

Player_PowerWalkInvincibility:
	LDY CrouchJumpTimer
	CPY #$3C
    BNE +
    LDX #CustomBitFlag_PowerWalk
    LDA #$0
    JSR ChkFlagPlayer
    BNE +
    LDA PlayerHealth
    CMP #$7F
    BCC +
    LDA StarInvincibilityTimer
    BNE +
    LDA #$4
    STA StarInvincibilityTimer
+   RTS

Player_HiJump:
    LDX #CustomBitFlag_HiJumpBoot
    JSR ChkFlagPlayer2
    BNE +
    LDA PlayerYVelocity
    SBC #$10
	STA PlayerYVelocity
+   RTS

Player_FloatJump:
	LDA Player1JoypadHeld ; holding jump button to fight physics
    AND #ControllerInput_A
    BEQ +
    LDX #CustomBitFlag_FloatBoots
    JSR ChkFlagPlayer2
    BNE +
Player_WallCling:
	LDY PlayerYVelocity 
    BMI +
    CPY #$10
    BCC +
    LDA #$10
    STA PlayerYVelocity
+   RTS

Player_GroundPound:
    LDA Player1JoypadHeld
    AND #ControllerInput_Down
    BEQ +o
    LDX #CustomBitFlag_GroundPound
    JSR ChkFlagPlayer3
    BNE +
    LDA PlayerYVelocity
    BMI +
    CMP #$3F
    BCS ++
    INC PlayerYVelocity
    INC PlayerYVelocity
    JMP +
++
    LDA CrushTimer
    CMP #$24
    BCS ++
    INC CrushTimer
    LDA #$8
    CMP CrushTimer
    BCS +
    LDA #SpriteAnimation_CustomFrame1
    STA PlayerAnimationFrame
    JMP +
++
    LDA StarInvincibilityTimer
    BNE +
    LDA #$4
    STA StarInvincibilityTimer
+   RTS
+o  LDA #$0
    STA CrushTimer
    RTS

Player_GroundPoundHit:
    LDA PlayerYVelocity
    BMI +
    CMP #$3F
    BCC +
    LDA CrushTimer
    CMP #$24
    BCC +
    LDX #CustomBitFlag_GroundPound
    JSR ChkFlagPlayer3
    BNE +
    LDA #$20
    STA POWQuakeTimer
	LDA #SoundEffect3_Rumble_B
	STA SoundEffectQueue3
+
    LDA #$0
    STA CrushTimer
    RTS

ProjectileData:
   .db Enemy_Fireball ;1
   .db Enemy_Egg ;2
   .db Enemy_Bomb ;3
   .db Enemy_Phanto ;4 
   .db Enemy_FryguySplit ;5
   .db Enemy_Fireball ;6
   .db Enemy_Bullet ;7
   .db Enemy_Bomb ;8 
   .db Enemy_Fireball ;9
   .db Enemy_MushroomBlock ;a
   .db Enemy_Fireball ;b
   .db Enemy_Bullet ;b
   .db Enemy_Fireball ;1
   ;;
ProjectileCountData:
   .db $2
   .db $1
   .db $1
   .db $1
   .db $2
   .db $2
   .db $4
   .db $2
   .db $2
   .db $1
   .db $1
   .db $1
   .db $2
   ;;
ProjectileTimerData:
   .db $10
   .db $20
   .db $70
   .db $80
   .db $80
   .db $60
   .db $08
   .db $40
   .db $10
   .db $80
   .db $40
   .db $40
   .db $10

ProjectileMeta:
   .db $41
   .db $0
   .db $0
   .db $0
   .db $0
   .db $40
   .db $60
   .db $60
   .db $44
   .db $60
   .db $60
   .db $08
   .db $40
   
ProjectileProcess:
    TAX
    DEX
	JSR JumpToTableAfterJump
ProjectileProcessTable:
    .dw Projectile_Fling_Speed
    .dw Projectile_Fling_Speed
    .dw Projectile_Bomb
    .dw Projectile_Phanto
    .dw Projectile_Fling_Speed_Hammer
    .dw Projectile_Fling_Speed
    .dw Projectile_Gun
    .dw Projectile_PlaceBomb
    .dw Projectile_Fling_Speed_Hammer
    .dw Projectile_Ladder
    .dw Projectile_SwordBeam
    .dw Projectile_Fling_Speed
    .dw Projectile_Freeze

ProjChar_IsPlayers = %10000000
ProjChar_PuffEnemy = %1000000
ProjChar_Disappear = %100000
ProjChar_Invincible = %10000
ProjChar_Explosion = %1000


Projectile_ThrowAnim:
	LDA #SpriteAnimation_Throwing
	STA PlayerAnimationFrame
	LDA #$02
	STA PlayerWalkFrame
	LDA #$0A
	STA PlayerWalkFrameCounter
    RTS
Projectile_SwordBeam:
    LDX byte_RAM_0
    JSR CheckMaxHealth
    BCS +n
    JSR Projectile_Fling_Speed
    LDA PlayerDirection
    BEQ +
    LDA #$20
    JMP ++
+   LDA #$E0
++  STA ObjectXVelocity, X
	LDA #SoundEffect1_EnemyHit
	STA SoundEffectQueue1
    RTS
+n  LDA #$0
    STA EnemyState, X
    DEC ProjectileNumber
    RTS
Projectile_Gun:
    LDX byte_RAM_0
    LDA PlayerDirection
    BEQ +
    LDA #$70
    JMP ++
+   LDA #$90
++  STA ObjectXVelocity, X
	LDA #SoundEffect1_EnemyHit
	STA SoundEffectQueue1
    JMP Projectile_Fling

Projectile_Freeze:
    JSR Projectile_Fling_Speed
    LDA #$3
    STA MoreEnemyInfo, X
	EOR ObjectAttributes, X 
    STA ObjectAttributes, X
    RTS

Projectile_Fling_Speed_Hammer:
    LDX byte_RAM_0
    LDA #$E0
    STA ObjectYVelocity, X
    DEC EnemyVariable, X
Projectile_Fling_Speed:
    JSR Projectile_ThrowAnim
    LDX byte_RAM_0
    LDA PlayerDirection
    BEQ +
    LDA #$1E
    LDY PlayerXVelocity
    BEQ ++
    BMI ++
    CLC
    ADC #$18
    JMP ++
+   LDA #$E2
    LDY PlayerXVelocity
    BPL ++
    SEC
    SBC #$18
++  STA ObjectXVelocity, X
Projectile_Fling:
    LDX byte_RAM_0
	LDA PlayerXLo
    CLC
    ADC #2
	STA ObjectXLo, X
	LDA PlayerXHi
    ADC #0
	STA ObjectXHi, X
	LDA PlayerYLo
    CLC
    ADC #8
	STA ObjectYLo, X
	LDA PlayerYHi
    ADC #0
    ;; carry page
	STA ObjectYHi, X
    RTS
Projectile_Phanto:
    LDX byte_RAM_0
    LDA #$0
	LDA ScreenYLo
	STA ObjectYLo, X
	LDA ScreenYHi
	STA ObjectYHi, X
	LDA ScreenBoundaryLeftLo
	STA ObjectXLo, X
	LDA ScreenBoundaryLeftHi
	STA ObjectXHi, X
    LDA #$3
	EOR ObjectAttributes, X 
    STA ObjectAttributes, X
    JSR Projectile_ThrowAnim
    RTS

Projectile_Ladder:
    JSR Projectile_Bomb
    LDA #BackgroundTile_LadderStandable
    STA EnemyVariable, X
    RTS
Projectile_PlaceBomb:
    JSR Projectile_Fling
    LDA #$4
	STA EnemyArray_46E, X 
	LDA PlayerXLo
	STA ObjectXLo, X
	LDA PlayerXHi
    ADC #0
	STA ObjectXHi, X
	LDA ObjectXVelocity, X
	BNE +
	STA ObjectYVelocity, X
	JSR SnapEnemy
    JMP PlaceBomb
Projectile_Bomb:
    JSR Projectile_Fling
    LDA #$4
	STA EnemyArray_46E, X 
	LDA Player1JoypadHeld
    AND #ControllerInput_Down
    BNE +
    STX ObjectBeingCarriedIndex
    LDA #$1
    STA HoldingItem
    STA EnemyVariable, X
	STA ObjectBeingCarriedTimer, X
+
PlaceBomb:
    LDA #$3
	EOR ObjectAttributes, X 
    STA ObjectAttributes, X
    LDA #$80
    STA EnemyTimer, X
    RTS

CreateFireballStartForceDefault: 
    LDA ProjectileType
    PHA
    LDY CurrentCharacter
    LDA StartingHold, Y
    AND #$7F
    BEQ +
    STA ProjectileType
+
    JSR CreateFireballStartSkipInput
    PLA
    STA ProjectileType
    RTS

CreateFireballStart: 
	LDA Player1JoypadPress
    AND #ControllerInput_B
	BEQ ++ ;; #ControllerInput_B
    LDA HoldingItem ;; no firing with holding
    BNE ++
CreateFireballStartSkipInput: 
    LDA ProjectileTimer ;; no firing if timer is on
    BNE ++
    LDA ProjectileNumber ;; reset if num is negative
    BPL +
    LDA #0
    STA ProjectileNumber
+
    LDY ProjectileType ;; if no projectile...
    CPY #$0
    BNE +x
    LDX CurrentCharacter
    LDY StartingProjectile, X ;; if no projectile...
    CPY #$0
    BNE +y
    JMP +++
+y  
+c
+x  DEY
    STY byte_RAM_C5
    LDA ProjectileNumber
    CMP ProjectileCountData, Y ;; no firing if above/equal limit
    BCS ++
    LDY ProjectileType
    BNE +k
    LDA DokiMode, X
    AND #CustomCharFlag_WeaponCherry
    BEQ +k
    LDA Level_Count_Cherries
    BEQ +++
    DEC Level_Count_Cherries
+k
	JSR CreateEnemy_TryAllSlots_Bank1
    CPY #$FF
    BNE +
++  JMP +++
+   INC ProjectileNumber
    LDX byte_RAM_0
    LDY byte_RAM_C5 ;; if no projectile...
    LDA ProjectileData, Y
	STA ObjectType, X
    JSR EnemyInit_Basic_Bank1 ; Get current object sprite attributes...

+p  LDY byte_RAM_C5 ;; if no projectile...
    LDA ProjectileMeta, Y
    ORA #$80
    STA Enemy_Fireball_Hits, X
    STA EnemyVariable, X
	LDA EnemyArray_46E, X 
    AND #%11110011
    STA EnemyArray_46E, X
    LDA #$2
	STA EnemyArray_489, X
    LDA #$5
    STA EnemyArray_492, X
	LDA #$01
	STA EnemyArray_42F, X
    LDA #$FF
    STA Enemy_Champion, X
    STA MoreEnemyInfo, X
++  LDY byte_RAM_C5 ;; if no projectile...
    LDA ProjectileTimerData, Y
    STA ProjectileTimer
    TYA
    JSR ProjectileProcess
+++ RTS

StoreItem:
	LDA StoredItem
    BNE +
    LDX #CustomBitFlag_StoreItem
    JSR ChkFlagPlayer
    BEQ +
    LDY CurrentCharacter
    LDA StartingHold, Y
    BNE +
    JMP +++
+
    LDA Player1JoypadHeld
    AND #ControllerInput_Up
    BNE +
    JMP +++
+
    LDA ProjectileTimer
    BEQ +
    JMP SkipOutThrow
+
	LDA StoredItem
    BNE ++
    LDA HoldingItem
    BNE +
    LDY CurrentCharacter
    LDA StartingHold, Y
    BNE ++
    JMP +++
+
	LDX ObjectBeingCarriedIndex
	LDA EnemyState, X
	CMP #EnemyState_Sand
    BNE +
+s  JMP SkipOutThrow
+
    LDX #CustomBitFlag_StoreItem
    JSR ChkFlagPlayer
    BNE ++
    DEC HoldingItem
	LDX ObjectBeingCarriedIndex
    LDA #EnemyState_BlockFizzle
	STA EnemyState, X
    LDA #$14
    STA EnemyTimer, X
    STA ProjectileTimer
    LDA ObjectType, X
    STA StoredItem
    JMP SkipOutThrow
++  LDX ObjectBeingCarriedIndex
    LDA HoldingItem
    BEQ +
    JMP +++
+
    INC HoldingItem
    JSR CreateEnemy_TryAllSlots_Bank1
    LDX byte_RAM_0
    CPY #$FF
    BNE ++
    DEC HoldingItem
    JMP SkipOutThrow
++  STX ObjectBeingCarriedIndex
    LDA StoredItem
    BNE +
    LDY CurrentCharacter
    LDA DokiMode, Y
    AND #CustomCharFlag_StoreCherry
    BEQ ++
    LDA Level_Count_Cherries
    BNE +c 
    LDA #$0
    STA EnemyState, X
    DEC HoldingItem
    JMP SkipOutThrow
+c
    DEC Level_Count_Cherries
++
    LDY CurrentCharacter
    LDA StartingHold, Y
    BPL +
    LDA #$0
    STA EnemyState, X
    DEC HoldingItem
    JSR CreateFireballStartForceDefault
    JMP SkipOutThrow
+
    STA ObjectType, X
    LDA #$20
    STA ProjectileTimer
    JSR EnemyInit_Basic_Bank1 ; Get current object sprite attributes...
	LDA ScreenBoundaryLeftLo
	ADC #$80
	STA ObjectXLo, X
	LDA ScreenBoundaryLeftHi
	ADC #$00
	STA ObjectXHi, X
	LDA ScreenYLo
	STA ObjectYLo, X

	LDA ScreenYHi
	ADC #$00
	STA ObjectYHi, X
    LDA #$1
    STA HoldingItem
    STA EnemyVariable, X
	STA ObjectBeingCarriedTimer, X
    LDA ObjectType, X
    CMP #Enemy_BobOmb
    BEQ +o
    CMP #Enemy_Bomb
    BNE +b
+o  LDA #$50
	STA EnemyTimer, X
+b
    CMP #Enemy_MushroomBlock
    BNE +
    LDA #BackgroundTile_MushroomBlock
    STA EnemyVariable, X
+
    LDA #$0
    STA StoredItem
    JMP SkipOutThrow
+++ 
    RTS
SkipOutThrow:
    PLA
    PLA
    RTS
