;
; Pokey
;
EnemyInit_Pokey:
	JSR EnemyInit_Basic

	LDA #$03
	STA EnemyVariable, X
	RTS

; ---------------------------------------------------------------------------
unk_BANK3_AA1C:
	.db $02
	.db $04
	.db $0D
	.db $0E
; ---------------------------------------------------------------------------

EnemyBehavior_Pokey:
	LDA EnemyVariable, X
	BNE loc_BANK3_AA2D

	JSR EnemyBehavior_CheckDamagedInterrupt

	JSR EnemyBehavior_CheckBeingCarriedTimerInterrupt

	JSR EnemyBehavior_Check42FPhysicsInterrupt

loc_BANK3_AA2D:
	LDA EnemyCollision, X
	AND #$10
	BEQ loc_BANK3_AA3A

	JSR sub_BANK3_AA3E

	INC EnemyArray_42F, X
	RTS

; ---------------------------------------------------------------------------

loc_BANK3_AA3A:
	LDA ObjectBeingCarriedTimer, X
	BEQ loc_BANK3_AA99

; =============== S U B R O U T I N E =======================================

sub_BANK3_AA3E:
	LDA EnemyVariable, X
	BEQ loc_BANK3_AA99

	STA EnemyArray_477, X
	LDA #$00
	STA EnemyVariable, X
	LDA #$02
	STA EnemyArray_489, X
	LDA EnemyRawDataOffset, X
	STA byte_RAM_6
	LDA #$FF
	STA EnemyRawDataOffset, X
	JSR CreateEnemy

	BMI loc_BANK3_AA99

	LDY byte_RAM_0
	LDA #Enemy_Pokey
	STA ObjectType, Y
	JSR RenderSprite_Tryclyde_ResetAttributes

	LDY byte_RAM_0
	LDA byte_RAM_6
	STA EnemyRawDataOffset, Y
	LDA EnemyArray_477, X
	SEC
	SBC #$01
	STA EnemyVariable, Y
	TAY

loc_BANK3_AA78:
	LDA unk_BANK3_AA1C, Y
	LDY byte_RAM_0
	STA EnemyArray_489, Y
	LDA ObjectXLo, X
	STA ObjectXLo, Y
	LDA ObjectXHi, X
	STA ObjectXHi, Y
	LDA ObjectYLo, X
	CLC
	ADC #$10
	STA ObjectYLo, Y
	LDA ObjectYHi, X
	ADC #$00
	STA ObjectYHi, Y

loc_BANK3_AA99:
	INC ObjectAnimationTimer, X
	LDA ObjectAnimationTimer, X
	AND #$3F
	BNE loc_BANK3_AAA4

	JSR EnemyInit_BasicMovementTowardPlayer

loc_BANK3_AAA4:
	JSR ApplyObjectPhysicsX

	JMP RenderSprite

; End of function sub_BANK3_AA3E

PokeyWiggleOffset:
	.db $00
	.db $01
	.db $00
	.db $FF
	.db $00
	.db $01
	.db $00


RenderSprite_Pokey:
	LDY #$00
	LDA byte_RAM_EE
	BNE RenderSprite_Pokey_Segments

	LDA byte_RAM_10
	AND #$18
	LSR A
	LSR A
	LSR A
	TAY

RenderSprite_Pokey_Segments:
	STY byte_RAM_7
	LDA SpriteTempScreenX
	STA PokeyTempScreenX
	CLC
	ADC PokeyWiggleOffset, Y
	STA SpriteTempScreenX
	JSR RenderSprite_NotAlbatoss

	LDA EnemyVariable, X
	STA byte_RAM_9
	BEQ RenderSprite_Pokey_Exit

	TYA
	CLC
	ADC #$10
	TAY
	LDX byte_RAM_7
	LDA PokeyTempScreenX
	ADC PokeyWiggleOffset + 1, X
	STA byte_RAM_1
	LDX #$70
	JSR SetSpriteTiles

	DEC byte_RAM_9
	BEQ RenderSprite_Pokey_Exit

	JSR FindSpriteSlot

	LDX byte_RAM_7
	LDA PokeyTempScreenX
	CLC
	ADC PokeyWiggleOffset + 2, X
	STA byte_RAM_1
	LDX #$70
	JSR SetSpriteTiles

	DEC byte_RAM_9
	BEQ RenderSprite_Pokey_Exit

	LDX byte_RAM_7
	LDA PokeyTempScreenX
	CLC
	ADC PokeyWiggleOffset + 3, X
	STA byte_RAM_1
	LDX #$70
	JSR SetSpriteTiles

RenderSprite_Pokey_Exit:
	LDX byte_RAM_12
	RTS