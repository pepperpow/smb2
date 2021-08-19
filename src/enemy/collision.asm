;
; Object/background collision that treats non-sky background tiles as solid,
; such as for Sparks and Mushroom Blocks
;
ObjectTileCollision_SolidBackground:
	LDA #$04
	BNE ObjectTileCollision_Main

;
; Normal object/background collision
;
ObjectTileCollision:
	LDA #$00

;
; Object Tile Collision
; =====================
;
; Handles object collision with background tiles
;
; Input
;   A = whether or not to treat walk-through tiles as solid
;   X = enemy index
; Output
;  EnemyCollision, X = collision flags
;
ObjectTileCollision_Main:
	STA byte_RAM_7
	LDA #$00
	STA byte_RAM_B
	STA byte_RAM_E
	JSR ClearDirectionalCollisionFlags

	STA byte_RAM_8
	LDA ObjectYVelocity - 1, X
	BPL ObjectTileCollision_Downward

ObjectTileCollision_Upward:
	JSR CheckEnemyTileCollision

	INC byte_RAM_7
	INC byte_RAM_8
	BNE loc_BANK3_B57B

ObjectTileCollision_Downward:
	INC byte_RAM_7
	INC byte_RAM_8
	JSR CheckEnemyTileCollision

ObjectTileCollision_CheckQuicksand:
	LDA ObjectType - 1, X
	CMP #Enemy_CobratJar
	BEQ ObjectTileCollision_CheckConveyor

	CMP #Enemy_CobratSand
	BEQ ObjectTileCollision_CheckConveyor

IFNDEF ENABLE_TILE_ATTRIBUTES_TABLE
	LDA byte_RAM_0
	SEC
	SBC #BackgroundTile_QuicksandSlow
	CMP #$02
	BCS ObjectTileCollision_CheckConveyor
ELSE
	LDY byte_RAM_0
	LDA TileInteractionAttributesTable, Y
	AND #%00001100
	CMP #%00001000
	BNE ObjectTileCollision_CheckConveyor

	LDA byte_RAM_0
	SEC
	SBC #BackgroundTile_QuicksandSlow
ENDIF

	ASL A
	ADC #$01
	STA ObjectYVelocity - 1, X
	LDA #EnemyState_Sinking
	STA EnemyState - 1, X
	LDA #$FF
	STA EnemyTimer - 1, X

ObjectTileCollision_CheckConveyor:
IFNDEF ENABLE_TILE_ATTRIBUTES_TABLE
	LDA byte_RAM_0
	STA byte_RAM_E

	SEC
	SBC #BackgroundTile_ConveyorLeft
	CMP #$02
	BCS loc_BANK3_B57B

ELSE
	LDY byte_RAM_0
	STY byte_RAM_E

	LDA TileInteractionAttributesTable, Y
	AND #%00001100
	CMP #%00001100

	BNE loc_BANK3_B57B

	TYA
	AND #%00000001
ENDIF

	LDY EnemyArray_438 - 1, X
	BNE loc_BANK3_B57B

	LDY ObjectType - 1, X
	CPY #Enemy_VegetableSmall
	BCC loc_BANK3_B56C

	TAY
	LDA ObjectYVelocity - 1, X
	CMP #$03
	BCS loc_BANK3_B57B

	LDA byte_RAM_D
	AND #$03
	BNE loc_BANK3_B57B

	LDA byte_BANK3_B4E0, Y
	STA ObjectXVelocity - 1, X
	STA byte_RAM_B
	BNE loc_BANK3_B57B

loc_BANK3_B56C:
	LDY ObjectXVelocity - 1, X
	BEQ loc_BANK3_B579

	EOR EnemyMovementDirection - 1, X
	LSR A
	BCS loc_BANK3_B579

	DEC ObjectAnimationTimer - 1, X
	DEC ObjectAnimationTimer - 1, X

loc_BANK3_B579:
	INC ObjectAnimationTimer - 1, X

loc_BANK3_B57B:
	LDA ObjectXVelocity - 1, X
	CLC
	ADC ObjectXAcceleration - 1, X
	BMI loc_BANK3_B587

	INC byte_RAM_7
	INC byte_RAM_8

loc_BANK3_B587:
	JSR CheckEnemyTileCollision

	DEX
	RTS



;
; Check collision attributes for the next two tiles
;
IFNDEF ENABLE_TILE_ATTRIBUTES_TABLE
CheckEnemyTileCollision:
	LDY byte_RAM_8
	JSR sub_BANK3_BB87

	LDY byte_RAM_7
	LDA EnemyTileCollisionTable, Y
	TAY
	LDA byte_RAM_0
	JSR CheckTileUsesCollisionType_Bank3

	BCC CheckEnemyTileCollision_Exit

	LDY byte_RAM_7
	LDA EnemyEnableCollisionFlagTable, Y
	ORA EnemyCollision - 1, X
	STA EnemyCollision - 1, X

ELSE
CheckEnemyTileCollision:
	LDY byte_RAM_8
	JSR sub_BANK3_BB87

	; check tile attributes
	LDY byte_RAM_0
	LDA TileCollisionAttributesTable, Y
	LDY byte_RAM_7
	AND CheckEnemyTileCollisionAttributesTable, Y

	BEQ CheckEnemyTileCollision_Exit

	LDA EnemyEnableCollisionFlagTable, Y
	ORA EnemyCollision - 1, X
	STA EnemyCollision - 1, X
ENDIF

CheckEnemyTileCollision_Exit:
	INC byte_RAM_7
	INC byte_RAM_8
	RTS


