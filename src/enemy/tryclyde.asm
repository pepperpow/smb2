;
; Tryclyde
; ========
;
; Drifts back and forth slightly, spits fire
;
; EnemyArray_477 = counter used to determine movement direction and top head position
; EnemyArray_B1 = counter used to determine whether or not the bottom head should move
; EnemyArray_45C = used to determine whether Tryclyde is taking damage
; EnemyArray_480 = counter used to determine bottom head position
;
EnemyInit_Tryclyde:
	JSR EnemyInit_Basic

IFDEF RESET_CHR_LATCH
	LDA #$01
	JSR SetBossTileset
ENDIF

	LDA #$40
	STA EnemyArray_477, X
	LDA #$02
IFDEF TEST_FLAG
	CLC
    ADC BossHP
ENDIF
	STA EnemyHP, X
	JMP EnemyInit_Birdo_Exit


TryclydeHeadPosition:
	.db $00
	.db $FF
	.db $FE
	.db $FD
	.db $FC
	.db $FB
	.db $FA
	.db $F9
	.db $F8
	.db $F9
	.db $FA
	.db $FB
	.db $FC
	.db $FD
	.db $FE
	.db $FF

TryclydeFireYVelocity:
	.db $0B
	.db $0C
	.db $0D
	.db $0F
	.db $10
	.db $12
	.db $14
	.db $17
	.db $1A
	.db $1D
	.db $1F
	.db $20

TryclydeFireXVelocity:
	.db $E2
	.db $E2
	.db $E2
	.db $E3
	.db $E4
	.db $E5
	.db $E7
	.db $E9
	.db $ED
	.db $F1
	.db $F8
	.db $00

locret_BANK3_A75C:
	RTS

EnemyBehavior_Tryclyde:
	JSR EnemyBehavior_CheckDamagedInterrupt

	LDY #$00
	LDA EnemyArray_477, X
	ASL A
	BCC EnemyBehavior_Tryclyde_PhysicsX

	LDY #$02
	ASL A
	BCC EnemyBehavior_Tryclyde_PhysicsX

	LDY #$FE

EnemyBehavior_Tryclyde_PhysicsX:
	STY ObjectXVelocity, X
	JSR ApplyObjectPhysicsX

	INC EnemyArray_477, X
	LDA EnemyArray_B1, X
	CLC
	ADC #$D0
	STA EnemyArray_B1, X
	BCC RenderSprite_Tryclyde

	INC EnemyArray_480, X

RenderSprite_Tryclyde:
	LDA byte_RAM_EF
	BNE locret_BANK3_A75C

	LDA #ObjAttrib_16x32 | ObjAttrib_FrontFacing | ObjAttrib_Palette1
	STA ObjectAttributes, X
	LDY #$48 ; static head regular
	LDA EnemyState, X
	SEC
	SBC #$01
	ORA EnemyArray_45C, X
	STA byte_RAM_7
	BEQ RenderSprite_Tryclyde_DrawBody

	LDY #$4C ; static head hurt

RenderSprite_Tryclyde_DrawBody:
	TYA
	LDY #$30
	STY_abs byte_RAM_F4
	JSR RenderSprite_DrawObject

	LDA #ObjAttrib_Palette1 | ObjAttrib_FrontFacing
	STA ObjectAttributes, X
	LDA #%00110011
	STA EnemyArray_46E, X
	LDA ObjectXLo, X
	PHA
	SEC
	SBC #$08
	STA ObjectXLo, X
	JSR sub_BANK2_8894

	LDX #$50 ; tail up
	LDA byte_RAM_10
	AND #$20
	BNE RenderSprite_Tryclyde_DrawTail

	LDA #$04
	AND byte_RAM_10
	BEQ RenderSprite_Tryclyde_DrawTail

	LDX #$53 ; tail down

RenderSprite_Tryclyde_DrawTail:
	; tail
	LDA byte_RAM_1
	SEC
	SBC #$08
	STA byte_RAM_1
	LDA #$20
	STA byte_RAM_C
	LDY #$E0
	JSR SetSpriteTiles

	; top head
	LDX byte_RAM_12
	LDA ObjectXLo, X
	SEC
	SBC #$08
	STA ObjectXLo, X
	JSR sub_BANK2_8894

	PLA
	STA ObjectXLo, X
	LDA #%00010011
	STA EnemyArray_46E, X
	LDA ObjectYLo, X
	STA byte_RAM_0
	LDA EnemyArray_477, X
	AND #$78
	LSR A
	LSR A
	LSR A
	TAY
	LDA TryclydeHeadPosition, Y
	ADC SpriteTempScreenX
	ADC #$F0
	STA byte_RAM_1
	LDX #$56
	LDA byte_RAM_7
	BNE RenderSprite_Tryclyde_DrawTopHead

	LDX #$58
	DEY
	DEY
	DEY
	DEY
	CPY #$07
	BCS RenderSprite_Tryclyde_DrawTopHead

	LDX #$5A

