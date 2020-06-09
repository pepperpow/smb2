
IFDEF CONTROLLER_2_DEBUG
ChangeCharacterOffsets:
	.db $00 ; unused
	.db $03 ; Mario to right
	.db $01 ; Mario to left
	.db $00 ; Princess to right
	.db $02 ; Princess to left
	.db $01 ; Toad to right
	.db $03 ; Toad to left
	.db $02 ; Luigi to right
	.db $00 ; Luigi to left

CheckPlayer2Joypad:
	LDA ChangeCharacterTimer
	BEQ CheckPlayer2Joypad_Go

	DEC ChangeCharacterTimer

CheckPlayer2Joypad_No:
	RTS

CheckPlayer2Joypad_Go:
	LDA PlayerState
	CMP #PlayerState_Dying
	BEQ CheckPlayer2Joypad_No

CheckPlayer2Joypad_CheckSelect:
	LDA Player2JoypadPress
	AND #ControllerInput_Select
	BEQ CheckPlayer2Joypad_CheckUp

	LDA CurrentLevel_Init
	STA CurrentLevel
	LDA CurrentLevelArea_Init
	STA CurrentLevelArea
	LDA CurrentLevelEntryPage_Init
	STA CurrentLevelEntryPage
	LDA TransitionType_Init
	STA TransitionType

	LDA PlayerXLo_Init
	STA PlayerXLo
	LDA PlayerYLo_Init
	STA PlayerYLo
	LDA PlayerScreenX_Init
	STA PlayerScreenX
	LDA PlayerScreenYLo_Init
	STA PlayerScreenYLo
	LDA PlayerYVelocity_Init
	STA PlayerYVelocity
	LDA PlayerState_Init
	STA PlayerState

	LDA #$00
	STA PlayerXVelocity

	JSR DoAreaReset

	JMP StartLevel

CheckPlayer2Joypad_CheckUp:
	LDA Player2JoypadPress
	AND #ControllerInput_Up
	BEQ CheckPlayer2Joypad_CheckDown

	LDY PlayerMaxHealth
	LDA PlayerHealth
	CMP PlayerHealthValueByHeartCount, Y
	BPL CheckPlayer2Joypad_CheckDown

	LDA #SoundEffect1_CherryGet
	STA SoundEffectQueue1

	LDY PlayerMaxHealth
	LDA PlayerHealth
	CLC
	ADC #$10
	STA PlayerHealth

CheckPlayer2Joypad_CheckDown:
	LDA Player2JoypadPress
	AND #ControllerInput_Down
	BEQ CheckPlayer2Joypad_CheckStart

	LDA PlayerHealth
	AND #$F0
	BEQ CheckPlayer2Joypad_CheckStart

	LDA #DPCM_PlayerHurt
	STA DPCMQueue

	LDA PlayerHealth
	SEC
	SBC #$10
	STA PlayerHealth

CheckPlayer2Joypad_CheckStart:
	LDA Player2JoypadPress
	AND #ControllerInput_Start
	BEQ CheckPlayer2Joypad_CheckButtonA

	LDX #$FF
	LDA StopwatchTimer
	BEQ CheckPlayer2Joypad_SetStopwatchTimer

	INX

CheckPlayer2Joypad_SetStopwatchTimer:
	STX StopwatchTimer

CheckPlayer2Joypad_CheckButtonA:
	LDA Player2JoypadPress
	AND #ControllerInput_A
	BEQ CheckPlayer2Joypad_CheckLeftRight

	LDA Player2JoypadHeld
	AND #ControllerInput_B
	BEQ CheckPlayer2Joypad_NoButtonB

	JSR DebugRandomObject
	BNE CheckPlayer2Joypad_CheckLeftRight

CheckPlayer2Joypad_NoButtonB:
	JSR RandomCarryObject

CheckPlayer2Joypad_CheckLeftRight:
	LDA Player2JoypadPress
	AND #ControllerInput_Right | ControllerInput_Left
	BEQ CheckPlayer2Joypad_Exit
	CMP #ControllerInput_Right | ControllerInput_Left
	BEQ CheckPlayer2Joypad_Exit

	CLC
	ADC CurrentCharacter
	ADC CurrentCharacter

	TAY
	LDA ChangeCharacterOffsets, Y

	LDX #$18
	STX ChangeCharacterTimer
	LDX #$08
	STX ChangeCharacterPoofTimer

	BNE CheckSetCurrentCharacter

CheckPlayer2Joypad_Exit:
	RTS

;
; Changes the current character
;
; Input
;   A = target character
;
CheckSetCurrentCharacter:
	CMP CurrentCharacter
	BNE SetCurrentCharacter

	RTS

SetCurrentCharacter:
	STA CurrentCharacter

	LDA GravityWithJumpButton
	PHA

	LDX CurrentCharacter
	LDY StatOffsetsRAM, X
	LDX #$00