;
; Resets directional collision flags and loads collision data pointer
;
; Input
;   X = enemy index
; Output
;   byte_RAM_D = previous collision flags
;   EnemyCollision = collision flags with up/down/left/right disabled
;   A = collision data pointer
;   X = X + 1
;
ClearDirectionalCollisionFlags:
	INX
	LDA EnemyCollision - 1, X
	STA byte_RAM_D
	AND #CollisionFlags_Damage | CollisionFlags_PlayerOnTop | CollisionFlags_PlayerInsideMaybe | CollisionFlags_80
	STA EnemyCollision - 1, X
	LDY EnemyArray_492 - 1, X
	LDA TileCollisionHitboxIndex, Y

ClearDirectionalCollisionFlags_Exit:
	RTS


EnemyTileCollisionTable:
	.db $02 ; jumpthrough bottom (y-velocity < 0)
	.db $01 ; jumpthrough top (y-velocity > 0)
	.db $02 ; jumpthrough right (x-velocity < 0)
	.db $02 ; jumpthrough left (x-velocity > 0)
	.db $00 ; treat background as solid
	.db $00 ; treat background as solid
	.db $00 ; treat background as solid
	.db $00 ; treat background as solid


IFDEF ENABLE_TILE_ATTRIBUTES_TABLE
CheckEnemyTileCollisionAttributesTable:
	.db %00001000 ; bottom (y-velocity < 0)
	.db %00000100 ; top (y-velocity > 0)
	.db %00000010 ; right (x-velocity < 0)
	.db %00000001 ; left (x-velocity > 0)
	.db %10001000 ; background-interactive bottom (y-velocity < 0)
	.db %01000100 ; background-interactive top (y-velocity > 0)
	.db %00100010 ; background-interactive right (x-velocity < 0)
	.db %00010001 ; background-interactive left (x-velocity > 0)
ENDIF

EnemyEnableCollisionFlagTable:
	.db CollisionFlags_Up
	.db CollisionFlags_Down
	.db CollisionFlags_Left
	.db CollisionFlags_Right
	.db CollisionFlags_Up
	.db CollisionFlags_Down
	.db CollisionFlags_Left
	.db CollisionFlags_Right

; =============== S U B R O U T I N E =======================================

sub_BANK3_B5CC:
	LDA #$00
	STA ObjectXAcceleration, X
	LDA EnemyCollision, X
	AND #CollisionFlags_Right | CollisionFlags_Left | CollisionFlags_Down | CollisionFlags_Up
	STA EnemyCollision, X
	LDA EnemyState, X
	CMP #EnemyState_BombExploding
	BNE loc_BANK3_B5E1

	LDY #$06
	BNE loc_BANK3_B5FF

loc_BANK3_B5E1:
	CMP #EnemyState_Sinking
	BEQ loc_BANK3_B5F8

	LDY ObjectType, X
	CPY #Enemy_Egg
	BEQ loc_BANK3_B5F4

	CPY #Enemy_Pokey
	BEQ loc_BANK3_B5F4

	LDY EnemyArray_42F, X
	BNE loc_BANK3_B5F8

loc_BANK3_B5F4:
	CMP #$01
	BNE ClearDirectionalCollisionFlags_Exit

loc_BANK3_B5F8:
	LDA ObjectBeingCarriedTimer, X
	BNE ClearDirectionalCollisionFlags_Exit

	LDY EnemyArray_489, X

loc_BANK3_B5FF:
	LDA ObjectCollisionHitboxRight_RAM, Y
	STA byte_RAM_9
	LDA #$00
	STA byte_RAM_0
	LDA ObjectCollisionHitboxLeft_RAM, Y
	BPL loc_BANK3_B60F

	DEC byte_RAM_0

loc_BANK3_B60F:
	CLC
	ADC ObjectXLo, X
	STA byte_RAM_5
	LDA ObjectXHi, X
	ADC byte_RAM_0
	STA byte_RAM_1
	LDA IsHorizontalLevel
	BNE loc_BANK3_B620

	STA byte_RAM_1

loc_BANK3_B620:
	LDA ObjectCollisionHitboxBottom_RAM, Y
	STA byte_RAM_B
	LDA #$00
	STA byte_RAM_0
	LDA ObjectCollisionHitboxTop_RAM, Y
	BPL loc_BANK3_B630

	DEC byte_RAM_0

loc_BANK3_B630:
	CLC
	ADC ObjectYLo, X
	STA byte_RAM_7
	LDA ObjectYHi, X
	ADC byte_RAM_0
	STA byte_RAM_3

loc_BANK3_B63B:
	STX byte_RAM_ED
	TXA
	BNE loc_BANK3_B661

	LDA PlayerInRocket
	ORA PlayerLock
	BNE loc_BANK3_B64E

	LDA EnemyState - 1, X
	CMP #$02
	BCC loc_BANK3_B651 ; branch if A < $02

loc_BANK3_B64E:
	JMP loc_BANK3_B6F0

; ---------------------------------------------------------------------------

loc_BANK3_B651:
	LDY byte_RAM_12
	LDA EnemyArray_42F, Y
	BEQ loc_BANK3_B65C

	CMP #$20
	BCC loc_BANK3_B64E

loc_BANK3_B65C:
	LDY PlayerDucking
	JMP loc_BANK3_B6A6

; ---------------------------------------------------------------------------

loc_BANK3_B661:
	LDY byte_RAM_12
	LDA EnemyState, Y
	CMP #EnemyState_BombExploding
	BEQ loc_BANK3_B671

	LDA EnemyArray_46E, Y
	AND #%00000100
	BNE loc_BANK3_B690

