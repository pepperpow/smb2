;
; Rocket
;

EnemyBehavior_Rocket:
	LDA EnemyArray_B1, X
	BNE EnemyBehavior_Rocket_Flying
	JMP EnemyBehavior_Rocket_Launching

EnemyBehavior_Rocket_Flying:
	LDY #$03
	LDA ObjectYVelocity, X
	BEQ EnemyBehavior_Rocket_Slow

	CMP #$FD
	BCC EnemyBehavior_Rocket_Fast

EnemyBehavior_Rocket_Slow:
	LDY #$3F
	INC SpriteTempScreenX
	LDA byte_RAM_10
	AND #$02
	BNE EnemyBehavior_Rocket_Fast

	DEC SpriteTempScreenX
	DEC SpriteTempScreenX

EnemyBehavior_Rocket_Fast:
	TYA
	AND byte_RAM_10
	BNE EnemyBehavior_Rocket_ApplyPhysics

	DEC ObjectYVelocity, X

EnemyBehavior_Rocket_ApplyPhysics:
	JSR ApplyObjectPhysicsY

	LDA EnemyArray_477, X
	BNE EnemyBehavior_Rocket_DroppingOff

	LDY ObjectYHi, X
	BPL EnemyBehavior_Rocket_Render

	JSR DoAreaReset

	LDA #Enemy_Rocket
	STA ObjectCarriedOver
	INC DoAreaTransition
	LDA #TransitionType_Rocket
	STA TransitionType
	LDA #$00
	STA_abs PlayerState

	RTS

EnemyBehavior_Rocket_DroppingOff:
	LDA ObjectYLo, X
	CMP #$30
	BCS EnemyBehavior_Rocket_Render

	LDY PlayerInRocket
	BNE EnemyBehavior_Rocket_DropPlayer

	CMP #$18
	BCS EnemyBehavior_Rocket_Render

	JMP EnemyBehavior_Bomb_Explode

EnemyBehavior_Rocket_DropPlayer:
IFNDEF RANDOMIZER_FLAGS
	LDA #$00
	STA PlayerInRocket
	STA HoldingItem
	STA PlayerXVelocity
	LDA ObjectYLo, X
	ADC #$20
	STA PlayerYLo
	STA PlayerScreenYLo
ENDIF

EnemyBehavior_Rocket_Render:
	JSR RenderSprite_Rocket

	LDA SpriteTempScreenX
	SEC
	SBC #$04
	STA SpriteDMAArea + $93
	ADC #$07
	STA SpriteDMAArea + $97
	ADC #$08
	STA SpriteDMAArea + $9B

	LDA #$20 ; long trail
	LDY ObjectYVelocity, X
	CPY #$FD
	BMI EnemyBehavior_Rocket_RenderTrails

	LDA #$15 ; short trail

EnemyBehavior_Rocket_RenderTrails:
	ADC SpriteTempScreenY
	STA SpriteDMAArea + $90
	STA SpriteDMAArea + $94
	STA SpriteDMAArea + $98
	LDA #$8C
	STA SpriteDMAArea + $91
	STA SpriteDMAArea + $95
	STA SpriteDMAArea + $99
	LDA byte_RAM_10
	LSR A
	AND #$03
	STA byte_RAM_0
	LSR A
	ROR A
	ROR A
	AND #$C0
	ORA byte_RAM_0
	STA SpriteDMAArea + $92
	STA SpriteDMAArea + $96
	STA SpriteDMAArea + $9A
	RTS

EnemyBehavior_Rocket_Launching:
	; Wait until ObjectBeingCarriedTimer reaches 1 to start the boosters
	LDA ObjectBeingCarriedTimer, X
	CMP #$01
	BNE EnemyBehavior_Rocket_Carry

	; Setting EnemyArray_B1 puts the rocket in the area
	STA EnemyArray_B1, X
	STA PlayerInRocket
	LDA #SoundEffect3_Rumble_A
	STA SoundEffectQueue3
	LDA #$FE
	STA ObjectYVelocity, X

EnemyBehavior_Rocket_Carry:
	JSR CarryObject

RenderSprite_Rocket:
	LDA SpriteTempScreenY
	STA byte_RAM_0
	LDA SpriteTempScreenX
	SEC
	SBC #$08
	STA byte_RAM_1
	LDA #$02
	STA byte_RAM_2
	STA byte_RAM_5
	STA byte_RAM_C
	LDA ObjectAttributes, X
	AND #$23
	STA byte_RAM_3
	LDY #$00
	LDX #$96
	JSR loc_BANK2_9C53

	LDA byte_RAM_1
	CLC
	ADC #$10
	STA byte_RAM_1
	DEC byte_RAM_2
	LDA SpriteTempScreenY
	STA byte_RAM_0
	LDY #$10
	LDX #$96
	JMP loc_BANK2_9C53

