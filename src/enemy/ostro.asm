;
; Ostro
;
byte_BANK3_A652:
	.db $FB
	.db $05
; ---------------------------------------------------------------------------

RenderSprite_Ostro:
	JSR RenderSprite_NotRocket

	LDA byte_RAM_EE
	AND #$0E
	ORA byte_RAM_EF
	ORA EnemyArray_B1, X
	BNE locret_BANK3_A67C

	LDA ObjectYLo, X
	SEC
	SBC #$02
	STA byte_RAM_0
	LDY EnemyMovementDirection, X
	LDA byte_RAM_1
	CLC
	ADC byte_BANK3_A652 - 1, Y
	STA byte_RAM_1
	JSR FindSpriteSlot

	LDX #$3C
	JSR SetSpriteTiles

	LDX byte_RAM_12

locret_BANK3_A67C:
	RTS

; ---------------------------------------------------------------------------

EnemyBehavior_Ostro:
	LDA EnemyArray_B1, X
	BNE loc_BANK3_A6DB

	LDA ObjectBeingCarriedTimer, X
	BEQ loc_BANK3_A6BD

	LDA #Enemy_ShyguyRed
	STA ObjectType, X
	JSR SetEnemyAttributes

	JSR CreateEnemy

	BMI locret_BANK3_A6BC

	LDY byte_RAM_0
	LDA #Enemy_Ostro
	STA ObjectType, Y
	STA EnemyArray_B1, Y
	LDA ObjectXLo, X
	STA ObjectXLo, Y
	LDA ObjectXHi, X
	STA ObjectXHi, Y
	LDA EnemyRawDataOffset, X
	STA EnemyRawDataOffset, Y
	LDA #$FF
	STA EnemyRawDataOffset, X
	LDA ObjectXVelocity, X
	STA ObjectXVelocity, Y
	TYA
	TAX
	JSR SetEnemyAttributes

	LDX byte_RAM_12

locret_BANK3_A6BC:
	RTS

; ---------------------------------------------------------------------------

loc_BANK3_A6BD:
	LDA EnemyCollision, X
	AND #$10
	BEQ loc_BANK3_A6DB

	INC EnemyArray_B1, X
	STA ObjectAnimationTimer, X
	JSR CreateEnemy

	BMI loc_BANK3_A6DB

	LDY byte_RAM_0
	LDA ObjectXVelocity, X
	STA ObjectXVelocity, Y
	LDA #$20
	STA EnemyArray_453, Y
	JMP loc_BANK3_A6E1

; ---------------------------------------------------------------------------

loc_BANK3_A6DB:
	JSR EnemyBehavior_CheckBeingCarriedTimerInterrupt

	JSR EnemyBehavior_CheckDamagedInterrupt

loc_BANK3_A6E1:
	JSR ObjectTileCollision

	LDA EnemyCollision, X
	AND EnemyMovementDirection, X
	BEQ loc_BANK3_A6ED

	JSR EnemyBehavior_TurnAround

loc_BANK3_A6ED:
	LDA EnemyCollision, X
	AND #$04
	BEQ loc_BANK3_A70D

	LDA EnemyArray_42F, X
	BEQ loc_BANK3_A700

	LDA #$00
	STA EnemyArray_42F, X
	JSR EnemyInit_BasicAttributes

loc_BANK3_A700:
	LDA ObjectAnimationTimer, X
	EOR #$08
	STA ObjectAnimationTimer, X
	JSR ResetObjectYVelocity

	LDA #$F0
	STA ObjectYVelocity, X

loc_BANK3_A70D:
	INC EnemyArray_477, X
	LDA EnemyArray_B1, X
	BNE loc_BANK3_A71E

	LDA EnemyArray_477, X
	AND #$3F
	BNE loc_BANK3_A71E

	JSR EnemyInit_BasicMovementTowardPlayer

loc_BANK3_A71E:
	JSR ApplyObjectMovement

	JMP RenderSprite

; ---------------------------------------------------------------------------