loc_BANK3_B671:
	LDA EnemyState - 1, X
	CMP #EnemyState_BombExploding ; what does this mean for an enemy?
	BNE loc_BANK3_B67B

	LDY #$06
	BNE loc_BANK3_B6A6

loc_BANK3_B67B:
	CMP #EnemyState_Sinking
	BEQ loc_BANK3_B692

	LDY ObjectType - 1, X
	CPY #Enemy_Egg
	BEQ loc_BANK3_B68E

	CPY #Enemy_Pokey
	BEQ loc_BANK3_B68E

	LDY EnemyArray_42F - 1, X
	BNE loc_BANK3_B692

loc_BANK3_B68E:
	CMP #$01

loc_BANK3_B690:
	BNE loc_BANK3_B6F0

loc_BANK3_B692:
	LDA ObjectBeingCarriedTimer - 1, X
	BNE loc_BANK3_B6F0

	LDA EnemyCollision - 1, X
	AND #CollisionFlags_Damage
	BNE loc_BANK3_B6F0

	LDA EnemyArray_46E - 1, X
	AND #$04
	BNE loc_BANK3_B6F0

	LDY EnemyArray_489 - 1, X

loc_BANK3_B6A6:
	LDA ObjectCollisionHitboxRight_RAM, Y
	STA byte_RAM_A
	LDA #$00
	STA byte_RAM_0
	LDA ObjectCollisionHitboxLeft_RAM, Y
	BPL loc_BANK3_B6B6

	DEC byte_RAM_0

loc_BANK3_B6B6:
	CLC
	ADC ObjectXLo - 1, X
	STA byte_RAM_6
	LDA ObjectXHi - 1, X
	ADC byte_RAM_0
	STA byte_RAM_2
	LDA IsHorizontalLevel
	BNE loc_BANK3_B6C7

	STA byte_RAM_2

loc_BANK3_B6C7:
	LDA ObjectCollisionHitboxBottom_RAM, Y
	STA byte_RAM_C
	LDA #$00
	STA byte_RAM_0
	LDA ObjectCollisionHitboxTop_RAM, Y
	BPL loc_BANK3_B6D7

	DEC byte_RAM_0

loc_BANK3_B6D7:
	CLC
	ADC ObjectYLo - 1, X
	STA byte_RAM_8
	LDA ObjectYHi - 1, X
	ADC byte_RAM_0
	STA byte_RAM_4
	JSR sub_BANK3_BDC5

	BCS loc_BANK3_B6F0

	LDA byte_RAM_B
	PHA
	JSR EnemyCollisionBehavior

	PLA
	STA byte_RAM_B

loc_BANK3_B6F0:
	DEX
	BMI loc_BANK3_B6F6

	JMP loc_BANK3_B63B

; ---------------------------------------------------------------------------

loc_BANK3_B6F6:
	LDX byte_RAM_12

locret_BANK3_B6F8:
	RTS

; End of function sub_BANK3_B5CC

; =============== S U B R O U T I N E =======================================

EnemyCollisionBehavior:
	TXA
	BNE EnemyCollisionBehavior_ReadCollisionType

	LDA HoldingItem
	BEQ EnemyCollisionBehavior_ReadCollisionType

	LDA ObjectBeingCarriedIndex
	CMP byte_RAM_12
	BEQ locret_BANK3_B6F8

EnemyCollisionBehavior_ReadCollisionType:
	LDY byte_RAM_12
	LDA ObjectType, Y
	TAY
	LDA unk_RAM_71D1, Y
	JSR JumpToTableAfterJump

	.dw EnemyCollisionBehavior_Enemy
	.dw EnemyCollisionBehavior_ProjectileItem
	.dw EnemyCollisionBehavior_Object
	.dw EnemyCollisionBehavior_POW
	.dw EnemyCollisionBehavior_Door


EnemyCollisionBehavior_Door:
	TXA
	BNE EnemyCollisionBehavior_Exit

	LDA Player1JoypadPress
	AND #ControllerInput_Up
	BEQ EnemyCollisionBehavior_Exit

	LDA PlayerCollision
	AND #CollisionFlags_Down
	BEQ EnemyCollisionBehavior_Exit

	LDA byte_RAM_426
	CMP #$FA
	BCS EnemyCollisionBehavior_Exit

	LDA DoorAnimationTimer
	ORA SubspaceDoorTimer
	BNE EnemyCollisionBehavior_Exit

	LDA HoldingItem
	BEQ loc_BANK3_B749

	LDY ObjectBeingCarriedIndex
	LDA ObjectType, Y
	CMP #Enemy_Key
	BNE EnemyCollisionBehavior_Exit

loc_BANK3_B749:
	LDY byte_RAM_12
	LDA ObjectXLo, Y
	STA PlayerXLo
	LDA ObjectXHi, Y
	STA PlayerXHi
	JSR StashPlayerPosition

	LDA #TransitionType_SubSpace
	STA TransitionType
	JMP DoorHandling_GoThroughDoor_Bank3

EnemyCollisionBehavior_Exit:
	RTS