RenderSprite_Tryclyde_DrawTopHead:
	LDY #$00
	JSR SetSpriteTiles

	; bottom head
	LDX byte_RAM_12
	LDA ObjectYLo, X
	CLC
	ADC #$10
	STA byte_RAM_0
	LDA EnemyArray_480, X
	AND #$78
	LSR A
	LSR A
	LSR A
	TAY
	LDA TryclydeHeadPosition, Y
	ADC SpriteTempScreenX
	ADC #$F0
	STA byte_RAM_1
	LDA #$00
	STA byte_RAM_C
	LDX #$56
	LDA byte_RAM_7
	BNE RenderSprite_Tryclyde_DrawBottomHead

	LDX #$58
	DEY
	DEY
	DEY
	DEY
	CPY #$07
	BCS RenderSprite_Tryclyde_DrawBottomHead

	LDX #$5A

RenderSprite_Tryclyde_DrawBottomHead:
	LDY #$08
	JSR SetSpriteTiles

	LDX byte_RAM_12
	LDA #%00010011
	STA EnemyArray_46E, X
	LDA byte_RAM_EE
	BNE EnemyBehavior_Tryclyde_SpitFireballs

RenderSprite_Tryclyde_DrawBottomNeck:
	LDA ObjectYLo, X
	CLC
	ADC #$10
	STA SpriteDMAArea + $58
	LDA #$0D ; neck sprite
	STA SpriteDMAArea + $59
	STA SpriteDMAArea + $5D ; bottom neck
	LDA SpriteDMAArea + $32
	STA SpriteDMAArea + $5A
	STA SpriteDMAArea + $5E ; bottom neck
	LDA byte_RAM_1
	CLC
	ADC #$10
	STA SpriteDMAArea + $5B

RenderSprite_Tryclyde_DrawTopNeck:
	LDA ObjectYLo, X
	STA SpriteDMAArea + $5C
	LDA SpriteTempScreenX
	SEC
	SBC #$08
	STA SpriteDMAArea + $5F

EnemyBehavior_Tryclyde_SpitFireballs:
	LDA #$00
	STA byte_RAM_5
	LDA EnemyArray_477, X
	JSR EnemyBehavior_Tryclyde_SpitFireball

	INC byte_RAM_5
	LDA EnemyArray_480, X

EnemyBehavior_Tryclyde_SpitFireball:
	AND #$67
	CMP #$40
	BNE RenderSprite_Tryclyde_Exit

	LDA EnemyArray_45C, X
	BNE RenderSprite_Tryclyde_Exit

	JSR CreateEnemy

	BMI RenderSprite_Tryclyde_Exit

	LDA #SoundEffect1_BirdoShot
	STA SoundEffectQueue1
	LDY byte_RAM_0
	LDA #Enemy_Fireball
	STA ObjectType, Y
	STA EnemyVariable, Y
	STA EnemyArray_B1, Y
	LDA ObjectXLo, X
	SBC #$18
	STA ObjectXLo, Y
	LDA byte_RAM_5
	BEQ EnemyBehavior_Tryclyde_GetFireAngle

	LDA ObjectYLo, X
	CLC
	ADC #$10
	STA ObjectYLo, Y

EnemyBehavior_Tryclyde_GetFireAngle:
	; angle the fireball based on the player's position
	LDA PlayerXLo
	LSR A
	LSR A
	LSR A
	LSR A
	AND #$0F
	CMP #$0B
	BCC EnemyBehavior_Tryclyde_SetFireVelocity

	LDA #$0B

EnemyBehavior_Tryclyde_SetFireVelocity:
	TAX ; These may be fireball speed pointers
	LDA TryclydeFireYVelocity, X
	STA ObjectYVelocity, Y
	LDA TryclydeFireXVelocity, X
	STA ObjectXVelocity, Y

;
; Sets enemy attributes to defaults, restores X, and exits
;
; Input
;   Y = enemy index
; Output
;   X = enemy index
;
RenderSprite_Tryclyde_ResetAttributes:
	TYA
	TAX
	JSR SetEnemyAttributes

	LDX byte_RAM_12

RenderSprite_Tryclyde_Exit:
	RTS

