;
; FryGuy
;
byte_BANK3_AC25:
	.db $F0

byte_BANK3_AC26:
	.db $00
	.db $F0

RenderSprite_Fryguy:
	LDA #$00
	STA byte_RAM_EE
	LDA ObjectAnimationTimer, X
	AND #$08
	LSR A
	LSR A
	LSR A
	STA byte_RAM_7
	LDY byte_RAM_7
	LDA SpriteTempScreenX
	PHA
	CLC
	ADC byte_BANK3_AC25, Y
	STA SpriteTempScreenX
	LDA #$80
	LDY EnemyArray_45C, X
	BEQ loc_BANK3_AC4B

	LDA #$88

loc_BANK3_AC4B:
	JSR RenderSprite_DrawObject

	JSR FindSpriteSlot

	STY_abs byte_RAM_F4
	PLA
	CLC
	LDY byte_RAM_7
	ADC byte_BANK3_AC26, Y
	STA SpriteTempScreenX
	LDA #$84
	LDY EnemyArray_45C, X
	BEQ loc_BANK3_AC67

	LDA #$8C

loc_BANK3_AC67:
	JMP RenderSprite_DrawObject


; ---------------------------------------------------------------------------

EnemyInit_Fryguy:
	JSR EnemyInit_Basic

IFDEF RESET_CHR_LATCH
	LDA #$02
	JSR SetBossTileset
ENDIF

	LDA #$04
IFDEF TEST_FLAG
	CLC
    ADC BossHP
ENDIF
	STA EnemyHP, X
	LDA #$00
	STA EnemyVariable, X
	RTS

; ---------------------------------------------------------------------------
byte_BANK3_AC77:
	.db $E0
	.db $20
	.db $F0
	.db $10

byte_BANK3_AC7B:
	.db $04
	.db $0C
	.db $04
	.db $0C

byte_BANK3_AC7F:
	.db $04
	.db $04
	.db $0C
	.db $0C

byte_BANK3_AC83:
	.db $01
	.db $FF

byte_BANK3_AC85:
	.db $2A
	.db $D6

byte_BANK3_AC87:
	.db $01
	.db $FF

byte_BANK3_AC89:
	.db $18
	.db $E8
; ---------------------------------------------------------------------------

EnemyBehavior_Fryguy:
	LDA #$02
	STA EnemyMovementDirection, X
	INC ObjectAnimationTimer, X
	LDY EnemyHP, X
	DEY
	BNE loc_BANK3_ACE7

	LDA #$03
	STA byte_RAM_9
	STA FryguySplitFlames
	JSR EnemyDestroy

loc_BANK3_ACA1:
	JSR CreateEnemy

	BMI loc_BANK3_ACE3

	LDY byte_RAM_0
	LDA ObjectYHi, X
	STA unk_RAM_4EF, Y
	LDA #$F0
	STA ObjectYVelocity, Y
	LDA #Enemy_FryguySplit
	STA ObjectType, Y
	LDA #$30
	STA EnemyArray_453, Y
	LDA ObjectYLo, X
	PHA
	LDX byte_RAM_9
	LDA byte_BANK3_AC77, X
	STA ObjectXVelocity, Y
	LDA SpriteTempScreenX
	ADC byte_BANK3_AC7B, X
	STA ObjectXLo, Y
	PLA
	ADC byte_BANK3_AC7F, X
	STA ObjectYLo, Y
	LDA #$00
	STA ObjectXHi, Y
	TYA
	TAX
	JSR SetEnemyAttributes

	LDX byte_RAM_12

loc_BANK3_ACE3:
	DEC byte_RAM_9
	BPL loc_BANK3_ACA1

loc_BANK3_ACE7:
	LDA byte_RAM_10
	AND #$1F
	BNE loc_BANK3_AD07

	JSR CreateEnemy

	LDX byte_RAM_0
	LDA #Enemy_Fireball
	STA ObjectType, X
	LDA ObjectXLo, X
	SBC #$08
	STA ObjectXLo, X
	LDA ObjectYLo, X
	ADC #$18
	STA ObjectYLo, X
	JSR EnemyInit_BasicAttributes

	LDX byte_RAM_12

loc_BANK3_AD07:
	LDA byte_RAM_10
	AND #$01
	BNE loc_BANK3_AD37

	LDA EnemyVariable, X
	AND #$01
	TAY
	LDA ObjectYVelocity, X
	CLC
	ADC byte_BANK3_AC87, Y
	STA ObjectYVelocity, X
	CMP byte_BANK3_AC89, Y
	BNE loc_BANK3_AD21

	INC EnemyVariable, X

loc_BANK3_AD21:
	LDA EnemyArray_477, X
	AND #$01
	TAY
	LDA ObjectXVelocity, X
	CLC
	ADC byte_BANK3_AC83, Y
	STA ObjectXVelocity, X
	CMP byte_BANK3_AC85, Y
	BNE loc_BANK3_AD37

	INC EnemyArray_477, X

loc_BANK3_AD37:
	JSR RenderSprite_Fryguy

	JSR ApplyObjectPhysicsY

	JMP ApplyObjectPhysicsX

; ---------------------------------------------------------------------------
unk_BANK3_AD40:
	.db $3F
	.db $3F
	.db $3F
	.db $7F
unk_BANK3_AD44:
	.db $D4
	.db $D8
	.db $DA
	.db $DE
; ---------------------------------------------------------------------------

EnemyBehavior_FryguySplit:
	LDA EnemyCollision, X
	AND #$10
	BEQ loc_BANK3_AD59

	JSR PlayBossHurtSound

	LDA #%00000000
	STA EnemyArray_46E, X
	JMP TurnIntoPuffOfSmoke

; ---------------------------------------------------------------------------

loc_BANK3_AD59:
	LDA #$02
	STA EnemyMovementDirection, X
	LDA byte_RAM_10
	STA ObjectShakeTimer, X
	INC ObjectAnimationTimer, X
	INC ObjectAnimationTimer, X
	JSR ObjectTileCollision

	JSR RenderSprite

	LDA EnemyCollision, X
	PHA
	AND #CollisionFlags_Down
	BEQ loc_BANK3_AD7A

	JSR ResetObjectYVelocity

	LDA #$00
	STA ObjectXVelocity, X

loc_BANK3_AD7A:
	PLA
	AND #CollisionFlags_Right | CollisionFlags_Left
	BEQ loc_BANK3_AD85

	JSR EnemyBehavior_TurnAround

	JSR HalfObjectVelocityX

loc_BANK3_AD85:
	TXA
	ASL A
	ASL A
	ASL A
	ADC byte_RAM_10
	LDY FryguySplitFlames
	AND unk_BANK3_AD40, Y
	ORA ObjectYVelocity, X
	BNE loc_BANK3_ADAB

	LDA PseudoRNGValues + 2
	AND #$1F
	ORA unk_BANK3_AD44, Y
	STA ObjectYVelocity, X
	JSR EnemyInit_BasicMovementTowardPlayer

	LDA FryguySplitFlames
	CMP #$02
	BCS loc_BANK3_ADAB

	ASL ObjectXVelocity, X

loc_BANK3_ADAB:
IFDEF REV_A
	LDA PlayerState
	CMP #PlayerState_ChangingSize
	BEQ +
ENDIF

	JSR ApplyObjectPhysicsX

	JMP ApplyObjectMovement_Vertical

IFDEF REV_A
	+ RTS
ENDIF