EnemyCollisionBehavior_Enemy:
	LDY byte_RAM_12
	TXA
	BEQ CheckCollisionWithPlayer

	LDA EnemyArray_45C, Y
	ORA EnemyArray_45C - 1, X
	BNE EnemyCollisionBehavior_Exit

	LDA EnemyArray_42F, Y
	BNE loc_BANK3_B792

	LDA EnemyState, Y
	CMP #EnemyState_BombExploding
	BEQ loc_BANK3_B792

	TXA
	TAY
	DEY
	LDX byte_RAM_12
	INX
	LDA EnemyState, Y
	CMP #EnemyState_BombExploding
	BEQ loc_BANK3_B792

	LDA EnemyArray_42F, Y
	BEQ loc_BANK3_B7E0

	LDA EnemyCollision - 1, X
	AND #CollisionFlags_Damage
	BNE loc_BANK3_B7E0

loc_BANK3_B792:
	LDA EnemyArray_453, Y
	ORA EnemyArray_45C, Y
	BNE loc_BANK3_B7D7

	LDA EnemyArray_46E, Y
	AND #%00001000
	BEQ loc_BANK3_B7A4

	JSR PlayBossHurtSound

loc_BANK3_B7A4:
	LDA EnemyHP, Y
	SEC
	SBC #$01
	STA EnemyHP, Y
	BMI loc_BANK3_B7BD

	JSR PlayBossHurtSound

	LDA #$21
	STA EnemyArray_45C, Y
	LSR A
	STA EnemyArray_438, Y
	BNE loc_BANK3_B7D7

loc_BANK3_B7BD:
	LDA EnemyCollision, Y
	ORA #CollisionFlags_Damage
	STA EnemyCollision, Y
	LDA #$E0
	STA ObjectYVelocity, Y
	LDA ObjectXVelocity, Y
	STA byte_RAM_0
	ASL A
	ROR byte_RAM_0
	LDA byte_RAM_0
	STA ObjectXVelocity, Y

loc_BANK3_B7D7:
	LDA ObjectType - 1, X
	CMP #Enemy_VegetableSmall
	BCS loc_BANK3_B7E0

	JSR sub_BANK3_BA5D

loc_BANK3_B7E0:
	LDX byte_RAM_ED
	RTS

; ---------------------------------------------------------------------------
InvincibilityKill_VelocityX:
	.db $F8 ; to the left
	.db $08 ; to the right
; ---------------------------------------------------------------------------

CheckCollisionWithPlayer:
	LDA byte_RAM_EE
	AND #CollisionFlags_Up
	BNE CheckCollisionWithPlayer_Exit

	; check if it's a heart
	LDA ObjectType, Y
	BNE CheckCollisionWithPlayer_NotHeart

	; accept the heart into your life
	STA EnemyState, Y
	LDA #SoundEffect1_CherryGet
	STA SoundEffectQueue1
IFDEF HEALTH_REVAMP
    LDA PlayerMaxHealth
    BMI +
    LDA PlayerHealth
    ADC #$10
    STA PlayerHealth
    LDA PlayerMaxHealth
    ASL
    ASL
    ASL
    ASL
    CLC
    ADC #$1F
    CMP PlayerHealth
    BCS +
    STA PlayerHealth
+
    JMP CheckCollisionWithPlayer_Exit
ENDIF
IFNDEF HEALTH_REVAMP
	LDY PlayerMaxHealth
	LDA PlayerHealth
	CLC
	ADC #$10
	STA PlayerHealth
	CMP PlayerHealthValueByHeartCount, Y
	BCC CheckCollisionWithPlayer_Exit

	JMP RestorePlayerToFullHealth
ENDIF

; ---------------------------------------------------------------------------

CheckCollisionWithPlayer_NotHeart:
	CMP #Enemy_Phanto
	BNE CheckCollisionWithPlayer_NotPhanto

IFDEF PHANTO_CUSTOM
	LDY PhantoActivateTimer
	CPY #$FF
	BEQ CheckCollisionWithPlayer_NotPhanto
ENDIF
	LDY PhantoActivateTimer
	BNE CheckCollisionWithPlayer_Exit

CheckCollisionWithPlayer_NotPhanto:
	CMP #Enemy_Starman
	BNE CheckCollisionWithPlayer_NotStarman

	LDA #$3F
	STA StarInvincibilityTimer
	LDA #Music1_Invincible
	STA MusicQueue1
	LDA #EnemyState_Inactive
	STA EnemyState, Y

CheckCollisionWithPlayer_Exit:
	RTS

; ---------------------------------------------------------------------------

CheckCollisionWithPlayer_NotStarman:
	CMP #Enemy_WhaleSpout
	BNE CheckCollisionWithPlayer_NotWhaleSpout

	LDA EnemyVariable, Y
	CMP #$DC
	BCS CheckCollisionWithPlayer_Exit2

	LDA StarInvincibilityTimer
	BEQ CheckCollisionWithPlayer_NotInvincible

	LDA #$DC
	STA EnemyVariable, Y
	LDA #$00
	STA ObjectYVelocity, Y

CheckCollisionWithPlayer_Exit2:
	RTS

; ---------------------------------------------------------------------------

CheckCollisionWithPlayer_NotWhaleSpout:
	CMP #Enemy_Wart
	BNE CheckCollisionWithPlayer_NotWart

	LDA EnemyArray_B1, X
	BNE CheckCollisionWithPlayer_Exit2

CheckCollisionWithPlayer_NotWart:
	LDY StarInvincibilityTimer
	BEQ CheckCollisionWithPlayer_NotInvincible

	; player is invincible
	LDX byte_RAM_12
	CMP #Enemy_AutobombFire
	BEQ CheckCollisionWithPlayer_Poof

	CMP #Enemy_Fireball
	BNE CheckCollisionWithPlayer_KillEnemy

; turn into a puff of smoke
CheckCollisionWithPlayer_Poof:
	LDA #%00000000
	STA EnemyArray_46E, X
	JSR EnemyBehavior_Shell_Destroy

	JMP loc_BANK3_B878

