; ---------------------------------------------------------------------------
HealthBarTiles:
	.db $BA ; 0
	.db $BA
	.db $BA
	.db $BA
	.db $B8 ; 1
	.db $BA
	.db $BA
	.db $BA
	.db $B8 ; 2
	.db $B8
	.db $BA
	.db $BA
	.db $B8 ; 3
	.db $B8
	.db $B8
	.db $BA
	.db $B8 ; 4
	.db $B8
	.db $B8
	.db $B8

POWQuakeOffsets:
	.db $00
	.db $03
	.db $00
	.db $FD

SkyFlashColors:
	.db $26
	.db $2A
	.db $22
	.db $26

; =============== S U B R O U T I N E =======================================

AreaSecondaryRoutine:
	LDA SkyFlashTimer
	BEQ AreaSecondaryRoutine_HealthBar

	; sky flash timer (ie. explosions)
	DEC SkyFlashTimer
	LDX byte_RAM_300
	LDA #$3F
	STA PPUBuffer_301, X
	LDA #$10
	STA PPUBuffer_301 + 1, X
	LDA #$04
	STA PPUBuffer_301 + 2, X
	LDA SkyColor
	LDY SkyFlashTimer
	BEQ AreaSecondaryRoutine_PlayerPalette

	TYA
	AND #$03
	TAY
	LDA SkyFlashColors, Y

AreaSecondaryRoutine_PlayerPalette:
	STA PPUBuffer_301 + 3, X
	LDA RestorePlayerPalette1
	STA PPUBuffer_301 + 4, X
	LDA RestorePlayerPalette2
	STA PPUBuffer_301 + 5, X
	LDA RestorePlayerPalette3
	STA PPUBuffer_301 + 6, X
	LDA #$00
	STA PPUBuffer_301 + 7, X
	TXA
	CLC
	ADC #$07
	STA byte_RAM_300

AreaSecondaryRoutine_HealthBar:
	LDA #$30
	STA byte_RAM_0
	JSR FindSpriteSlot

	LDA PlayerHealth
	BEQ AreaSecondaryRoutine_HealthBar_Draw

	AND #$F0
	LSR A
	LSR A
	ADC #$04 ; max health

AreaSecondaryRoutine_HealthBar_Draw:
	TAX

	LDA #$FE
	STA byte_RAM_3
IFDEF HEALTH_REVAMP
	LDA PlayerState
	CMP #PlayerState_ChangingSize
	BEQ +go
	CMP #PlayerState_Dying
	BEQ +go
	LDA DamageInvulnTime
	ORA CrouchJumpTimer
	ORA SubspaceTimer
	ORA InSubspaceOrJar
	BEQ AreaSecondaryRoutine_POW
+go
    LDA PlayerMaxHealth
    BMI AreaSecondaryRoutine_POW
    CMP #$3
    BCC +
    JSR NewHealthRender
    JMP AreaSecondaryRoutine_POW
+   TXA
    CMP #$10
    BCC +
    LDA #$10
    TAX
+
	PHA
	LDA CherryCount
	BEQ +
	LDA #$a1
	STA SpriteDMAArea + 1, Y
	PLA
	JMP AfterLoadHealthTile
+
	PLA
ENDIF
AreaSecondaryRoutine_HealthBar_Loop:
	LDA HealthBarTiles, X
	STA SpriteDMAArea + 1, Y
AfterLoadHealthTile:
	LDA #$10
	STA SpriteDMAArea + 3, Y
	LDA #$01
	STA SpriteDMAArea + 2, Y
	LDA byte_RAM_0
	STA SpriteDMAArea, Y
	CLC
	ADC #$10
	STA byte_RAM_0
	INX
	INY
	INY
	INY
	INY
	INC byte_RAM_3
	LDA byte_RAM_3
IFDEF HEALTH_REVAMP
	CMP #2
	BEQ AreaSecondaryRoutine_POW
ENDIF
	CMP PlayerMaxHealth
	BNE AreaSecondaryRoutine_HealthBar_Loop

AreaSecondaryRoutine_POW:
	LDA POWQuakeTimer
IFDEF HEALTH_REVAMP ;; actually deals with groundpound?
    BPL +++ 
    INC POWQuakeTimer
    INC POWQuakeTimer
+++
ENDIF
	BEQ AreaSecondaryRoutine_Exit

	DEC POWQuakeTimer
	LSR A
	AND #$01
	TAY
	LDA PPUScrollYMirror
	BPL AreaSecondaryRoutine_POW_OffsetScreen

	INY
	INY

AreaSecondaryRoutine_POW_OffsetScreen:
	LDA POWQuakeOffsets, Y
	STA BackgroundYOffset
IFNDEF SECONDARY_ROUTINE_MOVE
	JMP KillOnscreenEnemies
ENDIF

AreaSecondaryRoutine_Exit:
	RTS
