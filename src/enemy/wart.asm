;
; Wart Vegetable Thrower
;

VegetableThrowerOffsetX:
	.db $08
	.db $28
	.db $48
	.db $28

VegetableThrowerOffsetY:
	.db $94
	.db $84
	.db $94
	.db $84

VegetableThrowerVelocity:
	.db $F8
	.db $08
	.db $F8
	.db $08
	.db $08
	.db $F8
	.db $08
	.db $F8


Generator_VegetableThrower:
	LDA HoldingItem
	BNE locret_BANK3_B1CC

	LDA byte_RAM_10
	AND #$FF
	BNE locret_BANK3_B1CC

	INC VegetableThrowerShotCounter
	JSR CreateEnemy_TryAllSlots

	BMI locret_BANK3_B1CC

	LDX byte_RAM_0
	LDA VegetableThrowerShotCounter
	AND #$07
	TAY
	LDA VegetableThrowerVelocity, Y
	STA ObjectXVelocity, X
	TYA
	AND #$03
	TAY
	LDA #$02
	STA ObjectXHi, X
	LDA VegetableThrowerOffsetX, Y
	STA ObjectXLo, X
	LDA VegetableThrowerOffsetY, Y
	STA ObjectYLo, X
	LDA #$00
	STA ObjectYHi, X
	LDA PseudoRNGValues + 2
	AND #$03
	CMP #$02
	BCC loc_BANK3_B1C1

	ASL A
	STA EnemyArray_B1, X

loc_BANK3_B1C1:
	LDY #Enemy_VegetableLarge
	STY ObjectType, X
	JSR SetEnemyAttributes

	LDA #$D0
	STA ObjectYVelocity, X

locret_BANK3_B1CC:
	RTS

; ---------------------------------------------------------------------------


;
; Wart
; ====
;
; Walks back and forth, spits bubbles
;
; EnemyTimer = counter used to determing the bubble spit distance
; EnemyVariable = counter used to pause while walking back and forth
; EnemyArray_480 = counter used to determine the bubble spit height
; EnemyArray_B1 = counter for death animation
; EnemyArray_477 = counter used for alternating steps
; EnemyArray_45C = counter for blinking while hurt
;
EnemyInit_Wart:
	JSR EnemyInit_Basic

IFDEF RESET_CHR_LATCH
	LDA #$04
	JSR SetBossTileset
ENDIF

	LDA #$06
IFDEF TEST_FLAG
	CLC
    ADC BossHP
ENDIF
	STA EnemyHP, X
	LDA ObjectXHi, X
	STA unk_RAM_4EF, X
	RTS

WartBubbleYVelocity:
	.db $E0
	.db $F0
	.db $E8
	.db $E4

EnemyBehavior_Wart:
	LDA EnemyArray_B1, X
	BNE EnemyBehavior_Wart_Death

	LDA EnemyHP, X
	BNE EnemyBehavior_Wart_Alive

	; start the death sequence
	LDA #$80
	STA EnemyTimer, X
	STA EnemyArray_B1, X
	BNE EnemyBehavior_Wart_Exit

EnemyBehavior_Wart_Alive:
	INC EnemyVariable, X
	LDA byte_RAM_10
	AND #%11111111
	BNE EnemyBehavior_Wart_Movement

	; spit bubbles
	LDA #$5F
	STA EnemyTimer, X
	; counter that determines which index of WartBubbleYVelocity to use
	INC EnemyArray_480, X

EnemyBehavior_Wart_Movement:
	LDA #$00
	STA ObjectXVelocity, X

	; pause at the end of movement
	LDA EnemyVariable, X
	AND #%01000000
	BEQ EnemyBehavior_Wart_PhysicsX

	; increment animation timer
	INC EnemyArray_477, X
	LDA #$F8 ; left movement
	LDY EnemyVariable, X
	BPL EnemyBehavior_Wart_SetXVelocity

	LDA #$08 ; right movement