; ---------------------------------------------------------------------------

; die and fall off
CheckCollisionWithPlayer_KillEnemy:
	JSR EnemyFindWhichSidePlayerIsOn

	LDA InvincibilityKill_VelocityX, Y
	STA ObjectXVelocity, X
	LDA #$E0
	STA ObjectYVelocity, X
	LDA EnemyCollision, X
	ORA #CollisionFlags_Damage
	STA EnemyCollision, X

loc_BANK3_B878:
	LDX byte_RAM_ED
	LDY byte_RAM_12
	RTS

; ---------------------------------------------------------------------------

CheckCollisionWithPlayer_NotInvincible:
	LDY byte_RAM_12
	LDA EnemyState, Y
	CMP #EnemyState_BombExploding
	BEQ CheckCollisionWithPlayer_HurtPlayer

	; should we damage the player for jumping on top?
	LDA EnemyArray_46E, Y
	AND #%00000001
	BNE CheckCollisionWithPlayer_HurtPlayer

IFDEF RANDOMIZER_FLAGS
    JSR JumpAttack
	LDX byte_RAM_ED
	LDY byte_RAM_12
ENDIF

	; let player land on top
	JSR DetermineCollisionFlags

	LDA byte_RAM_F
	AND #$0B
	BEQ CheckCollisionWithPlayer_StandingOnHead

CheckCollisionWithPlayer_HurtPlayer:
	JMP DamagePlayer


CheckCollisionWithPlayer_StandingOnHead:
	LDA #$00
	STA PlayerInAir
	LDX byte_RAM_12
	LDA EnemyCollision, X
	ORA #CollisionFlags_PlayerOnTop
	STA EnemyCollision, X

	; can you even lift
	LDA EnemyArray_46E, X
	AND #%00000010
	BNE CheckCollisionWithPlayer_NoLift
	; check B button
	BIT Player1JoypadPress
	BVC CheckCollisionWithPlayer_NoLift

	; bail if we already have an item or are ducking
	LDA HoldingItem
	ORA PlayerDucking
	BNE CheckCollisionWithPlayer_NoLift

	STA EnemyCollision, X
	STX ObjectBeingCarriedIndex
	STA ObjectShakeTimer, X
	LDA #$07
	STA ObjectBeingCarriedTimer, X
	JSR SetPlayerStateLifting

	; leave a flying carpet behind if we're picking up pidgit
	LDA ObjectType, X
	CMP #Enemy_Pidgit
	BNE CheckCollisionWithPlayer_NoLift

	JSR CreateFlyingCarpet

CheckCollisionWithPlayer_NoLift:
	LDX byte_RAM_ED
	RTS

; End of function CheckCollisionWithPlayer_StandingOnHead

; ---------------------------------------------------------------------------

EnemyCollisionBehavior_Object:
	LDY byte_RAM_12
	TXA
	BEQ loc_BANK3_B905

	LDA ObjectType, Y
	CMP #Enemy_Key
	BNE loc_BANK3_B8E4

	LDA EnemyCollision, Y
	AND #CollisionFlags_Down
	BNE locret_BANK3_B902

loc_BANK3_B8E4:
	LDA EnemyArray_42F, Y
	BNE loc_BANK3_B8FF

	JSR DetermineCollisionFlags

	LDA byte_RAM_F
	AND EnemyMovementDirection - 1, X
	BEQ loc_BANK3_B8F8

	DEX
	JSR EnemyBehavior_TurnAround

	LDX byte_RAM_ED

loc_BANK3_B8F8:
	JSR sub_BANK3_BB31

	CPY #$00
	BEQ locret_BANK3_B902

loc_BANK3_B8FF:
	JMP loc_BANK3_B9EA

; ---------------------------------------------------------------------------

locret_BANK3_B902:
	RTS

; ---------------------------------------------------------------------------
unk_BANK3_B903:
	.db $08
	.db $04
; ---------------------------------------------------------------------------

; collision with items that the player can stand on
loc_BANK3_B905:
	LDA EnemyCollision, Y
	ORA #CollisionFlags_PlayerInsideMaybe
	STA EnemyCollision, Y
	JSR DetermineCollisionFlags

	LDA byte_RAM_F
	AND PlayerMovementDirection
	BEQ loc_BANK3_B919

	JSR PlayerHorizontalCollision

loc_BANK3_B919:
	LDA byte_RAM_F
	AND #$04
	BEQ loc_BANK3_B922

	JSR CheckCollisionWithPlayer_StandingOnHead

loc_BANK3_B922:
	JSR sub_BANK3_BB31

	CPY #$01
	BNE locret_BANK3_B955

	LDY byte_RAM_12
	LDA ObjectYVelocity, Y
	BEQ locret_BANK3_B955

	AND #$80
	ASL A
	ROL A
	TAY
	LDA byte_RAM_F
	AND unk_BANK3_B903, Y
	BEQ locret_BANK3_B955

	LDY byte_RAM_12
	LDA ObjectYVelocity, Y
	EOR #$FF
	CLC
	ADC #$01
	STA ObjectYVelocity, Y
	LDA #$01
	STA PlayerDucking
	LDA #$04
	STA PlayerAnimationFrame
	LDA #$10
	STA PlayerStateTimer

locret_BANK3_B955:
	RTS

EnemyCollisionBehavior_POW:
	TXA
	BEQ locret_BANK3_B955
	JMP loc_BANK3_B9EA

