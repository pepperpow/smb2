;
; Mouser
; ======
;
; Runs back and forth, throws bombs
;
; byte_RAM_10 = timer used for jumping and throwing
; EnemyArray_45C = pauses Mouser when not $00
; EnemyTimer = counter used to time throwing (wind up and pitch)
; EnemyArray_B1 = counter used for movement direction and non-throw pauses
;
EnemyInit_Mouser:
	JSR EnemyInit_Birdo
IFDEF RESET_CHR_LATCH
	LDA #$00
	JSR SetBossTileset
ENDIF

	LDA #$02
	LDY CurrentWorldTileset
	BEQ EnemyInit_Mouser_SetHP

	LDA #$04

EnemyInit_Mouser_SetHP:
	STA EnemyHP, X
	RTS

EnemyBehavior_Mouser:
	JSR EnemyBehavior_CheckDamagedInterrupt

	LDA EnemyArray_45C, X
	BEQ EnemyBehavior_Mouser_Active

	JMP RenderSprite

EnemyBehavior_Mouser_Active:
	JSR ObjectTileCollision

	LDA #$02
	STA EnemyMovementDirection, X
	JSR RenderSprite

	LDA EnemyCollision, X
	AND #CollisionFlags_Down
	BEQ EnemyBehavior_Mouser_Falling

	JSR ResetObjectYVelocity

	LDA byte_RAM_10
	AND #$FF
	BNE EnemyBehavior_Mouser_Move

EnemyBehavior_Mouser_Jump:
	LDA #$D8
	STA ObjectYVelocity, X
	BNE EnemyBehavior_Mouser_Falling

EnemyBehavior_Mouser_Move:
	LDA byte_RAM_10
	AND #$3F
	BNE loc_BANK3_A5AF

	; the wind-up
	LDA #$20
	STA EnemyTimer, X

loc_BANK3_A5AF:
	LDY EnemyTimer, X
	BNE EnemyBehavior_Mouser_MaybeThrow

	INC EnemyArray_B1, X
	LDA EnemyArray_B1, X
	AND #$20
	BEQ EnemyBehavior_Mouser_Exit

	INC ObjectAnimationTimer, X
	INC ObjectAnimationTimer, X
	LDY #$18 ; right
	LDA EnemyArray_B1, X
	AND #$40
	BNE EnemyBehavior_Mouser_PhysicsX

	LDY #$E8 ; left

EnemyBehavior_Mouser_PhysicsX:
	STY ObjectXVelocity, X
	JMP ApplyObjectPhysicsX

EnemyBehavior_Mouser_MaybeThrow:
	; the pitch
	CPY #$10
	BNE EnemyBehavior_Mouser_Exit

EnemyBehavior_Mouser_Throw:
	JSR CreateEnemy_TryAllSlots

	BMI EnemyBehavior_Mouser_Exit

	LDX byte_RAM_0
	LDA #Enemy_Bomb
	STA ObjectType, X
	LDA ObjectYLo, X
	ADC #$03
	STA ObjectYLo, X
	LDA #$E0 ; throw y-velocity
	STA ObjectYVelocity, X
	JSR SetEnemyAttributes

	LDA #$FF ; bomb fuse
	STA EnemyTimer, X
	LDA #$E0 ; throw x-velocity
	STA ObjectXVelocity, X
	LDX byte_RAM_12

EnemyBehavior_Mouser_Exit:
	RTS

EnemyBehavior_Mouser_Falling:
	JMP ApplyObjectMovement_Vertical


RenderSprite_Mouser:
	LDA EnemyState, X
	CMP #EnemyState_Alive
	BNE RenderSprite_Mouser_Hurt

	LDA EnemyArray_45C, X
	BEQ RenderSprite_Mouser_Throw

	INC ObjectAnimationTimer, X
	LDA #ObjAttrib_16x32 | ObjAttrib_FrontFacing | ObjAttrib_Palette2
	STA ObjectAttributes, X

RenderSprite_Mouser_Hurt:
	LDA #%10110011
	STA EnemyArray_46E, X
	LDA #$2C ; hurt sprite
	BNE RenderSprite_Mouser_DrawObject

RenderSprite_Mouser_Throw:
	LDY EnemyTimer, X
	DEY
	CPY #$10
	BCS RenderSprite_Mouser_Walk

	LDA #$20 ; throwing sprite

RenderSprite_Mouser_DrawObject:
	JSR RenderSprite_DrawObject

	JMP RenderSprite_Mouser_Exit

RenderSprite_Mouser_Walk:
	JSR RenderSprite_NotAlbatoss

	LDA EnemyTimer, X
	CMP #$10
	BCC RenderSprite_Mouser_Exit

RenderSprite_Mouser_Bomb:
	LDA #ObjAttrib_Palette1
	STA ObjectAttributes, X
	LDA #%00010000 ; use tilemap 2
	STA EnemyArray_46E, X
	LDA SpriteTempScreenX
	CLC
	ADC #$0B
	STA SpriteTempScreenX
	ASL byte_RAM_EE
	LDY #$00
	STY_abs byte_RAM_F4
	LDA #$38 ; could have been $34 from tilemap 1 instead
	JSR RenderSprite_DrawObject

RenderSprite_Mouser_Exit:
	; restore Mouser attributes after drawing the bomb
	LDA #ObjAttrib_16x32 | ObjAttrib_Palette3
	STA ObjectAttributes, X
	LDA #%00110011
	STA EnemyArray_46E, X

	RTS


; ---------------------------------------------------------------------------