EnemyBehavior_Wart_SetXVelocity:
	STA ObjectXVelocity, X

EnemyBehavior_Wart_PhysicsX:
	JSR ApplyObjectPhysicsX

	LDA EnemyArray_45C, X
	BNE EnemyBehavior_Wart_Exit

	LDA EnemyTimer, X
	BEQ EnemyBehavior_Wart_Exit

	AND #$0F
	BNE EnemyBehavior_Wart_Exit

	; try to create a new enemy for the bubble
	JSR CreateEnemy

	BMI EnemyBehavior_Wart_Exit

	LDA #SoundEffect1_HawkOpen_WartBarf
	STA SoundEffectQueue1
	; determines how high to spit the bubble
	LDA EnemyArray_480, X
	AND #$03
	TAY
	; determines how far to spit the bubble
	LDA EnemyTimer, X

	; set up the bubble
	LDX byte_RAM_0
	LSR A
	EOR #$FF
	STA ObjectXVelocity, X
	LDA WartBubbleYVelocity, Y
	STA ObjectYVelocity, X
WartLoadSpot:
	LDA #Enemy_WartBubble
	STA ObjectType, X
	LDA ObjectYLo, X
	ADC #$08
	STA ObjectYLo, X
	JSR SetEnemyAttributes

	LDX byte_RAM_12

EnemyBehavior_Wart_Exit:
	JMP RenderSprite


EnemyBehavior_Wart_Death:
	LDA EnemyTimer, X
	BEQ EnemyBehavior_Wart_DeathFall

	; going up
	STA EnemyArray_45C, X
	INC EnemyArray_477, X
	INC EnemyArray_477, X
	LDA #$F0
	STA ObjectYVelocity, X
	BNE EnemyBehavior_Wart_Death_Exit

EnemyBehavior_Wart_DeathFall:
	LDA #$04
	STA ObjectXVelocity, X
	JSR ApplyObjectPhysicsX

	JSR ApplyObjectPhysicsY

	; every other frame
	LDA byte_RAM_10
	LSR A
	BCS EnemyBehavior_Wart_CheckDeathComplete

	INC ObjectYVelocity, X
	BMI EnemyBehavior_Wart_CheckDeathComplete

	LDA byte_RAM_10
	AND #$1F
	BNE EnemyBehavior_Wart_CheckDeathComplete

	LDA #DPCM_BossDeath
	STA DPCMQueue
	JSR CreateEnemy

	LDX byte_RAM_0
	LDA ObjectYLo, X
	ADC #$08
	STA ObjectYLo, X
	JSR TurnIntoPuffOfSmoke

EnemyBehavior_Wart_CheckDeathComplete:
	LDA ObjectYLo, X
	CMP #$D0
	BCC EnemyBehavior_Wart_Death_Exit

	LDA #EnemyState_Dead
	STA EnemyState, X

EnemyBehavior_Wart_Death_Exit:
	JMP RenderSprite


EnemyBehavior_WartBubble:
	INC ObjectAnimationTimer, X
	JSR ApplyObjectPhysicsX

	JSR ApplyObjectPhysicsY

	INC ObjectYVelocity, X
	JMP RenderSprite

EnemyBehavior_WartBubble_Exit:
	RTS


RenderSprite_Wart:
	LDA_abs byte_RAM_F4
	STA byte_RAM_7267
	STA byte_RAM_726B
	LDA byte_RAM_10
	AND #$03
	STA byte_RAM_7
	TAY
	LDA unk_RAM_7265, Y
	STA_abs byte_RAM_F4
	LDA byte_RAM_EF
	BNE EnemyBehavior_WartBubble_Exit

	LDY EnemyHP, X
	BNE RenderSprite_Wart_AfterObjAttrib

	; he dead
	LDA #ObjAttrib_Horizontal | ObjAttrib_FrontFacing | ObjAttrib_16x32 | ObjAttrib_Palette2
	STA ObjectAttributes, X