EnemyCollisionBehavior_ProjectileItem:
	LDY byte_RAM_12
	TXA

loc_BANK3_B95F:
	BNE loc_BANK3_B993

	LDA EnemyState, Y

loc_BANK3_B964:
	CMP #$04
	BNE loc_BANK3_B96E

	LDA StarInvincibilityTimer
	BEQ loc_BANK3_B990

locret_BANK3_B96D:
	RTS

; ---------------------------------------------------------------------------

loc_BANK3_B96E:
	JSR DetermineCollisionFlags

	LDA byte_RAM_F
	AND #$08
	BEQ loc_BANK3_B987

	LDA HoldingItem
	BNE locret_BANK3_B96D

	LDY byte_RAM_12
	STY ObjectBeingCarriedIndex
	LDA #$01
	STA ObjectBeingCarriedTimer, Y
	INC HoldingItem

loc_BANK3_B987:
	LDA byte_RAM_F
	AND #$04
	BEQ locret_BANK3_B96D

	JMP CheckCollisionWithPlayer_StandingOnHead

; ---------------------------------------------------------------------------

loc_BANK3_B990:
	JMP DamagePlayer

; ---------------------------------------------------------------------------

loc_BANK3_B993:
	LDA ObjectType - 1, X
	CMP #Enemy_Wart
	BNE loc_BANK3_B9B7

	LDA EnemyTimer - 1, X
	BEQ locret_BANK3_B9F9

	LDA #$00
	STA EnemyState, Y
	JSR sub_BANK3_BA5D

	LDA #$60
	STA EnemyArray_45C - 1, X
	LSR A
	STA EnemyArray_438 - 1, X
	LDA EnemyHP - 1, X
	BNE locret_BANK3_B9B6

	INC ScrollXLock

locret_BANK3_B9B6:
	RTS

; ---------------------------------------------------------------------------

loc_BANK3_B9B7:
	CMP #$32
	BCS locret_BANK3_B9B6

	CMP #$11
	BNE loc_BANK3_B9CA

	LDA #$05
	STA EnemyState, Y
	LDA #$1E
	STA EnemyTimer, Y
	RTS

; ---------------------------------------------------------------------------

loc_BANK3_B9CA:
	LDA EnemyState, Y
	CMP #$04
	BEQ loc_BANK3_B9EC

	LDA ObjectType, Y
	CMP #Enemy_Shell
	BEQ loc_BANK3_B9EA

	LDA #$E8
	STA ObjectYVelocity, Y
	STX byte_RAM_0
	LDX ObjectXVelocity, Y
	BMI loc_BANK3_B9E5

	LDA #$18

loc_BANK3_B9E5:
	STA ObjectXVelocity, Y
	LDX byte_RAM_0

loc_BANK3_B9EA:
	LDY byte_RAM_12

loc_BANK3_B9EC:
	JSR sub_BANK3_BA5D

	BNE locret_BANK3_B9F9

	LDA ObjectXVelocity - 1, X
	ASL A
	ROR ObjectXVelocity - 1, X
	ASL A
	ROR ObjectXVelocity - 1, X

locret_BANK3_B9F9:
	RTS

; ---------------------------------------------------------------------------

DamagePlayer:
IFDEF DAMAGE_RESIST
	.include "src/extras/damage-resist.asm"
ENDIF
	LDA DamageInvulnTime
	BNE locret_BANK3_BA31

	LDA PlayerHealth
	SEC
	SBC #$10
	BCC loc_BANK3_BA32

	STA PlayerHealth
	LDY #$7F
	STY DamageInvulnTime
	LDY #$00
	STY PlayerYVelocity
	STY PlayerXVelocity
	CMP #$10
	BCC loc_BANK3_BA2C

	LDA PlayerScreenX
	SEC
	SBC SpriteTempScreenX
	ASL A
	ASL A
	STA PlayerXVelocity
	LDA #$C0
	LDY PlayerYVelocity
	BPL loc_BANK3_BA2A

	LDA #$00

loc_BANK3_BA2A:
	STA PlayerYVelocity

loc_BANK3_BA2C:
	LDA #DPCM_PlayerHurt
	STA DPCMQueue

locret_BANK3_BA31:
	RTS

; ---------------------------------------------------------------------------

loc_BANK3_BA32:
	TXA

loc_BANK3_BA33:
	PHA
	LDX byte_RAM_12
	LDA ObjectType, X
	CMP #Enemy_BeezoDiving
	BCS loc_BANK3_BA48

	JSR EnemyFindWhichSidePlayerIsOn

	INY
	TYA
	CMP EnemyMovementDirection, X
	BEQ loc_BANK3_BA48

	JSR EnemyBehavior_TurnAround

loc_BANK3_BA48:
	PLA
	TAX
	LDA #$C0
	STA PlayerYVelocity

loc_BANK3_BA4E:
	LDA #$20
	STA PlayerStateTimer
	LDY byte_RAM_12
	BMI loc_BANK3_BA5A

	LSR A
	STA EnemyArray_438, Y

loc_BANK3_BA5A:
	JMP KillPlayer

; =============== S U B R O U T I N E =======================================

; Damage enemy
sub_BANK3_BA5D:
	LDA EnemyArray_453 - 1, X
	ORA EnemyArray_45C - 1, X
	BNE locret_BANK3_BA94

	LDA EnemyArray_46E - 1, X
	AND #Enemy_Ostro
	BEQ EnemyTakeDamage

	JSR PlayBossHurtSound

EnemyTakeDamage:
	DEC EnemyHP - 1, X ; Subtract hit point