SetCurrentCharacter_StatsLoop:
	LDA StatOffsetsRAM + CharacterStats-StatOffsets, Y
	STA CharacterStatsRAM, X
	INY
	INX
	CPX #$17
	BCC SetCurrentCharacter_StatsLoop

	LDA CurrentCharacter
	ASL A
	ASL A
	TAY
	LDX #$00
SetCurrentCharacter_PaletteLoop:
	LDA StatOffsetsRAM + CharacterPalette-StatOffsets, Y
	STA RestorePlayerPalette0, X
	INY
	INX
	CPX #$04
	BCC SetCurrentCharacter_PaletteLoop

	; load carry offsets
	LDY CurrentCharacter
	LDA CarryYOffsetsRAM + CarryYOffsetBigLo-CarryYOffsets, Y
	STA ItemCarryYOffsetsRAM
	LDA CarryYOffsetsRAM + CarryYOffsetSmallLo-CarryYOffsets, Y
	STA ItemCarryYOffsetsRAM + $07
	LDA CarryYOffsetsRAM + CarryYOffsetBigHi-CarryYOffsets, Y
	STA ItemCarryYOffsetsRAM + $0E
	LDA CarryYOffsetsRAM + CarryYOffsetSmallHi-CarryYOffsets, Y
	STA ItemCarryYOffsetsRAM + $15

	; interrupt floating if this character can't do it
	LDA JumpFloatLength
	BEQ SetCurrentCharacter_SetJumpFloatTimer

	; if already floating, keep going
	CMP JumpFloatTimer
	BCC SetCurrentCharacter_CheckGravityChange

SetCurrentCharacter_SetJumpFloatTimer:
	STA JumpFloatTimer

SetCurrentCharacter_CheckGravityChange:
	; check whether gravity is increasing
	PLA
	SEC
	SBC GravityWithJumpButton
	BEQ SetCurrentCharacter_Update

	; stash velocity delta in X
	TAX

	; check whether y-velocity is negative
	LDA PlayerYVelocity
	BPL SetCurrentCharacter_Update

	CPX #$00
	BPL SetCurrentCharacter_ClampYVelocity

	; scale y-velocity based on difference in gravity
	EOR #$FF
	CLC
	ADC #$01

	DEX
SetCurrentCharacter_ScaleVelocityYUp_Loop:
	ASL
	INX
	BEQ SetCurrentCharacter_ScaleVelocityYUp_Loop

	EOR #$FF
	STA PlayerYVelocity

	JMP SetCurrentCharacter_Update

SetCurrentCharacter_ClampYVelocity:
	LDA PlayerYVelocity
	CMP JumpHeightRunning

	BPL SetCurrentCharacter_Update

	LDA JumpHeightStandingCarrying
	STA PlayerYVelocity

SetCurrentCharacter_Update:
	INC SkyFlashTimer

	; update chr for character
	JSR LoadCharacterCHRBanks

	LDA #DPCM_PlayerDeath
	STA DPCMQueue

SetCurrentCharacter_Exit:
	RTS


RandomCarryObjectTypes:
	.db #Enemy_VegetableSmall
	.db #Enemy_VegetableLarge
	.db #Enemy_Shell
	.db #Enemy_Bomb
	.db #Enemy_ShyguyRed
	.db #Enemy_Tweeter
	.db #Enemy_SnifitRed
	.db #Enemy_Egg

; bit 7: put in player's hands
; bit 6: set enemy timer
; bit 5: start at bottom of screen
; bit 4:
; bit 3:
; bit 2:
; bit 1: set thrown flag
; bit 0: disable velocity reset
RandomCarryObjectAttributes:
	.db %10000000
	.db %10000000
	.db %10000000
	.db %11000000
	.db %10000001
	.db %10000001
	.db %10000001
	.db %10000001


RandomCarryObject:
	LDA PlayerState
	BNE RandomCarryObject_Exit
	LDA HoldingItem
	BNE RandomCarryObject_Exit

	LDA byte_RAM_10
	LSR A
	LSR A
	LSR A
	AND #$07
	TAX
	LDA RandomCarryObjectAttributes, X
	STA CreateObjectAttributes
	LDA RandomCarryObjectTypes, X
	STA CreateObjectType

RandomCarryObject_Exit:
	RTS


DebugRandomObjectTypes:
	.db #Enemy_Bomb
	.db #Enemy_Bomb
	.db #Enemy_POWBlock
	.db #Enemy_POWBlock
	.db #Enemy_POWBlock
	.db #Enemy_Starman
	.db #Enemy_Starman
	.db #Enemy_Starman

DebugRandomObjectAttributes:
	.db %01000010
	.db %01000010
	.db %00000010
	.db %00000010
	.db %00000010
	.db %00100010
	.db %00100010
	.db %00100010


DebugRandomObject:
	LDA byte_RAM_10
	LSR A
	LSR A
	LSR A
	AND #$07
	TAX
	LDA DebugRandomObjectAttributes, X
	STA CreateObjectAttributes
	LDA DebugRandomObjectTypes, X
	STA CreateObjectType
	RTS
ENDIF