RenderSprite_Wart_AfterObjAttrib:
	LDA byte_RAM_EE
	PHA
	PHA
	LDY #$AE ; top row: shocked
	LDA EnemyArray_B1, X ; death counter
	BNE RenderSprite_Wart_TopHurt

	LDA EnemyArray_45C, X ; enemy timer
	BEQ RenderSprite_Wart_TopRegular

	CMP #$30
	BCS RenderSprite_Wart_TopHurt

	AND #$08
	BNE RenderSprite_Wart_TopHurt

	LDY #$9E ; top row: blinking

RenderSprite_Wart_TopHurt:
	TYA
	BNE RenderSprite_Wart_DrawTop

RenderSprite_Wart_TopRegular:
	LDA #$9E ; top row: regular
	LDY EnemyTimer, X
	BEQ RenderSprite_Wart_DrawTop

	LDA #$A2 ; top row: spitting

RenderSprite_Wart_DrawTop:
	JSR RenderSprite_DrawObject

	LDA byte_RAM_0
	STA SpriteTempScreenY
	LDY byte_RAM_7
	LDA unk_RAM_7266, Y
	STA_abs byte_RAM_F4
	LDY #$A6 ; middle row: regular
	LDA EnemyArray_B1, X
	BNE RenderSprite_Wart_MiddleHurt

	LDA EnemyArray_45C, X
	BEQ RenderSprite_Wart_MiddleRegular

	CMP #$30
	BCS RenderSprite_Wart_MiddleHurt

	AND #$08
	BNE RenderSprite_Wart_MiddleHurt

	BEQ RenderSprite_Wart_DrawMiddle

RenderSprite_Wart_MiddleRegular:
	LDA EnemyTimer, X
	BEQ RenderSprite_Wart_DrawMiddle

RenderSprite_Wart_MiddleHurt:
	LDY #$AA ; middle row: spitting

RenderSprite_Wart_DrawMiddle:
	PLA
	STA byte_RAM_EE
	TYA
	JSR RenderSprite_DrawObject

	LDA byte_RAM_0
	STA SpriteTempScreenY
	LDY byte_RAM_7
	LDA byte_RAM_7267, Y
	STA_abs byte_RAM_F4
	LDY #$BA ; bottom row: standing
	LDA ObjectXVelocity, X
	BEQ RenderSprite_Wart_DrawBottom

	LDY #$B2 ; bottom row: left foot up
	LDA EnemyArray_477, X
	AND #$10
	BEQ RenderSprite_Wart_DrawBottom

	LDY #$B6 ; bottom row: right foot up

RenderSprite_Wart_DrawBottom:
	PLA
	STA byte_RAM_EE
	TYA
	JSR RenderSprite_DrawObject

	LDA byte_RAM_EE
	BNE RenderSprite_Wart_Exit

	; draw backside
	LDY byte_RAM_7
	LDX byte_RAM_7267, Y
	LDA unk_RAM_7268, Y
	TAY
	LDA SpriteTempScreenX
	CLC
	ADC #$20
	BCS RenderSprite_Wart_Exit

	STA SpriteDMAArea + 3, Y
	STA SpriteDMAArea + 7, Y
	STA SpriteDMAArea + $B, Y
	LDA byte_RAM_0
	SBC #$2F
	STA SpriteDMAArea, Y
	ADC #$0F
	STA SpriteDMAArea + 4, Y
	ADC #$10
	STA SpriteDMAArea + 8, Y
	LDA SpriteDMAArea + 2, X
	STA SpriteDMAArea + 2, Y
	STA SpriteDMAArea + 6, Y
	STA SpriteDMAArea + $A, Y
	LDA #$19 ; top
	STA SpriteDMAArea + 1, Y
	LDA #$1B ; middle
	STA SpriteDMAArea + 5, Y
	LDA #$1D ; bottom
	STA SpriteDMAArea + 9, Y

RenderSprite_Wart_Exit:
	LDX byte_RAM_12
	RTS