IFDEF CUSTOM_MUSH
	LDA ObjectXVelocity, Y
    BPL +
    CMP #$CA
    BCC +++ 
    JMP ++
+   CMP #$36
    BCS +++
    JMP ++
+++ 
ENDIF
IFDEF RANDOMIZER_FLAGS
DamageEnemySingle:
    DEC EnemyHP - 1, X
++
    LDA EnemyHP - 1, X
ENDIF
	BMI EnemyKnockout

	LDA #$21 ; Flash
	STA EnemyArray_45C - 1, X
	LSR A

loc_BANK3_BA7A:
	STA EnemyArray_438 - 1, X

; End of function sub_BANK3_BA5D

PlayBossHurtSound:
	LDA #DPCM_BossHurt
	STA DPCMQueue
	RTS

; ---------------------------------------------------------------------------

EnemyKnockout:
	LDA EnemyCollision - 1, X
	ORA #CollisionFlags_Damage
	STA EnemyCollision - 1, X
	LDA #$E0
	STA ObjectYVelocity - 1, X
	LDA ObjectXVelocity, Y
	STA ObjectXVelocity - 1, X
	LDA #$00

locret_BANK3_BA94:
	RTS

;
; Determines the collision flags for two objects
;
; Input:
;   RAM_12 = main object
;   X = collision object (usually player?)
; Output:
;   byte_RAM_F = collision flags
;
DetermineCollisionFlags:
	LDA #$00
	STA byte_RAM_F
	LDY byte_RAM_12 ; stash Y
	LDA byte_RAM_427
	CMP #$F6
	BCS DetermineCollisionFlags_Y

	LDA ObjectXLo, Y
	LDY #CollisionFlags_Left
	CMP ObjectXLo - 1, X
	BMI DetermineCollisionFlags_SetFlagsX

	LDY #CollisionFlags_Right

DetermineCollisionFlags_SetFlagsX:
	STY byte_RAM_F
	TYA
	AND EnemyMovementDirection - 1, X
	BEQ DetermineCollisionFlags_ExitX

	LDY byte_RAM_12 ; restore Y
	LDA unk_RAM_4A4, Y
	BNE DetermineCollisionFlags_ExitX

	; @TODO: Looks like a way to make objects move together horizontally
	LDA ObjectXVelocity, Y
	STA ObjectXAcceleration - 1, X

DetermineCollisionFlags_ExitX:
	RTS


DetermineCollisionFlags_Y:
	LDA ObjectYLo, Y
	CPX #$01
	BCS loc_BANK3_BAD1

	PHA
	LDY PlayerDucking
	PLA
	SEC
	SBC byte_BANK3_BB2F, Y

loc_BANK3_BAD1:
	CMP ObjectYLo - 1, X
	BMI loc_BANK3_BB02

	LDA ObjectYVelocity - 1, X
	BMI DetermineCollisionFlags_ExitY

	LDY byte_RAM_12
	LDA unk_RAM_4A4, Y
	BNE loc_BANK3_BAE6

	LDA ObjectXVelocity, Y
	STA ObjectXAcceleration - 1, X

loc_BANK3_BAE6:
	LDY #$00
	INC byte_RAM_427
	INC byte_RAM_427
	BPL loc_BANK3_BAF1

	DEY

loc_BANK3_BAF1:
	LDA byte_RAM_427
	CLC
	ADC ObjectYLo - 1, X
	STA ObjectYLo - 1, X
	TYA
	ADC ObjectYHi - 1, X
	STA ObjectYHi - 1, X
	LDY #CollisionFlags_Down
	BNE loc_BANK3_BB13

loc_BANK3_BB02:
	LDA ObjectYVelocity - 1, X
	BEQ loc_BANK3_BB11

	BPL DetermineCollisionFlags_ExitY

	LDY byte_RAM_12
	LDA ObjectType, Y
	CMP #Enemy_Coin
	BEQ DetermineCollisionFlags_ExitY

loc_BANK3_BB11:
	LDY #CollisionFlags_Up

loc_BANK3_BB13:
	STY byte_RAM_F
	LDY byte_RAM_12
	LDA unk_RAM_4A4, Y
	BNE loc_BANK3_BB22

	; @TODO: Looks like a way to make objects move together vertically
	LDA ObjectYVelocity, Y
	STA ObjectYAcceleration - 1, X

loc_BANK3_BB22:
	LDA #$00
	STA ObjectYVelocity - 1, X
	LDA ObjectYSubpixel, Y
	STA ObjectYSubpixel - 1, X
	INC ObjectAnimationTimer - 1, X

DetermineCollisionFlags_ExitY:
	RTS


byte_BANK3_BB2F:
	.db $0B
	.db $10

; =============== S U B R O U T I N E =======================================

sub_BANK3_BB31:
	LDY #$00
	LDA EnemyCollision - 1, X
	ORA byte_RAM_F
	AND #$0C
	CMP #$0C
	BEQ loc_BANK3_BB48

	LDA EnemyCollision - 1, X
	ORA byte_RAM_F
	AND #CollisionFlags_Right | CollisionFlags_Left
	CMP #CollisionFlags_Right | CollisionFlags_Left
	BNE locret_BANK3_BB49

	INY

loc_BANK3_BB48:
	INY

locret_BANK3_BB49:
	RTS

; End of function sub_BANK3_BB31

; ---------------------------------------------------------------------------
_unused_BANK3_BB4A:
	.db $FF ; May not be used, but wasn't marked as data
	.db $FF
	.db $FF
	.db $FF
	.db $FF
	.db $FF

; Hoopstar will climb up and down any of these tiles
HoopstarClimbTiles:
	.db BackgroundTile_Vine
	.db BackgroundTile_VineStandable
	.db BackgroundTile_VineBottom
	.db BackgroundTile_ClimbableSky
	.db BackgroundTile_Chain
	.db BackgroundTile_Ladder
	.db BackgroundTile_LadderShadow
	.db BackgroundTile_LadderStandable
	.db BackgroundTile_LadderStandableShadow
	.db BackgroundTile_ChainStandable


EnemyBehavior_Hoopstar_CheckBackgroundTile:
	JSR sub_BANK3_BB87

	LDA byte_RAM_0

	LDY #$09
EnemyBehavior_Hoopstar_CheckBackgroundTile_Loop:
	CMP HoopstarClimbTiles, Y
	BEQ EnemyBehavior_Hoopstar_CheckBackgroundTile_Exit
	DEY
	BPL EnemyBehavior_Hoopstar_CheckBackgroundTile_Loop

	CLC

EnemyBehavior_Hoopstar_CheckBackgroundTile_Exit:
	RTS


ItemCarryYOffsets:
	.db $F9
	.db $FF
	.db $00
	.db $08
	.db $0C
	.db $18
	.db $1A
	.db $01
	.db $06
	.db $0A
	.db $0C
	.db $18
	.db $1A
	.db $1C
	.db $FF
	.db $FF
	.db $00
	.db $00
	.db $00
	.db $00
	.db $00
	.db $00
	.db $00
	.db $00
	.db $00
	.db $00
	.db $00
	.db $00


; =============== S U B R O U T I N E =======================================

;
; Seems to determine what kind of tile the object has collided with?
;
; Duplicate of subroutine in bank 0: sub_BANK0_924F
;
; Input
;   X = object index (0 = player)
;   Y = bounding box offset?
; Output
;   byte_RAM_0 = tile ID
;
sub_BANK3_BB87:
	TXA
	PHA

	LDA #$00
	STA byte_RAM_0
	STA byte_RAM_1
	LDA VerticalTileCollisionHitboxX, Y
	BPL loc_BANK3_BB96

	DEC byte_RAM_0

loc_BANK3_BB96:
	CLC
	ADC ObjectXLo - 1, X
	AND #$F0
	STA byte_RAM_5
	PHP
	LSR A
	LSR A
	LSR A
	LSR A
	STA byte_RAM_E5
	PLP
	LDA ObjectXHi - 1, X
	ADC byte_RAM_0
	STA byte_RAM_2
	STA byte_RAM_3
	LDA IsHorizontalLevel
	BNE loc_BANK3_BBB5

	STA byte_RAM_2
	STA byte_RAM_3

loc_BANK3_BBB5:
	LDA VerticalTileCollisionHitboxY, Y
	BPL loc_BANK3_BBBC

	DEC byte_RAM_1

loc_BANK3_BBBC:
	CLC
	ADC ObjectYLo - 1, X
	AND #$F0
	STA byte_RAM_6
	STA byte_RAM_E6
	LDA ObjectYHi - 1, X
	ADC byte_RAM_1
	STA byte_RAM_1
	STA byte_RAM_4
	JSR sub_BANK3_BC2E

	BCC loc_BANK3_BBD6

	LDA #$00
	BEQ loc_BANK3_BBDD

loc_BANK3_BBD6:
	JSR SetTileOffsetAndAreaPageAddr

	LDY byte_RAM_E7
	LDA (byte_RAM_1), Y

loc_BANK3_BBDD:
	STA byte_RAM_0
	PLA
	TAX
	RTS


;
; Check whether a tile should use the given collision handler type
;
; Input
;   A = tile ID
;   Y = collision handler type (0 = solid for mushroom blocks, 1 = jumpthrough, 2 = solid)
; Output
;   C = whether or not collision type Y is relevant
;
CheckTileUsesCollisionType_Bank3:
IFDEF CUSTOM_TILE_IDS
	CMP #$D8
	BCC +
	JSR CheckCustomSolidness
	+
ENDIF
	PHA ; stash tile ID for later

	; determine which tile table to use (0-3)
	AND #$C0
	ASL A
	ROL A
	ROL A

	; add the offset for the type of collision we're checking
	ADC TileGroupTable_Bank3, Y
	TAY

	; check which side of the tile ID pivot we're on
	PLA
	CMP TileSolidnessTable, Y
	RTS


;
; These map the two high bits of a tile to offets in TileSolidnessTable
;
TileGroupTable_Bank3:
	.db $00 ; solid to mushroom blocks
	.db $04 ; solid on top
	.db $08 ; solid on all sides


DoorHandling_GoThroughDoor_Bank3:
	INC DoorAnimationTimer
	INC PlayerLock
	JSR SnapPlayerToTile_Bank3

	LDA #DPCM_DoorOpenBombBom
	STA DPCMQueue
	RTS


;
; Checks horizontal collision with the player and stops them if necessary
;
PlayerHorizontalCollision:
	LDX #$00
	LDY PlayerMovementDirection
	LDA PlayerXVelocity
	EOR PlayerCollisionResultTable - 1, Y
	BPL loc_BANK3_BC10

	STX PlayerXVelocity

loc_BANK3_BC10:
	LDA PlayerXAcceleration
	EOR PlayerCollisionResultTable - 1, Y
	BPL loc_BANK3_BC1B

	STX PlayerXAcceleration

loc_BANK3_BC1B:
	STX PlayerXSubpixel

locret_BANK3_BC1E:
	RTS


;