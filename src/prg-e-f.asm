;
; Bank E & Bank F
; ===============
;
; What's inside: Lots of game logic.
;
;   - DPCM data
;   - Joypad input reading
;   - PPU update routines
;   - Game initialization routines
;   - Title card display routines
;   - Area initialization routines
;   - Music cue routines
;   - Character select (sprite data, palettes, logic)
;   - Bonus chance (sprite data, palettes, logic)
;   - Game Over / Continue screen
;   - Pause screen
;   - Health logic
;   - Bottomless pit death logic
;   - Bounding box data for collisions
;   - and more!
;

; Include DPCM samples
.include "src/music/dpcm-samples.asm"

; PPU update buffers used to update the screen
ScreenUpdateBufferPointers:
	.dw PPUBuffer_301
	.dw PPUBuffer_583
	.dw PPUBuffer_55F
	.dw PPUBuffer_CharacterSelect
	.dw PPUBuffer_BANKE_DE7A
	.dw PPUBuffer_Text_Game_Over
	.dw PPUBuffer_67B
	.dw PPUBuffer_Text_Retry
	.dw PPUBuffer_7168
	.dw PPUBuffer_67B
	.dw PPUBuffer_693
	.dw PPUBuffer_6AB
	.dw PPUBuffer_6BD
	.dw PPUBuffer_6CC ; PAUSE
	.dw PPUBuffer_6E9 ; (erase PAUSE)
	.dw PPUBuffer_6DA
	.dw PPUBuffer_6DF
	.dw PPUBuffer_6E4
	.dw PPUBuffer_7194
	.dw PPUBuffer_71A8
	.dw PPUBuffer_721B
	.dw PPUBuffer_TitleCard
	.dw PPUBuffer_PauseExtraLife
	.dw BonusChanceLayoutRAM

PPUBuffer_CharacterSelect:
	.db $21,$49,$06,'PLEASE' + $99
	.db $21,$50,$06,'SELECT' + $99
	.db $21,$8C,$06,'PLAYER' + $99
	.db $20,$00,$20,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8 ; Probably the checkerboard diamonds or w/e
	.db $B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7 ; $F
	.db $B8,$B7,$B8,$B7,$B8 ; $1E
	.db $20,$20,$20,$B9,$BA,$B9,$BA,$B9,$BA,$B9,$BA,$B9,$BA,$B9,$BA
	.db $B9,$BA,$B9,$BA,$B9,$BA,$B9,$BA,$B9,$BA,$B9,$BA,$B9,$BA,$B9 ; $F
	.db $BA,$B9,$BA,$B9,$BA ; $1E
	.db $23,$80,$20,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8
	.db $B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7,$B8,$B7 ; $F
	.db $B8,$B7,$B8,$B7,$B8 ; $1E
	.db $23,$A0,$20,$B9,$BA,$B9,$BA,$B9,$BA,$B9,$BA,$B9,$BA,$B9,$BA
	.db $B9,$BA,$B9,$BA,$B9,$BA,$B9,$BA,$B9,$BA,$B9,$BA,$B9,$BA,$B9 ; $F
	.db $BA,$B9,$BA,$B9,$BA ; $1E
	.db $20,$00,$9E,$B7,$B9,$B7,$B9,$B7,$B9,$B7,$B9,$B7,$B9,$B7,$B9
	.db $B7,$B9,$B7,$B9,$B7,$B9,$B7,$B9,$B7,$B9,$B7,$B9,$B7,$B9,$B7 ; $F
	.db $B9,$B7,$B9 ; $1E
	.db $20,$01,$9E,$B8,$BA,$B8,$BA,$B8,$BA,$B8,$BA,$B8,$BA,$B8,$BA
	.db $B8,$BA,$B8,$BA,$B8,$BA,$B8,$BA,$B8,$BA,$B8,$BA,$B8,$BA,$B8 ; $F
	.db $BA,$B8,$BA ; $1E
	.db $20,$1E,$9E,$B7,$B9,$B7,$B9,$B7,$B9,$B7,$B9,$B7,$B9,$B7,$B9
	.db $B7,$B9,$B7,$B9,$B7,$B9,$B7,$B9,$B7,$B9,$B7,$B9,$B7,$B9,$B7 ; $F
	.db $B9,$B7,$B9 ; $1E
	.db $20,$1F,$9E,$B8,$BA,$B8,$BA,$B8,$BA,$B8,$BA,$B8,$BA,$B8,$BA
	.db $B8,$BA,$B8,$BA,$B8,$BA,$B8,$BA,$B8,$BA,$B8,$BA,$B8,$BA,$B8 ; $F
	.db $BA,$B8,$BA ; $1E
	.db $20,$42,$5C,$FD
	.db $20,$62,$5C,$FD
	.db $20,$47,$05,$00,$01,$02,$03,4
	.db $20,$54,$05,$05,$06,$07,$08,9
	.db $20,$63,$0A,$A,$0B,$C,$0D,$E,$0F,$10,$11,$12,$13
	.db $20,$73,$0A,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D
	.db $20,$82,$1C,$1E,$1F,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29
	.db $FD,$FD,$FD,$FD,$2A,$2B,$2C,$2D,$2E,$2F,$30,$31,$32,$33,$34 ; $F
	.db $35 ; $1E
	.db $20,$A2,$06,$36,$37,$38,$39,$3A,$3B
	.db $20,$AB,$0A,$3C,$3D,$3E,$3F,$40,$43,$44,$45,$46,$47
	.db $20,$B8,$06,$48,$49,$4A,$4B,$4C,$4D
	.db $20,$C2,$05,$4E,$4F,$50,$51,$52
	.db $20,$D9,$05,$53,$54,$55,$56,$57
	.db $20,$E2,$04,$58,$59,$5A,$5B
	.db $20,$E6,$CD,$5C
	.db $20,$F9,$CD,$5C
	.db $20,$FA,$04,$5D,$5E,$5F,$60
	.db $21,$02,$83,$61,$64,$67
	.db $21,$03,$8B,$62,$65,$68,$6A,$6C,$6F,$72,$75,$78,$7B,$7E
	.db $21,$04,$94,$63,$66,$69,$6B,$6D,$70,$73,$76,$79,$7C,$7F,$81
	.db $82,$83,$84,$85,$86,$87,$88,$89 ; $F
	.db $21,$85,$89,$6E,$71,$74,$77,$7A,$7D,$80,$6E,$6E
	.db $21,$9A,$89,$97,$9A,$9D,$BB,$A0,$A3,$A6,$A9,$AB
	.db $21,$1B,$94,$8C,$8F,$92,$95,$98,$9B,$9E,$BC,$A1,$A4,$A7,$AA
	.db $AC,$AD,$AE,$B0,$B1,$B2,$B3,$B4 ; $F
	.db $21,$1C,$8B,$8D,$90,$93,$96,$99,$9C,$9F,$BD,$A2,$A5,$A8
	.db $21,$1D,$83,$8E,$91,$94
	.db $21,$62,$D1,$FD
	.db $21,$7D,$D1,$FD
	.db $22,$63,$C9,$FD,$22,$7C,$C9,$FD,$22,$86,$82,$8A,$8B,$22,$99
	.db $82,$8A,$8B ; $F
	.db $00
PPUBuffer_BANKE_DE7A:
	.db $23,$C0,$09,$3E,$0E,$E,$0E,$E,$0E,$E,$8E,$32
	.db $23,$CF,$01,$8C
	.db $23,$D0,$10,$32,$00,$A0,$A0,$A0,$20,$00,$8C,$32,$00,$00,$0A,$02,$00,$00,$8C
	.db $23,$E0,$09,$32,$00,$00,$0E,$00,$00,$00,$8C,$32
	.db $23,$EF,$01,$8C
	.db $23,$F0,$06,$32,$00,$A0,$A0,$A0,$A0
	.db $23,$F7,$09,$8C,$0E,$E,$0E,$E,$0E,$E,$0E,$E
	.db $24,$00,$60,$FF
	.db $24,$20,$60,$FF
	.db $24,$40,$60,$FF
	.db $24,$60,$60,$FF
	.db $27,$40,$60,$FF
	.db $27,$60,$60,$FF
	.db $27,$80,$60,$FF
	.db $27,$A0,$60,$FF
	.db $24,$80,$D6,$FF
	.db $24,$81,$D6,$FF
	.db $24,$82,$D6,$FF
	.db $24,$9D,$D6,$FF
	.db $24,$9E,$D6,$FF
	.db $24,$9F,$D6,$FF
	.db $24,$83,$01,$D0
	.db $24,$9C,$01,$D8
	.db $24,$84,$58,$FB
	.db $24,$A3,$D4,$D1
	.db $24,$BC,$D4,$D7
	.db $24,$A4,$58,$FB
	.db $24,$C4,$58,$FB
	.db $24,$E4,$58,$FB
	.db $25,$04,$58,$FB
	.db $25,$24,$58,$FB
	.db $25,$44,$58,$FB
	.db $25,$64,$58,$FB
	.db $25,$84,$58,$FB
	.db $25,$A4,$58,$FB
	.db $25,$C4,$58,$FB
	.db $25,$E4,$58,$FB
	.db $26,$04,$58,$FB
	.db $26,$24,$58,$FB
	.db $26,$44,$58,$FB
	.db $26,$64,$58,$FB
	.db $26,$84,$58,$FB
	.db $26,$A4,$58,$FB
	.db $26,$C4,$58,$FB
	.db $26,$E4,$58,$FB
	.db $27,$23,$01,$D2
	.db $27,$3C,$01,$D6
	.db $27,$24,$58,$D3
	.db $27,$C8,$08,$44,$FF,$BF,$AF,$AF,$AF,$FF,$11
	.db $27,$D0,$10,$44,$BF,$AF,$AF,$AF,$AF,$EF,$11,$44,$FF,$FF,$FF
	.db $FF,$FF,$FF,$11 ; $F
	.db $27,$E0,$10,$44,$FF,$FF,$FF,$FF,$FF,$FF,$11,$44,$FF,$FF,$FF
	.db $FF,$FF,$AF,$11 ; $F
	.db $27,$F0,$08,$44,$05,$05,$05,$05,$05,$05,$01
	.db $27,$04,$58,$FB
	.db $00

; nametable attribute data
PPUBuffer_PauseExtraLife:
	.db $27, $EA, $05
	.db $AA, $AA, $AA, $AA, $AA

; nametable attribute data
PPUBuffer_TitleCard:
	.db $20, $1E, $9E
	.db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.db $20, $1F, $9E
	.db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.db $23, $C7, $01, $00
	.db $23, $CF, $01, $00
	.db $23, $D7, $01, $00
	.db $23, $DF, $01, $00
	.db $23, $E7, $01, $00
	.db $23, $EF, $01, $00
	.db $23, $F7, $01, $00
	.db $23, $FF, $01, $00
	.db $00

; This table defines which level starts each world.
; The difference between the value of each world indicates how many worlds are
; in the level, which is why there is a slot for an 8th world, even though no
; such world is playable!
WorldStartingLevel:
	.db $00
	.db $03
	.db $06
	.db $09
	.db $0C
	.db $0F
	.db $12
	.db $14

IFNDEF CUSTOM_PLAYER_RENDER
PlayerSelectMarioSprites1:
	.db $8F, $00, $00, $48
	.db $8F, $00, $40, $50
	.db $9F, $02, $00, $48
	.db $9F, $02, $40, $50

PlayerSelectLuigiSprites1:
	.db $8F, $04, $01, $68
	.db $8F, $04, $41, $70
	.db $9F, $06, $01, $68
	.db $9F, $06, $41, $70

PlayerSelectToadSprites1:
	.db $8F, $08, $02, $88
	.db $8F, $08, $42, $90
	.db $9F, $0A, $02, $88
	.db $9F, $0A, $42, $90

PlayerSelectPrincessSprites1:
	.db $8F, $0C, $03, $A8
	.db $8F, $0C, $43, $B0
	.db $9F, $0E, $03, $A8
	.db $9F, $0E, $43, $B0

PlayerSelectMarioSprites2:
	.db $8F, $10, $00, $48
	.db $8F, $12, $00, $50
	.db $9F, $14, $00, $48
	.db $9F, $16, $00, $50

PlayerSelectLuigiSprites2:
	.db $8F, $18, $01, $68
	.db $8F, $1A, $01, $70
	.db $9F, $1C, $01, $68
	.db $9F, $1E, $01, $70

PlayerSelectToadSprites2:
	.db $8F, $20, $02, $88
	.db $8F, $22, $02, $90
	.db $9F, $24, $02, $88
	.db $9F, $26, $02, $90

PlayerSelectPrincessSprites2:
	.db $8F, $28, $03, $A8
	.db $8F, $2A, $03, $B0
	.db $9F, $2C, $03, $A8
	.db $9F, $2E, $03, $B0
ENDIF
IFDEF CUSTOM_PLAYER_RENDER
PlayerSelectMarioSprites1:
	.db $8F, $00, $00, $48
	.db $8F, $02, $00, $50
	.db $9F, $04, $00, $48
	.db $9F, $06, $00, $50

PlayerSelectLuigiSprites1:
	.db $8F, $08, $01, $68
	.db $8F, $0a, $01, $70
	.db $9F, $0c, $01, $68
	.db $9F, $0e, $01, $70

PlayerSelectToadSprites1:
	.db $8F, $10, $02, $88
	.db $8F, $12, $02, $90
	.db $9F, $14, $02, $88
	.db $9F, $16, $02, $90

PlayerSelectPrincessSprites1:
	.db $8F, $18, $03, $A8
	.db $8F, $1a, $03, $B0
	.db $9F, $1c, $03, $A8
	.db $9F, $1e, $03, $B0

PlayerSelectMarioSprites2:
	.db $8F, $20, $00, $48
	.db $8F, $22, $00, $50
	.db $9F, $24, $00, $48
	.db $9F, $26, $00, $50

PlayerSelectLuigiSprites2:
	.db $8F, $28, $01, $68
	.db $8F, $2A, $01, $70
	.db $9F, $2C, $01, $68
	.db $9F, $2E, $01, $70

PlayerSelectToadSprites2:
	.db $8F, $30, $02, $88
	.db $8F, $32, $02, $90
	.db $9F, $34, $02, $88
	.db $9F, $36, $02, $90

PlayerSelectPrincessSprites2:
	.db $8F, $38, $03, $A8
	.db $8F, $3A, $03, $B0
	.db $9F, $3C, $03, $A8
	.db $9F, $3E, $03, $B0
ENDIF

PlayerSelectSpriteIndexes:
	.db $00, $30, $20, $10

BonusChanceCherrySprite:
	.db $5F, $05, $01, $58
	.db $5F, $07, $01, $60

BonusChanceStarSprite:
	.db $5F, $09, $01, $58
	.db $5F, $09, $41, $60

BonusChanceVeggieSprite:
	.db $5F, $0B, $01, $58
	.db $5F, $0B, $41, $60

BonusChanceSnifitSprite:
	.db $5F, $01, $01, $58
	.db $5F, $03, $01, $60

PlayerSelectSpritePalettesDark:
	.db $3F, $10, $10 ; PPU Data
	.db $0F, $22, $12, $01
	.db $0F, $22, $12, $01
	.db $0F, $22, $12, $01
	.db $0F, $22, $12, $01

PlayerSelectPaletteOffsets:
	.db (PlayerSelectSpritePalettes_Mario - PlayerSelectSpritePalettes)
	.db (PlayerSelectSpritePalettes_Princess - PlayerSelectSpritePalettes)
	.db (PlayerSelectSpritePalettes_Toad - PlayerSelectSpritePalettes)
	.db (PlayerSelectSpritePalettes_Luigi - PlayerSelectSpritePalettes)

PlayerSelectSpritePalettes:
PlayerSelectSpritePalettes_Mario:
	.db $3F, $10, $04
	.db $0F, $27, $16, $01
PlayerSelectSpritePalettes_Luigi:
	.db $3F, $14, $04
	.db $0F, $36, $2A, $01
PlayerSelectSpritePalettes_Toad:
	.db $3F, $18, $04
	.db $0F, $27, $30, $01
PlayerSelectSpritePalettes_Princess:
	.db $3F, $1C, $04
	.db $0F, $36, $25, $07

TitleCardPalettes:
	.db $3F, $00, $20 ; PPU data
	.db $30 + 8, $30 + 0, $10 + $A, $00 + $F
	.db $30 + 8, $30 + 8, $00 + $F, $00 + $F
	.db $30 + 8, $10 + 7, $10 + $7, $30 + $8
	.db $30 + 8, $20 + 8, $10 + $8, $00 + $8
	.db $30 + 8, $30 + 0, $20 + $7, $00 + $1
	.db $30 + 8, $30 + 7, $20 + $7, $00 + $6
	.db $30 + 8, $20 + 5, $30 + $6, $00 + $6
	.db $30 + 8, $10 + 2, $30 + $6, $00 + $1
	.db $00

BonusChanceSpritePalettes:
	.db $0F,$37,$16,$0F
	.db $0F,$37,$16,$0F ; 4
	.db $0F,$37,$16,$0F ; 8
	.db $0F,$37,$16,$0F ; $C


;
; Load A with an index and call this to
; jump to a pointer from the table directly
; after the call.
;
JumpToTableAfterJump:
	ASL A
	TAY
	PLA
	STA byte_RAM_A
	PLA
	STA byte_RAM_B
	INY
	LDA (byte_RAM_A), Y
	STA byte_RAM_C
	INY
	LDA (byte_RAM_A), Y
	STA byte_RAM_D
	JMP (byte_RAM_C)


BlackAndWhitePalette:
	.db $0F,$30,$30,$0F


SetBlackAndWhitePalette:
	LDA PPUSTATUS
	LDA #$3F
	LDY #$00
	STA PPUADDR
	STY PPUADDR

SetBlackAndWhitePalette_Loop:
	TYA
	AND #$03
	TAX
	LDA BlackAndWhitePalette, X
	STA PPUDATA
	INY
	CPY #$14
	BCC SetBlackAndWhitePalette_Loop

	RTS


SetScrollXYTo0:
	LDA #$00
	STA PPUScrollYMirror
	STA PPUScrollXMirror
	STA PPUScrollYHiMirror
	STA PPUScrollXHiMirror
	RTS


;
; Clears the screen and resets the scroll position for the title card
;
; This is used for the character select screen as well, but that has a few PPU
; changes of its own.
;
ResetScreenForTitleCard:
	JSR EnableNMI

	JSR WaitForNMI_TurnOffPPU

	JSR SetScrollXYTo0

	LDA #ScreenUpdateBuffer_RAM_55F
	STA ScreenUpdateIndex
	JSR WaitForNMI

	LDA #VMirror
	JSR ChangeNametableMirroring

	JSR ClearNametablesAndSprites

	RTS


;
; Enables NMI and draws the background of the pause screen
;
EnableNMI_PauseTitleCard:
	JSR EnableNMI

	JSR WaitForNMI_TurnOffPPU

	LDA #Stack100_Menu
	STA StackArea
	LDA #ScreenUpdateBuffer_CharacterSelect
	STA ScreenUpdateIndex
	JSR WaitForNMI

	LDA #ScreenUpdateBuffer_BANKE_DE7A
	STA ScreenUpdateIndex
	JMP WaitForNMI


;
; Draws world info for the title card and pause screens
;
; ##### Input
; - `X`: CurrentWorld
; - `Y`: CurrentLevel (not actually used)
;
DisplayLevelTitleCardText:
	; Level number (unused)
	; In Doki Doki Panic, this was displayed as a page number, keeping with
	; the storybook motif.
	INY
	TYA
	JSR GetTwoDigitNumberTiles

	; World number
	INX
	TXA
	ORA #$D0
	STA byte_RAM_717D

	; Extra Life number
	LDY ExtraLives
	DEY
	TYA
	JSR GetTwoDigitNumberTiles
	STY byte_RAM_7191
	STA byte_RAM_7192

	; Reset level dots
	LDY #$06
	LDA #$FB
loc_BANKF_E1B6:
	STA unk_RAM_716B, Y ; writes to $7171
	DEY
	BPL loc_BANKF_E1B6

	; Level number
	LDY CurrentWorld
	LDA CurrentLevel
	SEC
	SBC WorldStartingLevel, Y
	STA CurrentLevelRelative
	CLC
	ADC #$D1
	STA byte_RAM_717F

	; Use the difference between the starting level of the next world and this
	; world to determine how many dots to show for the levels in the world.
	LDA WorldStartingLevel + 1, Y
	SEC
	SBC WorldStartingLevel, Y
	STA byte_RAM_3

	; Level dots
	LDX #$00
	LDY #$00
loc_BANKF_E1DC:
	LDA #$FD
	CPX CurrentLevelRelative
	BNE loc_BANKF_E1E5

	LDA #$F6

loc_BANKF_E1E5:
	STA unk_RAM_716B, Y
	INY
	INY
	INX
	CPX byte_RAM_3
	BCC loc_BANKF_E1DC

	; Draw the card
	LDA #ScreenUpdateBuffer_RAM_7168
	STA ScreenUpdateIndex
	RTS


;
; It's game time, pal
;
SetStack100Gameplay:
	LDA #Stack100_Gameplay
	STA StackArea
	RTS


; =============== S U B R O U T I N E =======================================

;
; Resets various level-related variables to $00
;
InitializeSomeLevelStuff:
	LDA #$00
	STA CurrentLevelArea
	STA CurrentLevelArea_Init
	STA CurrentLevelEntryPage
	STA CurrentLevelEntryPage_Init
	STA TransitionType
	STA TransitionType_Init
	STA PlayerState
	STA PlayerState_Init
	STA InSubspaceOrJar
	STA InJarType
	STA StopwatchTimer
	STA PlayerCurrentSize
	RTS


PlayerSelectArrowTop:
	.db $C9
	.db $D5
	.db $D1
	.db $CD
PlayerSelectArrowBottom:
	.db $E9
	.db $F5
	.db $F1
	.db $ED


;
; Displays the level title card and prepares the level to start by loading
; the world tiles, PRG banks A/B, and copying character data
;
DisplayLevelTitleCardAndMore:
	JSR WaitForNMI_TurnOffPPU

	JSR DisableNMI

	; Set the scrolling mirror over to the right side...
	; This Isn't quiiite correct, and causes a bunch of
	; crud to show on the very left pixel -- residue
	; from the character select screen
	LDA #$FF
	STA PPUScrollXMirror
	JSR ChangeTitleCardCHR

	LDA #PRGBank_A_B
	JSR ChangeMappedPRGBank

	JSR CopyCharacterStatsAndStuff

	JSR EnableNMI

	JSR HideAllSprites

	LDY #$23
DisplayLevelTitleCardAndMore_TitleCardPaletteLoop:
	LDA TitleCardPalettes, Y
	STA PPUBuffer_55F, Y
	DEY
	BPL DisplayLevelTitleCardAndMore_TitleCardPaletteLoop

	LDA #ScreenUpdateBuffer_RAM_55F ; Then tell it to dump that into the PPU
	STA ScreenUpdateIndex
	JSR WaitForNMI

	LDA #ScreenUpdateBuffer_TitleCard
	STA ScreenUpdateIndex
	JSR WaitForNMI

	JSR DrawTitleCardWorldImage

	JSR WaitForNMI_TurnOnPPU

	JSR RestorePlayerToFullHealth
IFDEF RANDOMIZER_FLAGS
	LDA PlayerHealth
	CLC
	ADC FreeHealth
	STA PlayerHealth
ENDIF

	; Pause for the title card
	LDA #$50
	STA byte_RAM_2
PreLevelTitleCard_PauseLoop:
	JSR WaitForNMI
	DEC byte_RAM_2
	BPL PreLevelTitleCard_PauseLoop

PreStartLevel:
	JSR SetStack100Gameplay

	JSR WaitForNMI_TurnOffPPU

	JSR DisableNMI

	JSR LoadWorldCHRBanks

	LDA #PRGBank_A_B
	JSR ChangeMappedPRGBank

	JSR CopyCharacterStatsAndStuff

	JSR EnableNMI

	RTS


;
; Runs the Character Select menu
;
DoCharacterSelectMenu:
	JSR WaitForNMI

	LDA #$00
	STA PPUMASK
	JSR DisableNMI

	JSR LoadCharacterSelectCHRBanks

	LDA #PRGBank_A_B
	JSR ChangeMappedPRGBank

	JSR CopyCharacterStatsAndStuff

	JSR ResetScreenForTitleCard

	LDA CharacterSelectBankSwitch
	CMP #$A5
	BEQ loc_BANKF_E2B2

	LDA #PRGBank_A_B
	JSR ChangeMappedPRGBank

	LDA #$A5
	STA CharacterSelectBankSwitch

loc_BANKF_E2B2:
	JSR EnableNMI_PauseTitleCard

	JSR DisableNMI

	LDA #Music1_CharacterSelect
	STA MusicQueue1
IFDEF INDIE_LIVES
    DEC CurrentCharacter
-   INC CurrentCharacter
    JSR ChkToNextValidCharacter 
    BNE -
    LDA IndependentLives
    BEQ +
    LDX CurrentCharacter
    LDA PlayerIndependentLives, X
    STA ExtraLives
+
    LDA CurrentCharacter 
    CLC
    ADC #$3
    JSR Custom_BufferText
ENDIF
	LDA CurrentCharacter
	STA PreviousCharacter
	LDA CurrentWorld
	STA PreviousWorld

	LDY #$3F
loc_BANKF_E2CA:
	LDA PlayerSelectMarioSprites1, Y
	STA SpriteDMAArea + $10, Y
	DEY
	BPL loc_BANKF_E2CA

	JSR EnableNMI

	JSR WaitForNMI

	LDX CurrentWorld
	LDY CurrentLevel
	JSR DisplayLevelTitleCardText

	JSR WaitForNMI

	JMP loc_BANKF_E311

; ---------------------------------------------------------------------------

loc_BANKF_E2E8:
	LDA Player1JoypadPress
	AND #ControllerInput_Right | ControllerInput_Left
	BNE CharacterSelect_ChangeCharacter

	JMP CharacterSelectMenuLoop

; ---------------------------------------------------------------------------

CharacterSelect_ChangeCharacter:
	LDA Player1JoypadPress
	AND #ControllerInput_Right
	BEQ loc_BANKF_E2FE

	DEC CurrentCharacter
	LDA #SoundEffect1_CherryGet
	STA SoundEffectQueue1

loc_BANKF_E2FE:
	LDA Player1JoypadPress
	AND #ControllerInput_Left
	BEQ loc_BANKF_E30B

	INC CurrentCharacter
	LDA #SoundEffect1_CherryGet
	STA SoundEffectQueue1

loc_BANKF_E30B:
	LDA CurrentCharacter
	AND #$03
	STA CurrentCharacter
IFDEF INDIE_LIVES
    JSR CharSelectInitialize
    JSR ChkToNextValidCharacter
    BNE CharacterSelect_ChangeCharacter
    LDA IndependentLives
    BEQ +
    LDX CurrentCharacter
    LDA PlayerIndependentLives, X
    STA ExtraLives
	JSR DisplayLevelTitleCardText
    JSR WaitForNMI
+
    LDA CurrentCharacter 
    CLC
    ADC #$3
    JSR Custom_BufferText
	LDA #ScreenUpdateBuffer_RAM_301
	STA ScreenUpdateIndex
    JSR WaitForNMI
    JMP loc_BANKF_E311
ENDIF

loc_BANKF_E311:
	LDY #$00
	LDA #$21
	STA PPUBuffer_301
	LDA #$C9
	STA PPUBuffer_301 + 1
	LDA #$4F
	STA PPUBuffer_301 + 2
	LDA #$FB
	STA PPUBuffer_301 + 3
	LDA #$21
	STA PPUBuffer_301 + 4
	LDA #$E9
	STA PPUBuffer_301 + 5
	LDA #$4F
	STA PPUBuffer_301 + 6
	LDA #$FB
	STA PPUBuffer_301 + 7
	LDY CurrentCharacter
	LDA #$21
	STA PPUBuffer_301 + 8
	LDA PlayerSelectArrowTop, Y
	STA PPUBuffer_301 + 9
	LDA #$02
	STA PPUBuffer_301 + 10
	LDA #$BE
	STA PPUBuffer_301 + 11
	LDA #$C0
	STA PPUBuffer_301 + 12
	LDA #$21
	STA PPUBuffer_301 + 13
	LDA PlayerSelectArrowBottom, Y
	STA PPUBuffer_301 + 14
	LDA #$02
	STA PPUBuffer_301 + 15
	LDA #$BF
	STA PPUBuffer_301 + 16
	LDA #$C1
	STA PPUBuffer_301 + 17
	LDA #$00
	STA PPUBuffer_301 + 18
	JSR WaitForNMI_TurnOnPPU

	LDX #$12
	LDY #$00

loc_BANKF_E37D:
	LDA PlayerSelectSpritePalettesDark, Y
	STA PPUBuffer_301, Y
	INY
	DEX
	BPL loc_BANKF_E37D

IFDEF INDIE_LIVES
    JSR LockCharacterSelectColor
ENDIF

	LDA #$06
	STA byte_RAM_A
	LDX CurrentCharacter
	LDA PlayerSelectPaletteOffsets, X
	TAX

loc_BANKF_E391:
	LDA PlayerSelectSpritePalettes, X
	STA PPUBuffer_301, Y
	INY
	INX
	DEC byte_RAM_A
	BPL loc_BANKF_E391

	LDA #$00
	STA PPUBuffer_301, Y

CharacterSelectMenuLoop:
	JSR WaitForNMI_TurnOnPPU

	LDA Player1JoypadPress
	AND #ControllerInput_A
	BNE loc_BANKF_E3AE

IFDEF CHAR_SWITCH
	LDA CurrentCharacter
	STA PreviousCharacter
ENDIF

	JMP loc_BANKF_E2E8

; ---------------------------------------------------------------------------

loc_BANKF_E3AE:
	LDA #SoundEffect1_CherryGet
	STA SoundEffectQueue1
	LDX CurrentWorld
	LDY CurrentLevel
	JSR DisplayLevelTitleCardText

	LDA #$40
	STA byte_RAM_10
	JSR WaitForNMI

	LDX #$F
	LDA CurrentCharacter
	TAY
	LDA PlayerSelectSpriteIndexes, Y
	TAY

loc_BANKF_E3CC:
	LDA PlayerSelectMarioSprites2, Y
	STA SpriteDMAArea + $10, Y
	INY
	DEX
	BPL loc_BANKF_E3CC

loc_BANKF_E3D6:
	JSR WaitForNMI

	DEC byte_RAM_10
	BPL loc_BANKF_E3D6

	LDY #$3F

loc_BANKF_E3DF:
	LDA PlayerSelectMarioSprites1, Y
	STA SpriteDMAArea + $10, Y
	DEY
	BPL loc_BANKF_E3DF

	LDA #$40
	STA byte_RAM_10

loc_BANKF_E3EC:
	JSR WaitForNMI

	DEC byte_RAM_10
	BPL loc_BANKF_E3EC

	LDA #Music2_StopMusic
	STA MusicQueue2
	RTS


;
; This starts the game once RESET has done its thing.
; We also come here after choosing "RETRY" from the game over menu.
;
IFDEF RANDOMIZER_FLAGS
.include "src/extras/custom_flags.asm"
LockCharacterSelectColor:
      LDA CurrentCharacter
      PHA
      TYA
      PHA

      LDY #3
      LDA #0 
      STA CurrentCharacter
      JMP +
-     DEC CurrentCharacter
      LDA CurrentCharacter
      AND #3
      CMP #0
      BEQ +++
+     JSR ChkToNextValidCharacter
      BNE ++
      INY
      INY
      INY
      INY
      JMP     -
++    LDA     #$0f
      STA     PPUBuffer_301,Y
      LDA     #$12
      INY
      STA     PPUBuffer_301,Y
      INY
      STA     PPUBuffer_301,Y
      INY
      STA     PPUBuffer_301,Y
      INY
      JMP     -

+++   PLA
      TAY
      PLA
      STA CurrentCharacter
      RTS
CharSelectInitialize:
      LDA CharacterLock_Variable ; check lock var, if 0 load new var
      CMP #$F
      BNE +
      LDA CharacterInitialLock
      STA CharacterLock_Variable
+     RTS
ENDIF

StartGame:
	LDA #$00
	STA PPUMASK
	JSR DisableNMI

	LDA #PRGBank_0_1
	STA GameMilestoneCounter
	JSR ChangeMappedPRGBank

	JSR TitleScreen ; The whole title screen is a subroutine, lol

	INC GameMilestoneCounter
SetNumContinues:
	LDA #$02 ; Number of continues on start
	STA Continues
	; JSR LoadStartingInventory
IFDEF RANDOMIZER_FLAGS
StartingTransition:
	LDA #TransitionType_Door
	STA TransitionType
	STA TransitionType_Init
StartingPage:
	LDA #$0
	STA CurrentLevelEntryPage
	STA CurrentLevelEntryPage_Init
ENDIF

; We return here after picking "CONTINUE" from the game over menu.
ContinueGame:
	LDA #$03 ; Number of lives to start
	STA ExtraLives
IFDEF INDIE_LIVES
ResetPlayer_Lives:
    LDY #$03
-   STA PlayerIndependentLives, Y
    DEY
    BPL -
	LDA #$F
	STA CharacterLock_Variable
	JSR CharSelectInitialize
ENDIF

GoToWorldStartingLevel:
IFNDEF NO_CONTINUE
	LDX CurrentWorld
	LDY WorldStartingLevel, X
	STY CurrentLevel
	STY CurrentLevel_Init

	JSR DoCharacterSelectMenu

	JSR InitializeSomeLevelStuff
ENDIF
IFDEF NO_CONTINUE
	LDA #$00
	STA PlayerState
	STA PlayerState_Init
	STA InSubspaceOrJar
	STA StopwatchTimer
	STA PlayerCurrentSize
	JSR DoCharacterSelectMenu
ENDIF
IFDEF CUSTOM_MUSH
	JSR ResetPlayerAbility
ENDIF

	JSR DisplayLevelTitleCardAndMore

	LDA #$FF
	STA CurrentMusicIndex
	BNE StartLevel ; Branch always

CharacterSelectMenu:
	JSR DoCharacterSelectMenu

StartLevelAfterTitleCard:
	JSR DisplayLevelTitleCardAndMore

StartLevel:
	JSR WaitForNMI_TurnOffPPU

	LDA #$B0
	ORA PPUScrollXHiMirror
	LDY IsHorizontalLevel
	BNE StartLevel_SetPPUCtrlMirror

	AND #$FE
	ORA PPUScrollYHiMirror

StartLevel_SetPPUCtrlMirror:
	STA PPUCtrlMirror
	STA PPUCTRL
	LDA #Stack100_Transition
	STA StackArea
	LDA #PRGBank_8_9
	JSR ChangeMappedPRGBank

	JSR CopyLevelDataToMemory

	LDA #PRGBank_6_7
	JSR ChangeMappedPRGBank

	JSR LoadCurrentArea

	JSR LoadCurrentPalette

IFDEF AREA_HEADER_TILESET
	JSR LoadWorldCHRBanks
ENDIF

	JSR HideAllSprites

	JSR WaitForNMI

	JSR SetStack100Gameplay

	LDA #PPUCtrl_Base2000 | PPUCtrl_WriteHorizontal | PPUCtrl_Sprite0000 | PPUCtrl_Background1000 | PPUCtrl_SpriteSize8x16 | PPUCtrl_NMIEnabled
	STA PPUCtrlMirror

	LDA IsHorizontalLevel
	BEQ VerticalLevel_Loop

HorizontalLevel_Loop:
	JSR WaitForNMI

	LDA #PRGBank_0_1
	JSR ChangeMappedPRGBank

	JSR InitializeAreaHorizontal

	JSR EnsureCorrectMusic

	LDA BreakStartLevelLoop
	BEQ HorizontalLevel_Loop

	LDA #$00
	STA BreakStartLevelLoop
	JSR WaitForNMI_TurnOnPPU

HorizontalLevel_CheckScroll:
	JSR WaitForNMI

	; Disable pause detection while scrolling
	LDA NeedsScroll
	AND #%00000100
	BNE HorizontalLevel_CheckSubArea

	LDA Player1JoypadPress
	AND #ControllerInput_Start
	BEQ HorizontalLevel_CheckSubArea

	JMP ShowPauseScreen

HorizontalLevel_CheckSubArea:
	LDA InSubspaceOrJar
	BEQ HorizontalLevel_ProcessFrame

	JMP InitializeSubArea

HorizontalLevel_ProcessFrame:
	JSR HideAllSprites

	JSR RunFrame_Horizontal

	LDY GameMode
	BEQ HorizontalLevel_CheckTransition

	JMP loc_BANKF_E665

HorizontalLevel_CheckTransition:
	LDA DoAreaTransition
	BEQ HorizontalLevel_CheckScroll

	JSR FollowCurrentAreaPointer

	JSR sub_BANKF_F1AE

	LDA #$00
	STA DoAreaTransition
	JMP StartLevel


VerticalLevel_Loop:
	JSR WaitForNMI

	LDA #PRGBank_0_1
	JSR ChangeMappedPRGBank

	JSR InitializeAreaVertical

	JSR EnsureCorrectMusic

	LDA BreakStartLevelLoop
	BEQ VerticalLevel_Loop

	LDA #$00
	STA BreakStartLevelLoop
	JSR WaitForNMI_TurnOnPPU

VerticalLevel_CheckScroll:
	JSR WaitForNMI

	; Disable pause detection while scrolling
	; This is likely a work-around to avoid getting the PPU into a weird state
	; due to conflicts between the pause screen and attempting to draw the part
	; of the area scrolling into view.
	LDA NeedsScroll
	AND #%00000100
	BNE VerticalLevel_ProcessFrame

	LDA Player1JoypadPress
	AND #ControllerInput_Start
	BNE ShowPauseScreen

VerticalLevel_ProcessFrame:
IFDEF TEST_FLAG_VERT_SUB
	LDA InSubspaceOrJar
	BEQ +
	LDA PPUScrollYMirror
	STA PPUScrollYMirror_Backup
	LDA PPUScrollXMirror
	STA PPUScrollXMirror_Backup
	LDA PPUScrollYHiMirror
	STA PPUScrollYHiMirror_Backup
	LDA PPUScrollXHiMirror
	STA PPUScrollXHiMirror_Backup
	LDA ScreenYHi
	STA ScreenYHi_Backup
	LDA ScreenYLo
	STA ScreenYLo_Backup
	LDA ScreenBoundaryLeftHi
	STA ScreenBoundaryLeftHi_Backup
	LDA byte_RAM_E1
	STA byte_RAM_517
	LDA ScreenYHi
	STA VertSubspaceFlag + 1
	LDA ScreenYLo
	STA VertSubspaceFlag + 2
	LDA #1
	STA IsHorizontalLevel
	STA VertSubspaceFlag
	LDA PlayerYHi
	STA VertSubspaceFlag + 3
	STA PlayerXHi
	STA CurrentLevelPage
	LDA PlayerYHi
	STA ScreenBoundaryLeftHi
	LDA #$0
	STA PlayerYHi
	LDA #$0
	STA ScreenBoundaryLeftLo
	JMP InitializeSubArea
+
ENDIF
	JSR HideAllSprites

	JSR RunFrame_Vertical

	LDY GameMode
	BEQ VerticalLevel_CheckTransition

	JMP loc_BANKF_E665

VerticalLevel_CheckTransition:
	LDA DoAreaTransition
	BEQ VerticalLevel_CheckScroll

	JSR FollowCurrentAreaPointer

	JSR sub_BANKF_F1AE

	LDA #$00
	STA DoAreaTransition
	JMP StartLevel


;
; Pauses the game
;
ShowPauseScreen:
	JSR PauseScreen_ExtraLife

	; used when running sound queues
	LDA #Stack100_Pause
	STA StackArea


PauseScreenLoop:
	LDA #$0E
	STA byte_RAM_6

DoSuicideCheatCheck:
	JSR WaitForNMI_TurnOnPPU

	LDA PlayerState ; Check if the player is already dying
	CMP #PlayerState_Dying
	BEQ PauseScreenExitCheck ; If so, skip the suicide code check

	LDA Player2JoypadHeld ; Check for suicide code
	CMP #ControllerInput_Up | ControllerInput_B | ControllerInput_A ; Up + A + B
	BNE PauseScreenExitCheck ; Not being held! Nothing to see here

	JSR KillPlayer ; KILL THYSELF

PauseScreenExitCheck:
	LDA Player1JoypadPress
	AND #ControllerInput_Start
	BNE HidePauseScreen


	DEC byte_RAM_6
	BPL DoSuicideCheatCheck

	INC byte_RAM_7
	LDA byte_RAM_7
	AND #$01
	CLC
	ADC #$0D ; Will use either $0D or $0E from the update index pointers
;IFDEF CUSTOM_MUSH
;	LDA #$0
;ENDIF
	STA ScreenUpdateIndex ; @TODO I assume this is what blinks "PAUSE"
	JMP PauseScreenLoop

;
; Unpauses the game
;
HidePauseScreen:
	JSR WaitForNMI_TurnOffPPU

IFDEF RESET_CHR_LATCH
	LDA #$00
	STA ResetCHRLatch
ENDIF

	JSR LoadWorldCHRBanks

	LDA #PRGBank_6_7
	JSR ChangeMappedPRGBank

	JSR LoadCurrentPalette

	JSR WaitForNMI

	JSR SetStack100Gameplay

	JSR HideAllSprites

	LDA #PRGBank_0_1
	JSR ChangeMappedPRGBank

	JSR RestoreScreenScrollPosition

	LDA IsHorizontalLevel
	BNE HidePauseScreen_Horizontal

HidePauseScreen_Vertical:
	LDA #HMirror
	JSR ChangeNametableMirroring

	JSR sub_BANK0_81FE

HidePauseScreen_Vertical_Loop:
	JSR WaitForNMI

	JSR sub_BANK0_823D

	LDA byte_RAM_537
	BEQ HidePauseScreen_Vertical_Loop

	JSR WaitForNMI_TurnOnPPU

	JMP VerticalLevel_CheckScroll

HidePauseScreen_Horizontal:
	LDA #VMirror
	JSR ChangeNametableMirroring

	JSR sub_BANK0_8785

HidePauseScreen_Horizontal_Loop:
	JSR WaitForNMI

	JSR sub_BANK0_87AA

	LDA byte_RAM_537
	BEQ HidePauseScreen_Horizontal_Loop

	JSR WaitForNMI_TurnOnPPU

	JMP HorizontalLevel_CheckScroll


InitializeSubArea:
	JSR ClearNametablesAndSprites

	LDA #PRGBank_6_7
	JSR ChangeMappedPRGBank

	LDA #$00
	STA SubspaceCoins
	LDA InSubspaceOrJar
	CMP #$02
	BEQ InitializeSubspace

InitializeJar:
	LDA #PRGBank_8_9
	JSR ChangeMappedPRGBank

	JSR CopyJarDataToMemory

	JSR CopyEnemyDataToMemory

	LDA #PRGBank_6_7
	JSR ChangeMappedPRGBank

	JSR ClearSubAreaTileLayout

	LDA #Music1_Inside
	STA MusicQueue1
	LDA #$01
	STA CurrentMusicIndex
	JMP loc_BANKF_E5E1


InitializeSubspace:
	JSR GenerateSubspaceArea

	LDA #Music1_Subspace
	STA MusicQueue1
	LDA #$04
	STA CurrentMusicIndex

loc_BANKF_E5E1:
	LDA #PRGBank_0_1
	JSR ChangeMappedPRGBank

	JSR UseSubareaScreenBoundaries

	JSR EnableNMI

SubArea_Loop:
	JSR WaitForNMI

	JSR sub_BANK0_87AA

	LDA byte_RAM_537
	BEQ SubArea_Loop

	LDA InSubspaceOrJar
	CMP #$02
	BEQ loc_BANKF_E606

	LDA #PRGBank_6_7
	JSR ChangeMappedPRGBank

	JSR LoadCurrentPalette

loc_BANKF_E606:
	JSR WaitForNMI_TurnOnPPU

; subspace
loc_BANKF_E609:
	JSR WaitForNMI

	JSR HideAllSprites

	JSR sub_BANKF_F0F9

	LDY GameMode
	BEQ loc_BANKF_E61A

	JMP loc_BANKF_E665

; ---------------------------------------------------------------------------

loc_BANKF_E61A:
	LDA InSubspaceOrJar
	BNE loc_BANKF_E609

	LDA SubspaceCoins
	BEQ loc_BANKF_E627

	INC SubspaceVisits

IFDEF LEVEL_FLAGS ;; this activates _every_ transition??
    INC Level_Count_SubspaceVisits
    LDX #CustomBitFlag_Sub1
    JSR ApplyFlagLevel
    BNE +
    LDX #CustomBitFlag_Sub2
    JSR ApplyFlagLevel 
    BNE +
+   
ENDIF

loc_BANKF_E627:
	LDA CurrentLevelAreaCopy
	STA CurrentLevelArea
	LDA #PRGBank_6_7
	JSR ChangeMappedPRGBank

	JSR LoadCurrentPalette

	JSR WaitForNMI_TurnOffPPU

	JSR HideAllSprites

	LDY CompareMusicIndex
	STY CurrentMusicIndex
	LDA StarInvincibilityTimer
	BNE loc_BANKF_E64C

	LDA LevelMusicIndexes, Y
	STA MusicQueue1

loc_BANKF_E64C:
	LDA #PRGBank_0_1
	JSR ChangeMappedPRGBank

	JSR UseMainAreaScreenBoundaries

ExitSubArea_Loop:
	JSR WaitForNMI

IFDEF TEST_FLAG_VERT_SUB_EXIT
	LDA IsHorizontalLevel
	BNE + 
	BEQ ++
+
ENDIF
	JSR sub_BANK0_87AA

	LDA byte_RAM_537
	BEQ ExitSubArea_Loop

	JSR WaitForNMI_TurnOnPPU

IFDEF TEST_FLAG_VERT_SUB
++
	LDA IsHorizontalLevel
	BNE + 
	STA ScreenBoundaryLeftHi
	STA ScreenBoundaryLeftLo
	STA ScreenBoundaryRightHi
	LDA #$FF
	STA ScreenBoundaryRightLo
	LDA PPUScrollYMirror_Backup
	STA PPUScrollYMirror
	LDA PPUScrollXMirror_Backup
	STA PPUScrollXMirror
	LDA PPUScrollYHiMirror_Backup
	STA PPUScrollYHiMirror
	LDA PPUScrollXHiMirror_Backup
	STA PPUScrollXHiMirror
	LDA ScreenYHi_Backup
	STA ScreenYHi
	LDA ScreenYLo_Backup
	STA ScreenYLo
	JSR WaitForNMI_TurnOffPPU
	JMP HidePauseScreen_Vertical
+
ENDIF
	JMP HorizontalLevel_CheckScroll

; ---------------------------------------------------------------------------

loc_BANKF_E665:
	JSR DoAreaReset

	LDY GameMode
	LDA #GameMode_InGame
	STA GameMode
	STA StarInvincibilityTimer
	STA BigVeggiesPulled
	STA CherryCount
	STA StopwatchTimer
	DEY
	BNE loc_BANKF_E69F

	STY PlayerCurrentSize
	JSR LevelInitialization

	LDA #$FF
	STA CurrentMusicIndex
	; this looks like an address
	LDA #$25
	STA byte_RAM_7180
	LDA #$48
	STA byte_RAM_7181
	LDA #ScreenUpdateBuffer_TitleCard
	STA CardScreenUpdateIndex
	JSR PauseScreen_Card

AfterDeathJump:
IFDEF INDIE_LIVES
	JMP CharacterSelectMenu
    LDX CurrentCharacter
    LDA PlayerIndependentLives, X
    BEQ +
	JMP StartLevelAfterTitleCard
+
	JMP CharacterSelectMenu
ENDIF
IFNDEF CHARACTER_SELECT_AFTER_DEATH
	JMP StartLevelAfterTitleCard
ENDIF
IFDEF CHARACTER_SELECT_AFTER_DEATH
	JMP CharacterSelectMenu
ENDIF

; ---------------------------------------------------------------------------

loc_BANKF_E69F:
IFDEF HEALTH_REVAMP
	TYA
	PHA
	JSR RestorePlayerToFullHealth
	PLA
	TAY
	LDA #$0
ELSE
	LDA #PlayerHealth_2_HP
	STA PlayerHealth
	LDA #$00
ENDIF

	STA PlayerMaxHealth
	STA KeyUsed
	STA Mushroom1upPulled
	STA Mushroom1Pulled
	STA Mushroom2Pulled
	STA SubspaceVisits
	STA EnemiesKilledForHeart
	DEY
	BEQ DoGameOverStuff

	JMP loc_BANKF_E75A

; ---------------------------------------------------------------------------

DoGameOverStuff:
	STY PlayerCurrentSize
	LDA #Music2_GameOver
	STA MusicQueue2
	JSR WaitForNMI_TurnOffPPU

	JSR ChangeTitleCardCHR

	JSR ClearNametablesAndSprites

	JSR SetBlackAndWhitePalette

	JSR SetScrollXYTo0

	JSR EnableNMI

	JSR WaitForNMI_TurnOnPPU

	LDA #ScreenUpdateBuffer_Text_Game_Over
	STA ScreenUpdateIndex
	LDA #$C0
	STA byte_RAM_6

loc_BANKF_E6E6:
	JSR WaitForNMI

	DEC byte_RAM_6
	BNE loc_BANKF_E6E6

	LDY #$28

loc_BANKF_E6EF:
	LDA Text_Continue, Y
	STA PPUBuffer_67B, Y
	DEY
	BPL loc_BANKF_E6EF

	LDA #$FB
	STA byte_RAM_68F
	LDA Continues
	CLC
	ADC #$D0
	STA byte_RAM_67E
	LDA #$00
	STA byte_RAM_8
	LDA #ScreenUpdateBuffer_RAM_67B
	DEC Continues
	BPL loc_BANKF_E717

	LDA #$01
	STA byte_RAM_8
	LDA #ScreenUpdateBuffer_Text_Retry

loc_BANKF_E717:
	STA ScreenUpdateIndex

loc_BANKF_E719:
	JSR WaitForNMI

	LDA Player1JoypadPress
	AND #ControllerInput_Select
	BEQ loc_BANKF_E747

	LDA byte_RAM_8
	EOR #$01
	STA byte_RAM_8
	LDY Continues
	CPY #$FF
	BNE loc_BANKF_E733

	LDA #$01
	STA byte_RAM_8

loc_BANKF_E733:
	ASL A
	ASL A
	TAY
	LDA #$FB
	STA byte_RAM_71AB
	STA byte_RAM_71AF
	LDA #$F6
	STA byte_RAM_71AB, Y
	LDA #ScreenUpdateBuffer_RAM_71a8
	STA ScreenUpdateIndex

loc_BANKF_E747:
	LDA Player1JoypadPress
	AND #ControllerInput_Start
	BEQ loc_BANKF_E719

	LDA byte_RAM_8
	BNE GameOver_Retry

	STA SlotMachineCoins
	JMP ContinueGame

; ---------------------------------------------------------------------------

GameOver_Retry:
	JMP StartGame

; ---------------------------------------------------------------------------

loc_BANKF_E75A:
	DEY
	BEQ EndOfLevel

	LDY CurrentWorld
	STY PreviousWorld
	LDA WarpDestinations, Y
	STA CurrentWorld
	TAY
	LDX CurrentCharacter
	LDA WorldStartingLevel, Y
	STA CurrentLevel
	STA CurrentLevel_Init
	INY
	TYA
	ORA #$D0
	STA byte_RAM_71A6
	JSR WaitForNMI_TurnOffPPU

	JSR SetScrollXYTo0

	JSR ClearNametablesAndSprites

	JSR SetBlackAndWhitePalette

	JSR EnableNMI

	JSR ChangeTitleCardCHR

	LDA #ScreenUpdateBuffer_RAM_7194
	STA ScreenUpdateIndex
	LDA #Music2_SlotWarpFanfare
	STA MusicQueue2
	JSR Delay160Frames

	JSR InitializeSomeLevelStuff

	JMP CharacterSelectMenu

; ---------------------------------------------------------------------------

EndOfLevel:
	; Stop the music
	LDA #Music2_StopMusic ; Stop music
	STA MusicQueue2

	; Increase current characters "contribution" counter
	LDX CurrentCharacter
	INC CharacterLevelsCompleted, X

IFDEF FLAG_SYSTEM
    LDA Level_Count_Crystals
    CMP CrystalCondition
    BCC ++ 
    LDA World_Count_Bosses 
    CMP BossCondition 
    BCC ++
    LDA RescueCondition 
    BEQ +
    LDA CharacterLock_Variable
    BNE ++
    JMP +
++  JMP EndOfLevelJump
+   ; Check if we've completed the final level
	LDA WinLevel
    CMP #$FF
    BNE +
    JMP EndingSceneRoutine
+   CMP CurrentLevelAreaIndex
    BNE EndOfLevelSlotMachine
    JMP EndingSceneRoutine
ENDIF

IFDEF RANDOMIZER_FLAGS
	LDA WinLevel
    CMP #$FF
    BNE +
    JMP EndingSceneRoutine
+   CMP CurrentLevelAreaIndex
    BNE EndOfLevelSlotMachine
    JMP EndingSceneRoutine
ENDIF

	; Check if we've completed the final level
	LDA CurrentLevel
	CMP #$13
IFNDEF DISABLE_BONUS_CHANCE
	; If not, go to bonus chance and proceed to the next level
EndOfLevelJump:
	BNE EndOfLevelSlotMachine
ENDIF
IFDEF DISABLE_BONUS_CHANCE
	STY PlayerCurrentSize
EndOfLevelJump:
	BNE GoToNextLevel
ENDIF
	; Otherwise, display the ending
	JMP EndingSceneRoutine

EndOfLevelSlotMachine:
	STY PlayerCurrentSize
	JSR WaitForNMI_TurnOffPPU

	JSR ClearNametablesAndSprites

IFDEF REV_A
	JSR EnableNMI
	JSR WaitForNMI
ENDIF

	JSR LoadBonusChanceCHRBanks

IFNDEF BONUS_CHANCE_RAM_CLEANUP
	JSR CopyUnusedCoinSpriteToSpriteArea
ENDIF

	LDA #PRGBank_A_B
	JSR ChangeMappedPRGBank

	JSR CopyBonusChanceLayoutToRAM

	LDA #ScreenUpdateBuffer_RAM_BonusChanceLayout
	STA ScreenUpdateIndex
	LDA #Stack100_Menu
	STA StackArea
	JSR EnableNMI

	JSR WaitForNMI

	LDA #Stack100_Gameplay
	STA StackArea
	JSR DisableNMI

	JSR sub_BANKF_EA33

	LDA #Music2_SlotWarpFanfare
	STA MusicQueue2
	LDA SlotMachineCoins
	BNE loc_BANKF_E7F2

	JMP NoCoinsForSlotMachine

; ---------------------------------------------------------------------------

loc_BANKF_E7F2:
	LDA #$03
	STA ObjectXLo + 3
	STA ObjectXLo + 4
	STA ObjectXLo + 5
	JSR WaitForNMI_TurnOnPPU

IFDEF INDIE_LIVES
    LDA IndependentLives
    BEQ +
    LDX CurrentCharacter
    LDA PlayerIndependentLives, X
    STA ExtraLives
+
ENDIF

loc_BANKF_E7FD:
	LDA SlotMachineCoins
	BNE StartSlotMachine

GoToNextLevel:
IFDEF INDIE_LIVES
    LDA IndependentLives
    BEQ +
    LDA ExtraLives
    LDX CurrentCharacter
    STA PlayerIndependentLives, X
+
ENDIF
IFDEF CUSTOM_LEVEL_RLE
	JMP GoToNextLevel_SameWorld
ENDIF
	; Check if this is the last level before the next world
	LDY CurrentWorld
	LDA WorldStartingLevel + 1, Y
	SEC
	SBC #$01
	CMP CurrentLevel
	BNE GoToNextLevel_SameWorld

	JSR SetStack100Gameplay

	LDA #$FF
	STA CurrentMusicIndex
	INC CurrentWorld
	JMP GoToWorldStartingLevel

GoToNextLevel_SameWorld:
	JSR FollowCurrentAreaPointer

	; Sanity check that ensure that the world matches the level.
	; Without this, an area pointer at the end of a level that points to a
	; a different world would load incorrectly (eg. 2-1 would load as 1-4).
	; This scenario may not actually occur during normal gameplay.
	LDA CurrentLevel
	LDY #$00
EnsureCorrectWorld_Loop:
	INY
	CMP WorldStartingLevel, Y
	BCS EnsureCorrectWorld_Loop

	DEY
	STY CurrentWorld

	; Initialize the current area and then go to the character select menu
	LDY CurrentWorld
	LDA CurrentLevel
	SEC
	SBC WorldStartingLevel, Y
	STA CurrentLevelRelative
	LDA CurrentLevel
	STA CurrentLevel_Init
	LDA CurrentLevelArea
	STA CurrentLevelArea_Init
	LDA CurrentLevelEntryPage
	STA CurrentLevelEntryPage_Init
	LDY #$00
	STY PlayerState_Init
	STY TransitionType
	STY TransitionType_Init
	DEY
	STY CurrentMusicIndex
	JSR SetStack100Gameplay

	JMP CharacterSelectMenu


StartSlotMachine:
	DEC SlotMachineCoins
	JSR WaitForNMI

	JSR sub_BANKF_EA68

	LDA #$01 ; Set all reel timers
	STA ObjectXLo
	STA ObjectXLo + 1
	STA ObjectXLo + 2
	LSR A ; Set all reels to the first position
	STA ObjectXLo + 6
	STA ObjectXLo + 7
	STA ObjectXLo + 8

DoSlotMachineSpinnyShit:
	JSR WaitForNMI ; $2C-$2E: Reel change timer
	; $2F-$31: Current reel icon

	LDA #SoundEffect2_Climbing ; Play "reel sound" sound effect
	STA SoundEffectQueue2
	JSR sub_BANKF_EAC2

	JSR sub_BANKF_EADC

	JSR sub_BANKF_EAF6

	JSR sub_BANKF_E916

	LDA byte_BANKF_E9DF, Y
	STA ScreenUpdateIndex
	INC byte_RAM_6
	LDA ObjectXLo ; Reel 1 still active?
	ORA ObjectXLo + 1 ; Reel 2 still active?
	ORA ObjectXLo + 2 ; Reel 3 still active?
	BNE DoSlotMachineSpinnyShit ; If any are still active, go back to waiting

	LDA #ScreenUpdateBuffer_RAM_6df
	STA ScreenUpdateIndex
	JSR WaitForNMI

	LDY #$00
	LDX ObjectXLo + 6 ; Load reel 1
	LDA SlotMachineReelOrder1RAM, X
	BNE CheckReel2Symbol ; Is this reel a cherry?

	INY ; Yes; add one life

CheckReel2Symbol:
	LDX ObjectXLo + 7 ; Load reel 2
	CMP SlotMachineReelOrder2RAM, X
	BNE AddSlotMachineExtraLives ; Does this match the previous symbol?

	CMP #$00 ; Yes; are they both cherries?
	BNE CheckReel3Symbol ; If no, skip to third reel

	INY ; They are both cherries, add another life or something

CheckReel3Symbol:
	LDX ObjectXLo + 8 ; Load reel 3
	CMP SlotMachineReelOrder3RAM, X ; Does reel 3 match the previous two?
	BNE AddSlotMachineExtraLives ; No, fuck you

	INY ; They all match! Yay! Add a life.
; Cherry count: 3 / Non-cherry: 1
	CMP #$00 ; Were they all cherries?
	BNE AddSlotMachineExtraLives ; Nope, all done

	INY ; Yes, add 2 more extra lives
	INY

AddSlotMachineExtraLives:
	TYA ; Y contains extra lives to add
	CLC
	ADC ExtraLives ; Add won extra lives to current lives
	BCC loc_BANKF_E8D3 ; Check if adding extra lives has wrapped the counter

	LDA #$FF ; If so, set extra lives to 255 (#$FF)

loc_BANKF_E8D3:
	STA ExtraLives
	TYA ; Did we actually win any lives?
	BEQ SlotMachineLoseFanfare ; No, play lose sound effect

	ORA #$D0
	STA byte_RAM_6C8
	LDA #Music2_CrystalGetFanfare ; Play winner jingle
	STA MusicQueue2
	LDA #$A0
	STA byte_RAM_6
	JSR WaitForNMI

	JSR sub_BANKF_EA68

loc_BANKF_E8ED:
	JSR WaitForNMI

	JSR sub_BANKF_E916

	LDA byte_BANKF_E9E3, Y
	STA ScreenUpdateIndex
	DEC byte_RAM_6
	BNE loc_BANKF_E8ED

	BEQ loc_BANKF_E90C

SlotMachineLoseFanfare:
	LDA #Music2_DeathJingle
	STA MusicQueue2
	JSR WaitForNMI

	JSR sub_BANKF_EA68

	JSR Delay160Frames

loc_BANKF_E90C:
	LDA #ScreenUpdateBuffer_RAM_6e4
	STA ScreenUpdateIndex
	JSR WaitForNMI

	JMP loc_BANKF_E7FD

; =============== S U B R O U T I N E =======================================

sub_BANKF_E916:
	LDA byte_RAM_6
	LSR A
	LSR A
	LSR A
	LSR A
	AND #$01
	TAY
	RTS

; End of function sub_BANKF_E916

; ---------------------------------------------------------------------------

NoCoinsForSlotMachine:
	JSR Delay80Frames

	LDA #Music2_DeathJingle
	STA MusicQueue2

IFDEF EXPAND_MUSIC
	LDA #$08
ENDIF
	STA byte_RAM_6
loc_BANKF_E92A:
	LDA byte_RAM_6
	AND #$01
	TAY
	LDA byte_BANKF_E9E1, Y
	STA ScreenUpdateIndex

	LDA #$0A
	STA byte_RAM_7
loc_BANKF_E938:
	JSR WaitForNMI_TurnOnPPU
	DEC byte_RAM_7
	BNE loc_BANKF_E938

	DEC byte_RAM_6
	BPL loc_BANKF_E92A

	JMP GoToNextLevel


Delay80Frames:
	LDA #$50
	BNE DelayFrames

Delay160Frames:
	LDA #$A0

DelayFrames:
	STA byte_RAM_7
DelayFrames_Loop:
	JSR WaitForNMI_TurnOnPPU
	DEC byte_RAM_7
	BNE DelayFrames_Loop

	RTS


;
; Do the ending!
;
EndingSceneRoutine:
	JSR SetScrollXYTo0

	LDA #$80
	; FDS leftover; $4080 is an old sound register
	; The prototype had two writes to this address!
	; It looks like they missed this one, though.
	STA FDS_WAVETABLE_VOL
	ASL A
	STA SoundEffectPlaying1
	LDA #PRGBank_0_1
	JSR ChangeMappedPRGBank

	JSR FreeSubconsScene

	JSR WaitForNMI_TurnOffPPU

	JSR DisableNMI

	JSR LoadCelebrationSceneBackgroundCHR

	JSR EnableNMI

	JSR WaitForNMI

	LDA #PRGBank_0_1
	JSR ChangeMappedPRGBank

	INC GameMilestoneCounter

IFNDEF EXCLUDE_MARIO_DREAM
	JSR ContributorScene

	JSR WaitForNMI_TurnOffPPU

	JSR DisableNMI

SetupMarioSleepingScene:
	JSR LoadMarioSleepingCHRBanks

	JSR EnableNMI

	JSR WaitForNMI

	LDA #PRGBank_C_D
	JSR ChangeMappedPRGBank

	INC GameMilestoneCounter
	JMP MarioSleepingScene
ELSE
	JMP ContributorScene
ENDIF


; =============== S U B R O U T I N E =======================================

DisableNMI:
	LDA #PPUCtrl_Base2000 | PPUCtrl_WriteHorizontal | PPUCtrl_Sprite0000 | PPUCtrl_Background1000 | PPUCtrl_SpriteSize8x16 | PPUCtrl_NMIDisabled
	STA PPUCTRL
	STA PPUCtrlMirror
	RTS

; End of function DisableNMI

; ---------------------------------------------------------------------------
PPUBuffer_Text_Game_Over:
	.db $21, $CB, $0A, $E0, $DA, $E6, $DE, $FB, $FB, $E8, $EF, $DE
	.db $EB, $00 ; $C ; "GAME OVER"
Text_Continue:
	.db $21, $75, $01, $00 ; (Placeholder for continue count)
; This is loaded manually and drawn so the count
; can be patched in
; * CONTINUE
	.db $21, $6A, $0A, $F6, $FB, $DC, $E8, $E7, $ED, $E2, $E7, $EE
	.db $DE ; $C
PPUBuffer_Text_Retry:
	.db $21, $AA, $07, $F6, $FB, $EB, $DE, $ED, $EB, $F2 ; * RETRY
	.db $21, $CB, $0A, $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB ; Blank, erases "GAME OVER"
	.db $FB, $00 ; $C
	.db $09
	.db $0F
byte_BANKF_E9DF:
	.db ScreenUpdateBuffer_RAM_6ab
	.db ScreenUpdateBuffer_RAM_6df
byte_BANKF_E9E1:
	.db ScreenUpdateBuffer_RAM_693
	.db ScreenUpdateBuffer_RAM_6da
byte_BANKF_E9E3:
	.db ScreenUpdateBuffer_RAM_6bd
	.db ScreenUpdateBuffer_RAM_6da

; =============== S U B R O U T I N E =======================================

;
; Displays extra life info on the pause screen
;
PauseScreen_ExtraLife:
	LDA #ScreenUpdateBuffer_PauseExtraLife
	STA CardScreenUpdateIndex
	LDA #$26
	STA byte_RAM_7180
	LDA #$C8
	STA byte_RAM_7181

;
; Loads the palette and graphics for the pause screen to display
;
PauseScreen_Card:
	JSR WaitForNMI_TurnOffPPU

	JSR ChangeTitleCardCHR

	LDA #PRGBank_0_1
	JSR ChangeMappedPRGBank

	JSR StashScreenScrollPosition

	; Load title card palette
	LDY #$23
PauseScreen_Card_Loop:
	LDA TitleCardPalettes, Y
	STA PPUBuffer_55F, Y
	DEY
	BPL PauseScreen_Card_Loop

PauseScreen_Card_ScreenReset:
	JSR ResetScreenForTitleCard

	JSR EnableNMI_PauseTitleCard

	LDX CurrentWorld
	LDY CurrentLevel
	JSR DisplayLevelTitleCardText

	LDA #$FF
	STA PPUScrollXMirror
	JSR WaitForNMI

	LDA CardScreenUpdateIndex
	STA ScreenUpdateIndex
	JSR WaitForNMI

IFDEF CUSTOM_MUSH
	JSR TestMyDraw
ENDIF

EnableNMI:
	LDA #PPUCtrl_Base2000 | PPUCtrl_WriteHorizontal | PPUCtrl_Sprite0000 | PPUCtrl_Background1000 | PPUCtrl_SpriteSize8x16 | PPUCtrl_NMIEnabled
	STA PPUCtrlMirror
	STA PPUCTRL
	RTS


; =============== S U B R O U T I N E =======================================

sub_BANKF_EA33:
	JSR SetScrollXYTo0

	LDA PPUSTATUS
	LDY #$00
	LDA #$3F
	STA PPUADDR
	STY PPUADDR

loc_BANKF_EA43:
	LDA unk_RAM_59C, Y
	STA PPUDATA
	INY
	CPY #$10
	BCC loc_BANKF_EA43

	LDY #$00
	LDA PPUSTATUS
	LDA #$3F
	STA PPUADDR
	LDA #$10
	STA PPUADDR

SetBonusChancePalette:
	LDA BonusChanceSpritePalettes, Y
	STA PPUDATA
	INY
	CPY #$10
	BCC SetBonusChancePalette

; End of function sub_BANKF_EA33

; =============== S U B R O U T I N E =======================================

sub_BANKF_EA68:
	LDY ExtraLives
	DEY
	TYA
	JSR GetTwoDigitNumberTiles

	STY byte_RAM_599
	STA byte_RAM_59A
	LDA SlotMachineCoins
	CLC
	ADC #$D0
	STA byte_RAM_588
	LDA #ScreenUpdateBuffer_RAM_583
	STA ScreenUpdateIndex
	LDA #Stack100_Menu
	STA StackArea
	JSR EnableNMI

	JMP WaitForNMI

; End of function sub_BANKF_EA68

IFDEF FLAG_SYSTEM
	.include "src/extras/flag-set.asm"
ENDIF

IFDEF CUSTOM_MUSH
	.include "src/extras/player-stuff.asm"
ENDIF

IFDEF CHAR_SWITCH
.include "src/extras/player/char_switch_f.asm"
ENDIF

;
; Converts a number to numerical tiles with space for 2 digits
;
; ##### Input
; - `A` = number to display
;
; ##### Output
; - `A`: second digit of the number (ones)
; - `Y`: first digit of the number (tens)
;
GetTwoDigitNumberTiles:
	LDY #$D0 ; zero

GetTwoDigitNumberTiles_TensLoop:
	; Count up the tens digit until A < 10
	CMP #$0A
	BCC GetTwoDigitNumberTiles_Ones

	SBC #$0A
	INY
	JMP GetTwoDigitNumberTiles_TensLoop

GetTwoDigitNumberTiles_Ones:
	ORA #$D0
	CPY #$D0
	BNE GetTwoDigitNumberTiles_Exit

	LDY #$FB

GetTwoDigitNumberTiles_Exit:
	RTS


WaitForNMI_TurnOffPPU:
	LDA #$00
	BEQ _WaitForNMI_StuffPPUMask ; Branch always

WaitForNMI_TurnOnPPU:
	LDA #PPUMask_ShowLeft8Pixels_BG | PPUMask_ShowLeft8Pixels_SPR | PPUMask_ShowBackground | PPUMask_ShowSprites

_WaitForNMI_StuffPPUMask:
	STA PPUMaskMirror

WaitForNMI:
	LDA ScreenUpdateIndex
	ASL A
	TAX
	LDA ScreenUpdateBufferPointers, X
	STA RAM_PPUDataBufferPointer
	LDA ScreenUpdateBufferPointers + 1, X
	STA RAM_PPUDataBufferPointer + 1

	LDA #$00
	STA NMIWaitFlag ; Start waiting for NMI to finish
WaitForNMILoop:
	LDA NMIWaitFlag ; Has the NMI routine set the flag yet?
	BPL WaitForNMILoop ; If no, wait some more

	RTS ; If yes, go back to what we were doing


; =============== S U B R O U T I N E =======================================

sub_BANKF_EAC2:
	LDA Player1JoypadPress
	BPL locret_BANKF_EAD1

	LDX #$00

loc_BANKF_EAC8:
	LDA ObjectXLo, X
	BNE loc_BANKF_EAD2

	INX
	CPX #$03
	BCC loc_BANKF_EAC8

locret_BANKF_EAD1:
	RTS

; ---------------------------------------------------------------------------

loc_BANKF_EAD2:
	LDA #$00
	STA ObjectXLo, X
	LDA #SoundEffect1_CherryGet
	STA SoundEffectQueue1
	RTS

; End of function sub_BANKF_EAC2

; =============== S U B R O U T I N E =======================================

sub_BANKF_EADC:
	LDX #$02

loc_BANKF_EADE:
	LDA ObjectXLo, X
	BEQ loc_BANKF_EAF2

	DEC ObjectXLo + 3, X
	BNE loc_BANKF_EAF2

	LDA #$04
	STA ObjectXLo + 3, X
	DEC ObjectXLo + 6, X
	BPL loc_BANKF_EAF2

	LDA #$07
	STA ObjectXLo + 6, X

loc_BANKF_EAF2:
	DEX
	BPL loc_BANKF_EADE

	RTS

; End of function sub_BANKF_EADC

; =============== S U B R O U T I N E =======================================

sub_BANKF_EAF6:
	LDA #$02
	STA byte_RAM_0

loc_BANKF_EAFA:
	LDA byte_RAM_0
	TAY
	ASL A
	ASL A
	ASL A
	TAX
	ADC ObjectXLo + 6, Y
	TAY
	LDA SlotMachineReelOrder1RAM, Y
	TAY
	LDA #$07
	STA byte_RAM_1

loc_BANKF_EB0D:
	LDA BonusChanceCherrySprite, Y
	STA SpriteDMAArea + $10, X
	INX
	INY
	DEC byte_RAM_1
	BPL loc_BANKF_EB0D

	DEC byte_RAM_0
	BPL loc_BANKF_EAFA

	LDX #$17

loc_BANKF_EB1F:
	TXA
	AND #$18
	ASL A
	ASL A
	ADC SpriteDMAArea + $10, X
	STA SpriteDMAArea + $10, X
	DEX
	DEX
	DEX
	DEX
	BPL loc_BANKF_EB1F

	RTS

; End of function sub_BANKF_EAF6

IFNDEF BONUS_CHANCE_RAM_CLEANUP
;
; Copies the unused coin sprite from memory into the sprite DMA area at $200
;
CopyUnusedCoinSpriteToSpriteArea:
	LDY #$00

CopyUnusedCoinSpriteToSpriteArea_Loop:
	LDA unk_RAM_653, Y ; Copy two sprites from memory to memory.
	STA SpriteDMAArea + $28, Y ; This is definitely efficient.
	INY ; Two sprites for each half of the coin.
	CPY #$08 ; Four bytes per sprite * 2 sprites = 8 bytes
	BCC CopyUnusedCoinSpriteToSpriteArea_Loop

	RTS
ENDIF

;
; NMI logic for during a transition
;
NMI_Transition:
	LDA #$00
	STA OAMADDR
	LDA #$02
	STA OAM_DMA
	JSR ChangeCHRBanks

	LDA PPUMaskMirror
	STA PPUMASK
	JSR DoSoundProcessing

	LDA PPUCtrlMirror
	STA PPUCTRL
	DEC NMIWaitFlag
	JMP NMI_Exit


;
; NMI logic for during the pause menu
;
NMI_PauseOrMenu:
	LDA #$00
	STA PPUMASK
	STA OAMADDR
	LDA #$02
	STA OAM_DMA
	JSR ChangeCHRBanks

	JSR UpdatePPUFromBufferWithOptions

	JSR ResetPPUAddress

	LDA PPUScrollXMirror
	STA PPUSCROLL
	LDA #$00
	STA PPUSCROLL
	LDA PPUMaskMirror
	STA PPUMASK
	JMP NMI_CheckScreenUpdateIndex


;
; When waiting for an NMI, just run the audio engine
;
NMI_Waiting:
	LDA PPUMaskMirror
	STA PPUMASK
	JMP NMI_DoSoundProcessing


;
; Public NMI: where dreams come true!
;
NMI:
	PHP
	PHA
	TXA
	PHA
	TYA
	PHA
	BIT StackArea
	BPL NMI_PauseOrMenu ; branch if bit 7 was 0

	BVC NMI_Transition ; branch if bit 6 was 0

	LDA #$00
	STA PPUMASK
	STA OAMADDR
	LDA #$02
	STA OAM_DMA
	JSR ChangeCHRBanks

	LDA NMIWaitFlag
	BNE NMI_Waiting

NMI_Gameplay:
	; `UpdatePPUFromBufferNMI` draws in a row-oriented fashion, which makes it
	; unsuitable for horizontal levels where scrolling the screen means drawing
	; columns of new tiles. As a result, we need special logic to draw the
	; background in horizontal levels!
	LDA IsHorizontalLevel
	BEQ NMI_AfterBackgroundAttributesUpdate

	LDA HasScrollingPPUTilesUpdate
	BEQ NMI_AfterBackgroundTilesUpdate

	; Update nametable tiles in horizontal level
	LDA #$00
	STA HasScrollingPPUTilesUpdate
	LDX #$1E
	LDY #$00
	LDA PPUSTATUS
	LDA #PPUCtrl_Base2000 | PPUCtrl_WriteVertical | PPUCtrl_Sprite0000 | PPUCtrl_Background1000 | PPUCtrl_SpriteSize8x16 | PPUCtrl_NMIEnabled
	STA PPUCTRL

NMI_DrawBackgroundTilesOuterLoop:
	LDA_abs DrawBackgroundTilesPPUAddrHi
	STA PPUADDR
	LDA_abs DrawBackgroundTilesPPUAddrLo
	STA PPUADDR

NMI_DrawBackgroundTilesInnerLoop:
	LDA ScrollingPPUTileUpdateBuffer, Y
	STA PPUDATA
	INY
	DEX
	BNE NMI_DrawBackgroundTilesInnerLoop

	LDX #$1E
	INC_abs DrawBackgroundTilesPPUAddrLo

	CPY #$3C
	BNE NMI_DrawBackgroundTilesOuterLoop

NMI_AfterBackgroundTilesUpdate:
	LDA DrawBackgroundAttributesPPUAddrHi
	BEQ NMI_AfterBackgroundAttributesUpdate

	; Update nametable attributes in horizontal level
	LDA #PPUCtrl_Base2000 | PPUCtrl_WriteVertical | PPUCtrl_Sprite0000 | PPUCtrl_Background1000 | PPUCtrl_SpriteSize8x16 | PPUCtrl_NMIEnabled
	STA PPUCTRL
	LDY #$00
	LDX #$04

NMI_DrawBackgroundAttributesOuterLoop:
	LDA PPUSTATUS
	LDA DrawBackgroundAttributesPPUAddrHi
	STA PPUADDR
	LDA DrawBackgroundAttributesPPUAddrLo
	STA PPUADDR

NMI_DrawBackgroundAttributesInnerLoop:
	LDA HorizontalScrollingPPUAttributeUpdateBuffer, Y
	STA PPUDATA
	INY
	TYA
	LSR A
	BCS NMI_DrawBackgroundAttributesInnerLoop

	LDA DrawBackgroundAttributesPPUAddrLo
	CLC
	ADC #$08
	STA DrawBackgroundAttributesPPUAddrLo
	DEX
	BNE NMI_DrawBackgroundAttributesOuterLoop

	STX DrawBackgroundAttributesPPUAddrHi

NMI_AfterBackgroundAttributesUpdate:
	JSR UpdatePPUFromBufferNMI

	JSR ResetPPUAddress

	LDA #$B0
	ORA PPUScrollXHiMirror
	LDY IsHorizontalLevel
	BNE NMI_UpdatePPUScroll

	AND #$FE
	ORA PPUScrollYHiMirror

NMI_UpdatePPUScroll:
	STA PPUCTRL
	STA PPUCtrlMirror
	LDA PPUScrollXMirror
	STA PPUSCROLL
	LDA PPUScrollYMirror
	CLC
	ADC BackgroundYOffset
	STA PPUSCROLL
	LDA PPUMaskMirror
	STA PPUMASK
	INC byte_RAM_10

NMI_CheckScreenUpdateIndex:
	LDA ScreenUpdateIndex
	BNE NMI_ResetScreenUpdateIndex

	; Turn off PPU buffer 301 update
	STA byte_RAM_300
	STA PPUBuffer_301

NMI_ResetScreenUpdateIndex:
	LDA #ScreenUpdateBuffer_RAM_301
	STA ScreenUpdateIndex
	JSR UpdateJoypads

	DEC NMIWaitFlag

NMI_DoSoundProcessing:
	JSR DoSoundProcessing

IFDEF DEBUG
DebugHook:
; Hook into debug routine if select is pressed
	LDA Player1JoypadPress
	CMP #ControllerInput_Select | ControllerInput_Start
	BNE NMI_Exit
	LDA #>Debug_Init
	PHA
	LDA #<Debug_Init
	PHA
	PHP
	RTI
ENDIF

NMI_Exit:
	PLA
	TAY
	PLA
	TAX
	PLA
	PLP
	RTI

; End of function NMI

;
; Sets the PPU address to `$3f00`, then immediatley to `$0000`
;
; Speculation is that this ritual comes from a recommendation in some Nintendo
; documentation, but isn't actually necessary.
;
; See: https://forums.nesdev.com/viewtopic.php?f=2&t=16721
;
ResetPPUAddress:
	LDA PPUSTATUS
	LDA #$3F
	STA PPUADDR
	LDA #$00
	STA PPUADDR
	STA PPUADDR
	STA PPUADDR
	RTS


DoSoundProcessing:
	LDA #PRGBank_4_5
	JSR ChangeMappedPRGBankWithoutSaving

	JSR StartProcessingSoundQueue

	LDA MMC3PRGBankTemp
	JMP ChangeMappedPRGBank


ClearNametablesAndSprites:
	LDA #$00
	STA PPUMaskMirror
	STA PPUMASK
	LDA #$20
	JSR ClearNametableChunk

	LDA #$24
	JSR ClearNametableChunk

	LDA #$28
	JSR ClearNametableChunk


HideAllSprites:
	LDY #$00
	LDA #$F8

HideAllSpritesLoop:
	STA SpriteDMAArea, Y
	DEY
	DEY
	DEY
	DEY
	BNE HideAllSpritesLoop

	RTS


ClearNametableChunk:
	LDY PPUSTATUS ; Reset PPU address latch
	LDY #PPUCtrl_Base2000 | PPUCtrl_WriteHorizontal | PPUCtrl_Sprite0000 | PPUCtrl_Background1000 | PPUCtrl_SpriteSize8x16 | PPUCtrl_NMIDisabled
	STY PPUCTRL ; Turn off NMI
	STY PPUCtrlMirror
	LDY #$00
	; A contains the high byte of the PPU address (generally $20, $24, $28)
	STA PPUADDR
	STY PPUADDR ; And Y has the low byte ($00)
	LDX #$03 ; Do $300 bytes for this loop.
	LDA #$FB

ClearNametableChunk_Loop:
	STA PPUDATA ; Store the blank tile $300 times
	INY
	BNE ClearNametableChunk_Loop ; (Loop falls through every $100 bytes)

	DEX
	BNE ClearNametableChunk_Loop ; Loop falls through after $300 bytes

ClearNametableChunk_Loop2:
	; Do another loop of $C0 bytes to clear the
	; rest of the nametable chunk
	STA PPUDATA
	INY
	CPY #$C0
	BNE ClearNametableChunk_Loop2

	LDA #$00 ; Load A with $00 for clearing the attribute tables

ClearNametableChunk_AttributeTableLoop:
	STA PPUDATA ; Clear attribute table...
	INY ; Y was $C0 on entry, so write $40 bytes...
	BNE ClearNametableChunk_AttributeTableLoop

PPUBufferUpdatesComplete:
	RTS ; Woo fucking hoo


;
; Used to update the PPU nametable / palette data during NMI.
;
; This function can only handle $100 bytes of data
; (actually less).
;
; Unlike `UpdatePPUFromBufferWithOptions`, this one does not support
; $80 or $40 as options, instead treating them as direct length.
; It also does not increment the buffer pointer, only using Y
; to read further data.
;
; If Y overflows, it will resume copying again from the beginning,
; and can get into an infinite loop if it doesn't encounter
; a terminating $00. Welp!
;
UpdatePPUFromBufferNMI:
	LDA #PPUCtrl_Base2000 | PPUCtrl_WriteHorizontal | PPUCtrl_Sprite0000 | PPUCtrl_Background1000 | PPUCtrl_SpriteSize8x16 | PPUCtrl_NMIEnabled
	STA PPUCTRL
	LDY #$00

UpdatePPUFromBufferNMI_CheckForBuffer:
	LDA (RAM_PPUDataBufferPointer), Y
	BEQ PPUBufferUpdatesComplete

	LDX PPUSTATUS
	STA PPUADDR
	INY
	LDA (RAM_PPUDataBufferPointer), Y
	STA PPUADDR
	INY
	LDA (RAM_PPUDataBufferPointer), Y
	TAX

UpdatePPUFromBufferNMI_CopyLoop:
	INY
	LDA (RAM_PPUDataBufferPointer), Y
	STA PPUDATA
	DEX
	BNE UpdatePPUFromBufferNMI_CopyLoop

	INY
	JMP UpdatePPUFromBufferNMI_CheckForBuffer


;
; This reads from $F0/$F1 to determine where a "buffer" is.
; Basically, a buffer is like this:
;
; PPUADDR  LEN DATA ......
; $20 $04  $03 $E9 $F0 $FB
; $25 $5F  $4F $FB
; $21 $82  $84 $00 $01 $02 $03
; $00
;
; PPUADDR is two bytes (hi,lo) for the address to send to PPUADDR.
; LEN is the length, with the following two bitmasks:
;
;  - $80: Set the "draw vertically" option
;  - $40: Use ONE tile instead of a string
;
; DATA is either (LEN) bytes or one byte.
;
; After (LEN) bytes have been written, the buffer pointer
; is incremented to (LEN+2) and the function restarts.
; A byte of $00 terminates execution and returns.
;
; There is a similar function, `UpdatePPUFromBufferNMI`,
; that is called during NMI, but unlike this one,
; that one does NOT use bitmasks, nor increment the pointer.
;
UpdatePPUFromBufferWithOptions:
	; First, check if we have anything to send to the PPU
	LDY #$00
	LDA (RAM_PPUDataBufferPointer), Y
	; If the first byte at the buffer address is #$00, we have nothing. We're done here!
	BEQ PPUBufferUpdatesComplete

	; Clear address latch
	LDX PPUSTATUS
	; Set the PPU address to the
	; address from the PPU buffer
	STA PPUADDR
	INY
	LDA (RAM_PPUDataBufferPointer), Y
	STA PPUADDR
	INY
	LDA (RAM_PPUDataBufferPointer), Y ; Data segment length byte...
	ASL A
	PHA
	; Enable NMI + Vertical increment + whatever else was already set...
	LDA PPUCtrlMirror
	ORA #PPUCtrl_Base2000 | PPUCtrl_WriteVertical | PPUCtrl_Sprite0000 | PPUCtrl_Background0000 | PPUCtrl_SpriteSize8x8 | PPUCtrl_NMIEnabled
	; ...but only if $80 was set in the length byte. Otherwise, turn vertical incrementing back off.
	BCS UpdatePPUFBWO_EnableVerticalIncrement

	AND #PPUCtrl_Base2C00 | PPUCtrl_WriteHorizontal | PPUCtrl_Sprite1000 | PPUCtrl_Background1000 | PPUCtrl_SpriteSize8x16 | PPUCtrl_NMIEnabled | $40

UpdatePPUFBWO_EnableVerticalIncrement:
	STA PPUCTRL
	PLA
	; Check if the second bit ($40) in the length has been set
	ASL A
	; If not, we are copying a string of data
	BCC UpdatePPUFBWO_CopyStringOfTiles

	; Length (A) is now (A << 2).
	; OR in #$02 now if we are copying a single tile;
	; This will be rotated out into register C momentarily
	ORA #$02
	INY

UpdatePPUFBWO_CopyStringOfTiles:
	; Restore the data length.
	; A = (Length & #$3F)
	LSR A

	; This moves the second bit (used above to signal
	; "one tile mode") into the Carry register
	LSR A
	TAX ; Copy the length into register X

UpdatePPUFBWO_CopyLoop:
	; If Carry is set (from above), we're only copying one tile.
	; Do not increment Y to advance copying index
	BCS UpdatePPUFBWO_CopySingleTileSkip

	INY

UpdatePPUFBWO_CopySingleTileSkip:
	LDA (RAM_PPUDataBufferPointer), Y ; Load data from buffer...
	STA PPUDATA ; ...store it to the PPU.
	DEX ; Decrease remaining length.
	BNE UpdatePPUFBWO_CopyLoop ; Are we done? If no, copy more stuff

	INY ; Y contains the amount of copied data now
	TYA ; ...and now A does
	CLC ; Clear carry bit (from earlier)
	ADC RAM_PPUDataBufferPointer ; Add the length to the PPU data buffer
	STA RAM_PPUDataBufferPointer
	LDA RAM_PPUDataBufferPointer + 1
	; If the length overflowed (carry set),
	; add that to the hi byte of the pointer
	ADC #$00
	STA RAM_PPUDataBufferPointer + 1
	; Start the cycle over again.
	; (If the PPU buffer points to a 0, it will terminate after this jump)
	JMP UpdatePPUFromBufferWithOptions


IFDEF DEBUG
	.include "src/extras/debug/debug-f.asm"
ENDIF

IF INES_MAPPER == MAPPER_FME7
RESET_FME7:
	LDA #$08 ; PRG bank 0
	STA $8000
	LDA #%11000000
	STA $A000

	LDA #$09 ; PRG bank 1
	STA $8000
	LDA #$00 ; ROM bank 0
	STA $A000

	LDA #$0A ; PRG bank 2
	STA $8000
	LDA #$01 ; ROM bank 1
	STA $A000

	LDA #$0B ; PRG bank 3
	STA $8000
	LDA #$0E ; ROM bank E
	STA $A000

	JMP RESET


ChangeCHRBanks_FME7:
	LDY BackgroundCHR1
	LDA #$04
	STA $8000
	STY $A000

	INY
	LDA #$05
	STA $8000
	STY $A000

	LDY BackgroundCHR2
	LDA #$06
	STA $8000
	STY $A000

	INY
	LDA #$07
	STA $8000
	STY $A000

	LDY #$03
ChangeCHRBanks_FME7_Loop:
	TYA
	STA $8000
	LDA SpriteCHR1, Y
	STA $A000
	DEY
	BPL ChangeCHRBanks_FME7_Loop

	RTS

ELSEIF INES_MAPPER == MAPPER_MMC5
RESET_MMC5:
	; Set PRG mode 3 and CHR mode 3
	LDA #$03
	STA $5100 ; PRG mode
	STA $5101 ; CHR mode

	; Enable PRG RAM writing
	LDA #$02
	STA $5102 ; PRG RAM Protect 1
	LDA #$01
	STA $5103 ; PRG RAM Protect 2

	; Set nametable mapping
	LDA #%01010000
	STA $5105

	LDA #$00
	STA $5113 ; PRG RAM bank
	STA $5130 ; Upper CHR Bank bits

	LDA #$0F
	STA $5015

	; PRG bank 0
	LDA #$80 ; ROM bank 0
	STA $5114

	; PRG bank 1
	LDA #$81 ; ROM bank 1
	STA $5115

	; PRG bank 2
	LDA #$8E ; ROM bank E
	STA $5116

	; PRG bank 3
	LDA #$8F ; ROM bank F
	STA $5117

	JMP RESET


ChangeCHRBanks_MMC5:
	LDA SpriteCHR1
	STA $5120

	LDA SpriteCHR2
	STA $5121

	LDA SpriteCHR3
	STA $5122

	LDA SpriteCHR4
	STA $5123

	LDA BackgroundCHR1
	STA $5124
	ADC #$01
	STA $5125

	LDA BackgroundCHR2
	STA $5126
	ADC #$01
	STA $5127

	LDA BackgroundCHR1
	STA $5128
	ADC #$01
	STA $5129

	LDA BackgroundCHR2
	STA $512A
	ADC #$01
	STA $512B

	RTS
ENDIF

; Unused space in the original ($ED4D - $EFFF)
unusedSpace $F000, $FF


;
; ## Tile collision bounding boxes
;
; These hitboxes are used when determining the collision between objects and background tiles.
;
; Tile collision bounding box table offsets
;
TileCollisionHitboxIndex:
	.db $00 ; $00 - player standing
	.db $08 ; $01 - player holding item
	.db $10 ; $02 - player ducking
	.db $18 ; $03 - player ducking with item
	.db $20 ; $04 - 16x16 items (vegetables, etc.)
	.db $24 ; $05 - 16x16 enemies (shyguy, etc.)
; The following four entries are used to determine whether a carried item can be thrown.
	.db $28 ; $06 - player left, standing
	.db $2A ; $07 - player left, ducking
	.db $29 ; $08 - player right, standing
	.db $2B ; $09 - player right, ducking
	.db $2C ; $0A - player climb/cherry
	.db $2E ; $0B - player climbing
	.db $30 ; $0C - 16x32 enemies (birdo, mouser)
	.db $34 ; $0D - projectile
	.db $38 ; $0E - 16x48 enemies (tryclde)
	.db $3C ; $0F - spark
	.db $40 ; $10 - flying carpet

;
; ### Tile vertical collision bounding box (x-offsets)
;
; The left boundary offset is measured from the left side of the sprite.
; The right boundary offset is measured from the right of the first tile of the sprite.
;
; Each bounding box entry is four bytes:
;
;   1. left boundary (upward velocity)
;   2. right boundary (upward velocity)
;   3. left boundary (downward velocity)
;   4. right boundary (downward velocity)
;
VerticalTileCollisionHitboxX:
	.db $06, $09, $06, $09 ; $00
	.db $01, $01, $0E, $0E ; $04
	.db $06, $09, $06, $09 ; $08
	.db $01, $01, $0E, $0E ; $0C
	.db $06, $09, $06, $09 ; $10
	.db $01, $01, $0E, $0E ; $14
	.db $06, $09, $06, $09 ; $18
	.db $01, $01, $0E, $0E ; $1C
	.db $08, $08, $00, $0F ; $20
	.db $08, $08, $03, $0C ; $24
	.db $F8, $18, $F8, $18 ; $28
	.db $08, $08, $08, $08 ; $2C
	.db $08, $08, $03, $0C ; $30
	.db $03, $03, $02, $05 ; $34
	.db $08, $08, $03, $0C ; $38
	.db $08, $08, $FF, $10 ; $3C
	.db $10, $10, $02, $1E ; $40

;
; ### Tile vertical collision bounding box (y-offsets)
;
; The upper and lower boundary offset are measured from the top of the sprite.
;
; Each bounding box entry is four bytes:
;
;   1. upper boundary (upward velocity)
;   2. lower boundary (upward velocity)
;   3. upper boundary (downward velocity)
;   4. lower boundary (downward velocity)
;
; Not totally sure why there are two bytes, but it seems to have something to do with the direction
; of movement when checking the collision.
;
VerticalTileCollisionHitboxY:
	.db $07, $07, $20, $20 ; $00
	.db $0D, $1C, $0D, $1C ; $04
	.db $FF, $FF, $20, $20 ; $08
	.db $04, $1C, $04, $1C ; $0C
	.db $0F, $0F, $20, $20 ; $10
	.db $1C, $1C, $1C, $1C ; $14
	.db $07, $07, $20, $20 ; $18
	.db $0D, $1C, $0D, $1C ; $1C
	.db $00, $10, $09, $09 ; $20
	.db $03, $10, $09, $09 ; $24
	.db $FF, $FF, $0F, $0F ; $28
	.db $0C, $14, $07, $20 ; $2C
	.db $FE, $20, $10, $10 ; $30
	.db $09, $0A, $08, $08 ; $34
	.db $03, $30, $18, $18 ; $38
	.db $FF, $10, $08, $08 ; $3C
	.db $09, $0A, $08, $08 ; $40

;
; ## Object vertical collision bounding box
;
; These hitboxes are copied to RAM and used when determining collision between objects. This allows
; the hitboxes to change dynamically, which is used when Hawkmouth (offset $0B) opens and closes.
;
ObjectCollisionHitboxLeft:
	.db $02 ; $00
	.db $02 ; $01
	.db $03 ; $02
	.db $00 ; $03
	.db $03 ; $04
	.db $03 ; $05
	.db $F8 ; $06
	.db $00 ; $07
	.db $03 ; $08
	.db $01 ; $09
	.db $F3 ; $0A
	.db $04 ; $0B
	.db $03 ; $0C
	.db $03 ; $0D
	.db $03 ; $0E
	.db $F2 ; $0F
	.db $03 ; $10
	.db $03 ; $11
	.db $05 ; $12
	.db $03 ; $13

ObjectCollisionHitboxTop:
	.db $0B ; $00
	.db $10 ; $01
	.db $03 ; $02
	.db $00 ; $03
	.db $03 ; $04
	.db $03 ; $05
	.db $F8 ; $06
	.db $00 ; $07
	.db $09 ; $08
	.db $04 ; $09
	.db $03 ; $0A
	.db $03 ; $0B
	.db $0E ; $0C
	.db $03 ; $0D
	.db $03 ; $0E
	.db $03 ; $0F
	.db $F6 ; $10
	.db $0C ; $11
	.db $02 ; $12
	.db $03 ; $13

ObjectCollisionHitboxRight:
	.db $0B ; $00
	.db $0B ; $01
	.db $09 ; $02
	.db $10 ; $03
	.db $09 ; $04
	.db $19 ; $05
	.db $20 ; $06
	.db $20 ; $07
	.db $03 ; $08
	.db $1E ; $09
	.db $19 ; $0A
	.db $08 ; $0B
	.db $09 ; $0C
	.db $09 ; $0D
	.db $09 ; $0E
	.db $18 ; $0F
	.db $09 ; $10
	.db $1A ; $11
	.db $06 ; $12
	.db $15 ; $13

ObjectCollisionHitboxBottom:
	.db $16 ; $00
	.db $11 ; $01
	.db $0D ; $02
	.db $10 ; $03
	.db $1A ; $04
	.db $19 ; $05
	.db $24 ; $06
	.db $10 ; $07
	.db $03 ; $08
	.db $04 ; $09
	.db $2D ; $0A
	.db $30 ; $0B
	.db $0F ; $0C
	.db $2E ; $0D
	.db $3E ; $0E
	.db $1E ; $0F
	.db $28 ; $10
	.db $13 ; $11
	.db $48 ; $12
	.db $26 ; $13


NextSpriteFlickerSlot:
	DEC SpriteFlickerSlot
	BPL NextSpriteFlickerSlot_Exit

	LDA #$08
	STA SpriteFlickerSlot

NextSpriteFlickerSlot_Exit:
	RTS


LevelMusicIndexes:
	.db Music1_Overworld
	.db Music1_Inside ; 1 ; Music1 indexes.
	.db Music1_Boss ; 2
	.db Music1_Wart ; 3
	.db Music1_Subspace ; 4


; =============== S U B R O U T I N E =======================================

sub_BANKF_F0F9:
	JSR NextSpriteFlickerSlot

	LDA PlayerInRocket
	BNE loc_BANKF_F11B

	; boss clear fanfare locks player movement
	LDA MusicPlaying2
	CMP #Music2_BossClearFanfare
	BEQ loc_BANKF_F115

	LDA PlayerLock
	BNE loc_BANKF_F115

	LDA #PRGBank_0_1
	JSR ChangeMappedPRGBank

	JSR HandlePlayerState

loc_BANKF_F115:
	JSR SetPlayerScreenPosition

	JSR RenderPlayer

loc_BANKF_F11B:
	JMP RunFrame_Common

; End of function sub_BANKF_F0F9

;
; Does a lot of important stuff in horizontal levels
;
RunFrame_Horizontal:
	JSR NextSpriteFlickerSlot

	; If the player is in a rocket, cut to the chase
	LDA PlayerInRocket
	BNE RunFrame_Common

	; Switch to banks 0/1 for the scrolling logic
	LDA #PRGBank_0_1
	JSR ChangeMappedPRGBank

	; If the boss clear fanfare is playing or `PlayerLock` is set, skip the
	; player state update subroutine
	LDA MusicPlaying2
	CMP #Music2_BossClearFanfare
	BEQ RunFrame_Horizontal_AfterPlayerState

	LDA PlayerLock
	BNE RunFrame_Horizontal_AfterPlayerState

	JSR HandlePlayerState

RunFrame_Horizontal_AfterPlayerState:
	JSR GetMoveCameraX

	JSR ApplyHorizontalScroll

	JSR SetPlayerScreenPosition

	JSR RenderPlayer

; back to the shared stuff
RunFrame_Common:
	LDA #PRGBank_2_3
	JSR ChangeMappedPRGBank

	JSR AreaMainRoutine

IFNDEF SECONDARY_ROUTINE_MOVE
	JSR AreaSecondaryRoutine
ELSE
	LDA #PRGBank_A_B
	JSR ChangeMappedPRGBank
	JSR AreaSecondaryRoutine
	LDA #PRGBank_2_3
	JSR ChangeMappedPRGBank
	LDA POWQuakeTimer
	BEQ +
	JSR KillOnscreenEnemies
+
ENDIF

IFDEF CONTROLLER_2_DEBUG
	JSR AreaDebugRoutine
ENDIF

	JSR AnimateCHRRoutine

	JSR SetAreaStartPage

	; Decrement player state timers
	LDX #$03
DecrementPlayerStateTimers_Loop:
	LDA PlayerStateTimer, X
	BEQ DecrementPlayerStateTimers_Zero

	DEC PlayerStateTimer, X

DecrementPlayerStateTimers_Zero:
	DEX
	BPL DecrementPlayerStateTimers_Loop

IFDEF TRANSITION_INVULN
    LDA Player1JoypadPress
	AND #ControllerInput_Left | ControllerInput_Right
    BNE +
    LDA DamageInvulnTime
    BNE ++
    LDA AreaTransitioned_Invuln
    STA DamageInvulnTime
    LDA PlayerYVelocity
	BMI ++
    CMP #$10
    BCC ++
+   LDA #0
    STA AreaTransitioned_Invuln
++
ENDIF
	; If invincible, decrement timer every 8 frames
	LDY StarInvincibilityTimer
	BEQ RunFrame_Exit

	LDA byte_RAM_10
	AND #$07
	BNE RunFrame_Exit

	; When the invincibility timer hits 8, restore the regular level music
	DEC StarInvincibilityTimer
	CPY #$08
	BNE RunFrame_Exit

	LDY CurrentMusicIndex
	LDA LevelMusicIndexes, Y
	STA MusicQueue1

RunFrame_Exit:
	RTS


;
; Does a lot of important stuff in vertical levels
;
RunFrame_Vertical:
	JSR NextSpriteFlickerSlot

	JSR DetermineVerticalScroll

	; If the player is in a rocket, cut to the chase
	LDA PlayerInRocket
	BNE RunFrame_Vertical_Common

	; If the boss clear fanfare is playing or `PlayerLock` is set, skip the
	; player state update subroutine
	LDA MusicPlaying2
	CMP #Music2_BossClearFanfare
	BEQ RunFrame_Vertical_AfterPlayerState

IFDEF SCROLL_FIX
    LDA NeedsScroll
    BNE +
    LDA DoorAnimationTimer
    BNE +
    STA PlayerLock
    +
ENDIF

	LDA PlayerLock
	BNE RunFrame_Vertical_AfterPlayerState

	; Switch to banks 0/1 for the scrolling logic
	LDA #PRGBank_0_1
	JSR ChangeMappedPRGBank

	JSR HandlePlayerState

RunFrame_Vertical_AfterPlayerState:
	LDA #PRGBank_0_1
	JSR ChangeMappedPRGBank

	JSR ApplyVerticalScroll

	JSR SetPlayerScreenPosition

	JSR RenderPlayer

RunFrame_Vertical_Common:
	JMP RunFrame_Common


; =============== S U B R O U T I N E =======================================

sub_BANKF_F1AE:
	LDA DoAreaTransition
	CMP #$02
	BEQ locret_BANKF_F1E0

	LDY #$03

loc_BANKF_F1B7:
	LDA CurrentLevel, Y
	STA CurrentLevel_Init, Y
	DEY
	BPL loc_BANKF_F1B7

	LDA PlayerXLo
	STA PlayerXLo_Init
	LDA PlayerYLo
	STA PlayerYLo_Init
	LDA PlayerScreenX
	STA PlayerScreenX_Init
	LDA PlayerScreenYLo
	STA PlayerScreenYLo_Init
	LDA PlayerYVelocity
	STA PlayerYVelocity_Init
	LDA PlayerState
	STA PlayerState_Init

locret_BANKF_F1E0:
	RTS

; End of function sub_BANKF_F1AE

; =============== S U B R O U T I N E =======================================

;
; Level Initialization
; ====================
;
; Sets up in-level gameplay (eg. after level card)
;
LevelInitialization:
	LDY #$03

; Loop through and set level, area, page, and transition from RAM
LevelInitialization_AreaSetupLoop:
	LDA CurrentLevel_Init, Y
	STA CurrentLevel, Y
	DEY
	BPL LevelInitialization_AreaSetupLoop

	; position the player
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
	STA InSubspaceOrJar
	STA InJarType
	STA PlayerInAir
	STA DamageInvulnTime


RestorePlayerToFullHealth:
IFDEF HEALTH_REVAMP
    INC PlayerMaxHealth

	LDA PlayerHealth
    CMP #$FF
    BEQ +++
    LSR
    LSR
    LSR
    LSR
    CMP PlayerMaxHealth
    BCS +++
    LDA PlayerMaxHealth
    ASL
    ASL
    ASL
    ASL
    STA PlayerHealth
+++ DEC PlayerMaxHealth
	LDA PlayerHealth
    ORA #$F
	STA PlayerHealth
      RTS
ENDIF
IFNDEF HEALTH_REVAMP
      LDY     PlayerMaxHealth			  ; Get	player's current max HP
      LDA     PlayerHealthValueByHeartCount,Y	  ; Get	the health value for this amount of hearts
      STA     PlayerHealth
      RTS

PlayerHealthValueByHeartCount:
	.db PlayerHealth_2_HP
	.db PlayerHealth_3_HP
	.db PlayerHealth_4_HP
ENDIF
; Max hearts = (hearts - 2), value is 0,$01,2
; This table determines what the player's HP is set to

ClimbSpeed:
	.db $00
ClimbSpeedDown:
	.db $20
ClimbSpeedUp:
	.db $F0
; Bug: The climb speed index is determined by checking the up/down flags in
; Player1JoypadHeld. If both are enabled, the index it out of bounds and uses
; the LDA ($A5) below, which zips the player up the vine!
IFDEF FIX_CLIMB_ZIP
	.db $00
ENDIF

;
; Calculates the player's position onscreen.
;
; The screen position is also used for the jump-out-of-a-jar screen transition
; and bottomless pit checks, which works because of the assumption that the
; camera can always keep up with the player in normal gameplay.
;
SetPlayerScreenPosition:
	LDA PlayerXLo
	SEC
	SBC ScreenBoundaryLeftLo
	STA PlayerScreenX
	LDA PlayerYLo
	CLC
	SBC ScreenYLo
	STA PlayerScreenYLo
	LDA PlayerYHi
	SBC ScreenYHi
	STA PlayerScreenYHi

	; Exit if the player state is not standing/jumping or climbing
	LDA PlayerState
	CMP #PlayerState_Lifting
	BCS SetPlayerScreenPosition_Exit

	LDA PlayerScreenYHi
	BEQ SetPlayerScreenPosition_CheckClimbing

	BMI SetPlayerScreenPosition_Above

; If the player falls below the screen, they are in a bottomless pit.
SetPlayerScreenPosition_Below:
	LDA #$00
	STA PlayerStateTimer
IFDEF FALL_DEFENSE
    LDA #$80
    STA PlayerYVelocity
    LDA #SoundEffect1_EnemyHit
    STA SoundEffectQueue1
    LDA #PRGBank_2_3
    JSR ChangeMappedPRGBank
IFDEF DAMAGE_RESIST
    JSR DamagePlayerNoImmune
ELSE
	JSR DamagePlayer
ENDIF
    LDA #PRGBank_0_1
    JSR ChangeMappedPRGBank
    JMP SetPlayerScreenPosition_Above
+
ENDIF
	JMP KillPlayer

; If the player is above the screen, they might be jumping out of a jar.
SetPlayerScreenPosition_Above:
	; Verify that the y-position is above the first page of the area
	LDA PlayerYHi
	BPL SetPlayerScreenPosition_Exit

	; We're above the top of the area, so check if we're in a jar
	LDA InJarType
	BEQ SetPlayerScreenPosition_CheckClimbing

	; Check if the player is far enough above the top of the area
	LDA PlayerYLo
	CMP #$F0
	BCS SetPlayerScreenPosition_Exit

	; Exit the jar!
	JSR DoAreaReset

	; Break out of the previous subroutine
	PLA
	PLA

	; Put the player in a crouching stance
	LDY #$00
	STY PlayerDucking
	STY PlayerYVelocity
	STY PlayerXVelocity
	LDA #PlayerState_ExitingJar
	STA PlayerState
	LDA #SpriteAnimation_Ducking
	STA PlayerAnimationFrame
	LDA InJarType
	STY InJarType
IFNDEF DISABLED
	CMP #$02
	BNE SetPlayerScreenPosition_ExitSubAreaJar
ENDIF

SetPlayerScreenPosition_ExitPointerJar:
	STA DoAreaTransition
	RTS

SetPlayerScreenPosition_ExitSubAreaJar:
	STY InSubspaceOrJar
	LDA CurrentLevelAreaCopy
	STA CurrentLevelArea
	LDA #PRGBank_8_9
	JSR ChangeMappedPRGBank

	JMP CopyEnemyDataToMemory

SetPlayerScreenPosition_Exit:
	RTS

SetPlayerScreenPosition_CheckClimbing:
	LDA PlayerState
	CMP #PlayerState_Climbing
	BNE SetPlayerScreenPosition_Exit

	; No climbing transitions from subspace
	LDA InSubspaceOrJar
	CMP #$02
	BEQ SetPlayerScreenPosition_Exit

	; Climbing upwards
	LDA ClimbSpeedUp
	LDY PlayerYHi
	BMI SetPlayerScreenPosition_DoClimbingTransition

	; Climbing downwards
	LDA PlayerScreenYLo
	CMP #$B8
	BCC SetPlayerScreenPosition_Exit

	; Set y-position to an odd number
	LSR PlayerYLo
	SEC
	ROL PlayerYLo
	LDA ClimbSpeedDown

SetPlayerScreenPosition_DoClimbingTransition:
	STA PlayerYVelocity
	LDA #PlayerState_ClimbingAreaTransition
	STA PlayerState
	RTS


;
; Calculate the x-velocity of the camera based on the distance between the player
; and the center of the screen.
;
GetMoveCameraX:
	LDA #$00
	LDY ScrollXLock
	BNE GetMoveCameraX_Exit

	LDA PlayerXLo
	SEC
	SBC #$78
	SEC
	SBC ScreenBoundaryLeftLo

GetMoveCameraX_Exit:
	STA MoveCameraX
	RTS

IFDEF CUSTOM_PLAYER_RENDER

.include "src/extras/player/custom-player-render-all.asm"

ELSE

.include "src/systems/render-player.asm"

ENDIF



; =============== S U B R O U T I N E =======================================

SetAreaStartPage:
	LDA IsHorizontalLevel
	BNE SetAreaStartPage_HorizontalLevel

	LDY PlayerYHi
	LDA PlayerYLo
	JSR GetVerticalAreaStartPage

	TYA
	BPL SetAreaStartPage_SetAndExit
	LDA #$00
	BEQ SetAreaStartPage_SetAndExit

SetAreaStartPage_HorizontalLevel:
	LDA PlayerXHi

SetAreaStartPage_SetAndExit:
	STA CurrentLevelPage
	RTS

;
; Check if the player position requires vertical scrolling
;
DetermineVerticalScroll:
	; Exit if vertical scrolling is already happening
	LDX NeedsScroll
	BNE DetermineVerticalScroll_Exit

	; Exit if the player is doing any kind of transition
	LDA PlayerState
	CMP #PlayerState_Lifting
	BCS DetermineVerticalScroll_Exit

	; Use the player's position to detmine how to scroll
	LDA PlayerScreenYLo
	LDY PlayerScreenYHi
	BMI DetermineVerticalScroll_ScrollUpOnGround ; eg. `PlayerScreenYHi == $FF`
	BNE DetermineVerticalScroll_ScrollDown ; eg. `PlayerScreenYHi == $01`

	; Scroll down if player is near the bottom
	CMP #$B4
	BCS DetermineVerticalScroll_ScrollDown

	; Scroll up if the player is near the top
	CMP #$21
	BCS DetermineVerticalScroll_StartFromStationary

; Don't start scrolling for offscreen player until they're standing or climbing
DetermineVerticalScroll_ScrollUpOnGround:
	LDY PlayerInAir
	BNE DetermineVerticalScroll_StartFromStationary ; Player is in the air
	BEQ DetermineVerticalScroll_ScrollUp ; Player is NOT in the air

DetermineVerticalScroll_ScrollDown:
	; Set X = $02, scroll down
	INX

DetermineVerticalScroll_ScrollUp:
	; Set X = $01, scroll up
	INX

DetermineVerticalScroll_StartFromStationary:
	LDA VerticalScrollDirection
	STX VerticalScrollDirection
	BNE DetermineVerticalScroll_Exit

	; We weren't already vertically scrolling, but we need to start
	STX NeedsScroll

DetermineVerticalScroll_Exit:
	RTS


; Determines start page for vertical area
GetVerticalAreaStartPage:
	STA byte_RAM_F
	TYA
	BMI locret_BANKF_F4D9

	ASL A
	ASL A
	ASL A
	ASL A
	CLC
	ADC byte_RAM_F
	BCS loc_BANKF_F4D5

	CMP #$F0
	BCC locret_BANKF_F4D9

loc_BANKF_F4D5:
	CLC
	ADC #$10
	INY

locret_BANKF_F4D9:
	RTS

; End of function GetVerticalAreaStartPage


SpriteFlickerDMAOffset:
	.db $C0
	.db $70
	.db $80
	.db $50
	.db $A0
	.db $40
	.db $B0
	.db $60
	.db $90
	.db $C0
	.db $70
	.db $80
	.db $50
	.db $A0
	.db $40
	.db $B0
	.db $60

; Sprite display configuration
ObjectAttributeTable:
	.db ObjAttrib_Palette1 ; $00 Enemy_Heart
	.db ObjAttrib_Palette1 ; $01 Enemy_ShyguyRed
	.db ObjAttrib_Palette1 ; $02 Enemy_Tweeter
	.db ObjAttrib_Palette3 ; $03 Enemy_ShyguyPink
	.db ObjAttrib_Palette2 ; $04 Enemy_Porcupo
	.db ObjAttrib_Palette1 ; $05 Enemy_SnifitRed
	.db ObjAttrib_Palette2 ; $06 Enemy_SnifitGray
	.db ObjAttrib_Palette3 ; $07 Enemy_SnifitPink
	.db ObjAttrib_Palette1 | ObjAttrib_16x32 ; $08 Enemy_Ostro
	.db ObjAttrib_Palette1 ; $09 Enemy_BobOmb
	.db ObjAttrib_Palette1 | ObjAttrib_Horizontal | ObjAttrib_16x32 ; $0A Enemy_AlbatossCarryingBobOmb
	.db ObjAttrib_Palette1 | ObjAttrib_Horizontal | ObjAttrib_16x32 ; $0B Enemy_AlbatossStartRight
	.db ObjAttrib_Palette1 | ObjAttrib_Horizontal | ObjAttrib_16x32 ; $0C Enemy_AlbatossStartLeft
	.db ObjAttrib_Palette1 ; $0D Enemy_NinjiRunning
	.db ObjAttrib_Palette1 ; $0E Enemy_NinjiJumping
	.db ObjAttrib_Palette1 ; $0F Enemy_BeezoDiving
	.db ObjAttrib_Palette2 ; $10 Enemy_BeezoStraight
	.db ObjAttrib_Palette1 | ObjAttrib_Mirrored ; $11 Enemy_WartBubble
	.db ObjAttrib_Palette1 | ObjAttrib_Horizontal | ObjAttrib_FrontFacing ; $12 Enemy_Pidgit
	.db ObjAttrib_Palette1 | ObjAttrib_FrontFacing ; $13 Enemy_Trouter
	.db ObjAttrib_Palette1 | ObjAttrib_Mirrored ; $14 Enemy_Hoopstar
	.db ObjAttrib_Palette0 ; $15 Enemy_JarGeneratorShyguy
	.db ObjAttrib_Palette0 ; $16 Enemy_JarGeneratorBobOmb
	.db ObjAttrib_Palette1 | ObjAttrib_FrontFacing ; $17 Enemy_Phanto
	.db ObjAttrib_Palette1 | ObjAttrib_16x32 | ObjAttrib_UpsideDown ; $18 Enemy_CobratJar
	.db ObjAttrib_Palette1 | ObjAttrib_16x32 ; $19 Enemy_CobratSand
	.db ObjAttrib_Palette2 | ObjAttrib_FrontFacing ; $1A Enemy_Pokey
	.db ObjAttrib_Palette2 | ObjAttrib_FrontFacing ; $1B Enemy_Bullet
	.db ObjAttrib_Palette2 | ObjAttrib_16x32 ; $1C Enemy_Birdo
	.db ObjAttrib_Palette3 | ObjAttrib_16x32 ; $1D Enemy_Mouser
	.db ObjAttrib_Palette1 | ObjAttrib_FrontFacing ; $1E Enemy_Egg
	.db ObjAttrib_Palette2 | ObjAttrib_FrontFacing ; $1F Enemy_Tryclyde
	.db ObjAttrib_Palette1 | ObjAttrib_Mirrored ; $20 Enemy_Fireball
	.db ObjAttrib_Palette1 | ObjAttrib_16x32 ; $21 Enemy_Clawgrip
	.db ObjAttrib_Palette2 ; $22 Enemy_ClawgripRock
	.db ObjAttrib_Palette1 ; $23 Enemy_PanserStationaryFiresAngled
	.db ObjAttrib_Palette3 ; $24 Enemy_PanserWalking
	.db ObjAttrib_Palette2 ; $25 Enemy_PanserStationaryFiresUp
	.db ObjAttrib_Palette1 ; $26 Enemy_Autobomb
	.db ObjAttrib_Palette1 ; $27 Enemy_AutobombFire
	.db ObjAttrib_Palette1 | ObjAttrib_FrontFacing ; $28 Enemy_WhaleSpout
	.db ObjAttrib_Palette1 ; $29 Enemy_Flurry
	.db ObjAttrib_Palette1 | ObjAttrib_16x32 ; $2A Enemy_Fryguy
	.db ObjAttrib_Palette1 ; $2B Enemy_FryguySplit
	.db ObjAttrib_Palette3 | ObjAttrib_Horizontal | ObjAttrib_FrontFacing | ObjAttrib_16x32 ; $2C Enemy_Wart
	.db ObjAttrib_Palette1 | ObjAttrib_16x32 ; $2D Enemy_HawkmouthBoss
	.db ObjAttrib_Palette1 | ObjAttrib_Mirrored ; $2E Enemy_Spark1
	.db ObjAttrib_Palette1 | ObjAttrib_Mirrored ; $2F Enemy_Spark2
	.db ObjAttrib_Palette1 | ObjAttrib_Mirrored ; $30 Enemy_Spark3
	.db ObjAttrib_Palette1 | ObjAttrib_Mirrored ; $31 Enemy_Spark4
	.db ObjAttrib_Palette1 | ObjAttrib_Mirrored | ObjAttrib_UpsideDown ; $32 Enemy_VegetableSmall
	.db ObjAttrib_Palette1 | ObjAttrib_Mirrored | ObjAttrib_UpsideDown ; $33 Enemy_VegetableLarge
	.db ObjAttrib_Palette2 | ObjAttrib_Mirrored | ObjAttrib_UpsideDown ; $34 Enemy_VegetableWart
	.db ObjAttrib_Palette1 | ObjAttrib_Mirrored | ObjAttrib_UpsideDown ; $35 Enemy_Shell
	.db ObjAttrib_Palette1 | ObjAttrib_Mirrored | ObjAttrib_UpsideDown ; $36 Enemy_Coin
	.db ObjAttrib_Palette1 | ObjAttrib_UpsideDown ; $37 Enemy_Bomb
	.db ObjAttrib_Palette1 | ObjAttrib_UpsideDown ; $38 Enemy_Rocket
	.db ObjAttrib_Palette1 | ObjAttrib_FrontFacing ; $39 Enemy_MushroomBlock
	.db ObjAttrib_Palette1 | ObjAttrib_FrontFacing | ObjAttrib_UpsideDown ; $3A Enemy_POWBlock
	.db ObjAttrib_Palette1 | ObjAttrib_Horizontal | ObjAttrib_FrontFacing | ObjAttrib_16x32 ; $3B Enemy_FallingLogs
	.db ObjAttrib_Palette1 | ObjAttrib_FrontFacing ; $3C Enemy_SubspaceDoor
	.db ObjAttrib_Palette1 | ObjAttrib_FrontFacing ; $3D Enemy_Key
	.db ObjAttrib_Palette1 | ObjAttrib_FrontFacing | ObjAttrib_UpsideDown ; $3E Enemy_SubspacePotion
	.db ObjAttrib_Palette1 | ObjAttrib_Mirrored ; $3F Enemy_Mushroom
	.db ObjAttrib_Palette1 | ObjAttrib_FrontFacing | ObjAttrib_UpsideDown ; $40 Enemy_Mushroom1up
	.db ObjAttrib_Palette1 | ObjAttrib_Horizontal | ObjAttrib_16x32 ; $41 Enemy_FlyingCarpet
	.db ObjAttrib_Palette1 | ObjAttrib_16x32 ; $42 Enemy_HawkmouthRight
	.db ObjAttrib_Palette1 | ObjAttrib_16x32 ; $43 Enemy_HawkmouthLeft
	.db ObjAttrib_Palette1 | ObjAttrib_Mirrored ; $44 Enemy_CrystalBall
	.db ObjAttrib_Palette2 | ObjAttrib_Mirrored ; $45 Enemy_Starman
	.db ObjAttrib_Palette2 | ObjAttrib_Mirrored | ObjAttrib_UpsideDown ; $46 Enemy_Stopwatch

;
; Enemy Behavior 46E
;
;   bit 7 ($80) - uses mirrored sprite for animation
;   bit 6 ($40) - double speed
;   bit 5 ($20) - wider sprite? used for mouser
;   bit 4 ($10) - use tilemap 2
;   bit 3 ($08) - squawk on death (prevents despawning offscreen?)
;   bit 2 ($04) - disable collision with other enemies
;   bit 1 ($02) - unliftable
;   bit 0 ($01) - hurts when touched from above
EnemyArray_46E_Data:
	.db %00000100 ; $00 Enemy_Heart
	.db %00000000 ; $01 Enemy_ShyguyRed
	.db %00000000 ; $02 Enemy_Tweeter
	.db %00000000 ; $03 Enemy_ShyguyPink
	.db %00000011 ; $04 Enemy_Porcupo
	.db %00000000 ; $05 Enemy_SnifitRed
	.db %00000000 ; $06 Enemy_SnifitGray
	.db %00000000 ; $07 Enemy_SnifitPink
	.db %01010000 ; $08 Enemy_Ostro
	.db %01000000 ; $09 Enemy_BobOmb
	.db %01000010 ; $0A Enemy_AlbatossCarryingBobOmb
	.db %01000010 ; $0B Enemy_AlbatossStartRight
	.db %01000010 ; $0C Enemy_AlbatossStartLeft
	.db %01000000 ; $0D Enemy_NinjiRunning
	.db %01000000 ; $0E Enemy_NinjiJumping
	.db %01000000 ; $0F Enemy_BeezoDiving
	.db %01000000 ; $10 Enemy_BeezoStraight
	.db %00010011 ; $11 Enemy_WartBubble
	.db %11010000 ; $12 Enemy_Pidgit
	.db %10000000 ; $13 Enemy_Trouter
	.db %00000000 ; $14 Enemy_Hoopstar
	.db %00000110 ; $15 Enemy_JarGeneratorShyguy
	.db %00000110 ; $16 Enemy_JarGeneratorBobOmb
	.db %00000111 ; $17 Enemy_Phanto
	.db %00010000 ; $18 Enemy_CobratJar
	.db %01010000 ; $19 Enemy_CobratSand
	.db %10010000 ; $1A Enemy_Pokey
	.db %00000111 ; $1B Enemy_Bullet
	.db %00001010 ; $1C Enemy_Birdo
	.db %00111011 ; $1D Enemy_Mouser
	.db %01000000 ; $1E Enemy_Egg
	.db %00011000 ; $1F Enemy_Tryclyde
	.db %00000111 ; $20 Enemy_Fireball
	.db %00011011 ; $21 Enemy_Clawgrip
	.db %00010000 ; $22 Enemy_ClawgripRock
	.db %00000111 ; $23 Enemy_PanserStationaryFiresAngled
	.db %00000111 ; $24 Enemy_PanserWalking
	.db %00000111 ; $25 Enemy_PanserStationaryFiresUp
	.db %01010000 ; $26 Enemy_Autobomb
	.db %01010011 ; $27 Enemy_AutobombFire
	.db %10010110 ; $28 Enemy_WhaleSpout
	.db %01010000 ; $29 Enemy_Flurry
	.db %10011011 ; $2A Enemy_Fryguy
	.db %11010011 ; $2B Enemy_FryguySplit
	.db %00011011 ; $2C Enemy_Wart
	.db %00001011 ; $2D Enemy_HawkmouthBoss
	.db %00000011 ; $2E Enemy_Spark1
	.db %00000011 ; $2F Enemy_Spark2
	.db %00000011 ; $30 Enemy_Spark3
	.db %00000011 ; $31 Enemy_Spark4
	.db %00000000 ; $32 Enemy_VegetableSmall
	.db %00000000 ; $33 Enemy_VegetableLarge
	.db %00000000 ; $34 Enemy_VegetableWart
	.db %00000000 ; $35 Enemy_Shell
	.db %00000100 ; $36 Enemy_Coin
	.db %00000100 ; $37 Enemy_Bomb
	.db %00000100 ; $38 Enemy_Rocket
	.db %00000000 ; $39 Enemy_MushroomBlock
	.db %00000000 ; $3A Enemy_POWBlock
	.db %00000110 ; $3B Enemy_FallingLogs
	.db %00000100 ; $3C Enemy_SubspaceDoor
	.db %00000000 ; $3D Enemy_Key
	.db %00000100 ; $3E Enemy_SubspacePotion
	.db %00000100 ; $3F Enemy_Mushroom
	.db %00000100 ; $40 Enemy_Mushroom1up
	.db %00010110 ; $41 Enemy_FlyingCarpet
	.db %00000110 ; $42 Enemy_HawkmouthRight
	.db %00000110 ; $43 Enemy_HawkmouthLeft
	.db %00001100 ; $44 Enemy_CrystalBall
	.db %00000100 ; $45 Enemy_Starman
	.db %00000100 ; $46 Enemy_Stopwatch

;
; Index for tile collision bounding box table
;
EnemyArray_492_Data:
	.db $00 ; $00 Enemy_Heart
	.db $05 ; $01 Enemy_ShyguyRed
	.db $05 ; $02 Enemy_Tweeter
	.db $05 ; $03 Enemy_ShyguyPink
	.db $05 ; $04 Enemy_Porcupo
	.db $05 ; $05 Enemy_SnifitRed
	.db $05 ; $06 Enemy_SnifitGray
	.db $05 ; $07 Enemy_SnifitPink
	.db $0C ; $08 Enemy_Ostro
	.db $05 ; $09 Enemy_BobOmb
	.db $05 ; $0A Enemy_AlbatossCarryingBobOmb
	.db $05 ; $0B Enemy_AlbatossStartRight
	.db $05 ; $0C Enemy_AlbatossStartLeft
	.db $05 ; $0D Enemy_NinjiRunning
	.db $05 ; $0E Enemy_NinjiJumping
	.db $05 ; $0F Enemy_BeezoDiving
	.db $05 ; $10 Enemy_BeezoStraight
	.db $05 ; $11 Enemy_WartBubble
	.db $05 ; $12 Enemy_Pidgit
	.db $05 ; $13 Enemy_Trouter
	.db $05 ; $14 Enemy_Hoopstar
	.db $0D ; $15 Enemy_JarGeneratorShyguy
	.db $0D ; $16 Enemy_JarGeneratorBobOmb
	.db $05 ; $17 Enemy_Phanto
	.db $0C ; $18 Enemy_CobratJar
	.db $0C ; $19 Enemy_CobratSand
	.db $05 ; $1A Enemy_Pokey
	.db $0D ; $1B Enemy_Bullet
	.db $0C ; $1C Enemy_Birdo
	.db $0C ; $1D Enemy_Mouser
	.db $05 ; $1E Enemy_Egg
	.db $0E ; $1F Enemy_Tryclyde
	.db $0D ; $20 Enemy_Fireball
	.db $0C ; $21 Enemy_Clawgrip
	.db $05 ; $22 Enemy_ClawgripRock
	.db $05 ; $23 Enemy_PanserStationaryFiresAngled
	.db $05 ; $24 Enemy_PanserWalking
	.db $05 ; $25 Enemy_PanserStationaryFiresUp
	.db $0C ; $26 Enemy_Autobomb
	.db $05 ; $27 Enemy_AutobombFire
	.db $05 ; $28 Enemy_WhaleSpout
	.db $05 ; $29 Enemy_Flurry
	.db $05 ; $2A Enemy_Fryguy
	.db $05 ; $2B Enemy_FryguySplit
	.db $05 ; $2C Enemy_Wart
	.db $00 ; $2D Enemy_HawkmouthBoss
	.db $0F ; $2E Enemy_Spark1
	.db $0F ; $2F Enemy_Spark2
	.db $0F ; $30 Enemy_Spark3
	.db $0F ; $31 Enemy_Spark4
	.db $05 ; $32 Enemy_VegetableSmall
	.db $05 ; $33 Enemy_VegetableLarge
	.db $05 ; $34 Enemy_VegetableWart
	.db $05 ; $35 Enemy_Shell
	.db $05 ; $36 Enemy_Coin
	.db $05 ; $37 Enemy_Bomb
	.db $05 ; $38 Enemy_Rocket
	.db $04 ; $39 Enemy_MushroomBlock
	.db $04 ; $3A Enemy_POWBlock
	.db $04 ; $3B Enemy_FallingLogs
	.db $04 ; $3C Enemy_SubspaceDoor
	.db $04 ; $3D Enemy_Key
	.db $04 ; $3E Enemy_SubspacePotion
	.db $04 ; $3F Enemy_Mushroom
	.db $04 ; $40 Enemy_Mushroom1up
	.db $10 ; $41 Enemy_FlyingCarpet
	.db $00 ; $42 Enemy_HawkmouthRight
	.db $00 ; $43 Enemy_HawkmouthLeft
	.db $05 ; $44 Enemy_CrystalBall
	.db $05 ; $45 Enemy_Starman
	.db $05 ; $46 Enemy_Stopwatch

;
; Index for object collision bounding box table
;
EnemyArray_489_Data:
	.db $08 ; $00 Enemy_Heart
	.db $02 ; $01 Enemy_ShyguyRed
	.db $02 ; $02 Enemy_Tweeter
	.db $02 ; $03 Enemy_ShyguyPink
	.db $02 ; $04 Enemy_Porcupo
	.db $02 ; $05 Enemy_SnifitRed
	.db $02 ; $06 Enemy_SnifitGray
	.db $02 ; $07 Enemy_SnifitPink
	.db $04 ; $08 Enemy_Ostro
	.db $02 ; $09 Enemy_BobOmb
	.db $09 ; $0A Enemy_AlbatossCarryingBobOmb
	.db $09 ; $0B Enemy_AlbatossStartRight
	.db $09 ; $0C Enemy_AlbatossStartLeft
	.db $02 ; $0D Enemy_NinjiRunning
	.db $02 ; $0E Enemy_NinjiJumping
	.db $02 ; $0F Enemy_BeezoDiving
	.db $02 ; $10 Enemy_BeezoStraight
	.db $02 ; $11 Enemy_WartBubble
	.db $02 ; $12 Enemy_Pidgit
	.db $02 ; $13 Enemy_Trouter
	.db $02 ; $14 Enemy_Hoopstar
	.db $08 ; $15 Enemy_JarGeneratorShyguy
	.db $08 ; $16 Enemy_JarGeneratorBobOmb
	.db $02 ; $17 Enemy_Phanto
	.db $04 ; $18 Enemy_CobratJar
	.db $04 ; $19 Enemy_CobratSand
	.db $0E ; $1A Enemy_Pokey
	.db $08 ; $1B Enemy_Bullet
	.db $04 ; $1C Enemy_Birdo
	.db $04 ; $1D Enemy_Mouser
	.db $02 ; $1E Enemy_Egg
	.db $0F ; $1F Enemy_Tryclyde
	.db $02 ; $20 Enemy_Fireball
	.db $13 ; $21 Enemy_Clawgrip
	.db $02 ; $22 Enemy_ClawgripRock
	.db $02 ; $23 Enemy_PanserStationaryFiresAngled
	.db $02 ; $24 Enemy_PanserWalking
	.db $02 ; $25 Enemy_PanserStationaryFiresUp
	.db $10 ; $26 Enemy_Autobomb
	.db $02 ; $27 Enemy_AutobombFire
	.db $12 ; $28 Enemy_WhaleSpout
	.db $02 ; $29 Enemy_Flurry
	.db $0F ; $2A Enemy_Fryguy
	.db $02 ; $2B Enemy_FryguySplit
	.db $11 ; $2C Enemy_Wart
	.db $0B ; $2D Enemy_HawkmouthBoss
	.db $02 ; $2E Enemy_Spark1
	.db $02 ; $2F Enemy_Spark2
	.db $02 ; $30 Enemy_Spark3
	.db $02 ; $31 Enemy_Spark4
	.db $02 ; $32 Enemy_VegetableSmall
	.db $02 ; $33 Enemy_VegetableLarge
	.db $02 ; $34 Enemy_VegetableWart
	.db $02 ; $35 Enemy_Shell
	.db $02 ; $36 Enemy_Coin
	.db $02 ; $37 Enemy_Bomb
	.db $04 ; $38 Enemy_Rocket
	.db $03 ; $39 Enemy_MushroomBlock
	.db $03 ; $3A Enemy_POWBlock
	.db $07 ; $3B Enemy_FallingLogs
	.db $04 ; $3C Enemy_SubspaceDoor
	.db $03 ; $3D Enemy_Key
	.db $03 ; $3E Enemy_SubspacePotion
	.db $03 ; $3F Enemy_Mushroom
	.db $03 ; $40 Enemy_Mushroom1up
	.db $09 ; $41 Enemy_FlyingCarpet
	.db $0B ; $42 Enemy_HawkmouthRight
	.db $0B ; $43 Enemy_HawkmouthLeft
	.db $02 ; $44 Enemy_CrystalBall
	.db $02 ; $45 Enemy_Starman
	.db $02 ; $46 Enemy_Stopwatch

; More collision (post-throw)
byte_BANKF_F607:
	.db $00 ; $00 Enemy_Heart
	.db $00 ; $01 Enemy_ShyguyRed
	.db $00 ; $02 Enemy_Tweeter
	.db $00 ; $03 Enemy_ShyguyPink
	.db $00 ; $04 Enemy_Porcupo
	.db $00 ; $05 Enemy_SnifitRed
	.db $00 ; $06 Enemy_SnifitGray
	.db $00 ; $07 Enemy_SnifitPink
	.db $00 ; $08 Enemy_Ostro
	.db $00 ; $09 Enemy_BobOmb
	.db $00 ; $0A Enemy_AlbatossCarryingBobOmb
	.db $00 ; $0B Enemy_AlbatossStartRight
	.db $00 ; $0C Enemy_AlbatossStartLeft
	.db $00 ; $0D Enemy_NinjiRunning
	.db $00 ; $0E Enemy_NinjiJumping
	.db $00 ; $0F Enemy_BeezoDiving
	.db $00 ; $10 Enemy_BeezoStraight
	.db $00 ; $11 Enemy_WartBubble
	.db $00 ; $12 Enemy_Pidgit
	.db $00 ; $13 Enemy_Trouter
	.db $00 ; $14 Enemy_Hoopstar
	.db $00 ; $15 Enemy_JarGeneratorShyguy
	.db $00 ; $16 Enemy_JarGeneratorBobOmb
	.db $00 ; $17 Enemy_Phanto
	.db $00 ; $18 Enemy_CobratJar
	.db $00 ; $19 Enemy_CobratSand
	.db $00 ; $1A Enemy_Pokey
	.db $00 ; $1B Enemy_Bullet
	.db $00 ; $1C Enemy_Birdo
	.db $00 ; $1D Enemy_Mouser
	.db $00 ; $1E Enemy_Egg
	.db $00 ; $1F Enemy_Tryclyde
	.db $00 ; $20 Enemy_Fireball
	.db $00 ; $21 Enemy_Clawgrip
	.db $00 ; $22 Enemy_ClawgripRock
	.db $00 ; $23 Enemy_PanserStationaryFiresAngled
	.db $00 ; $24 Enemy_PanserWalking
	.db $00 ; $25 Enemy_PanserStationaryFiresUp
	.db $00 ; $26 Enemy_Autobomb
	.db $00 ; $27 Enemy_AutobombFire
	.db $00 ; $28 Enemy_WhaleSpout
	.db $00 ; $29 Enemy_Flurry
	.db $00 ; $2A Enemy_Fryguy
	.db $00 ; $2B Enemy_FryguySplit
	.db $00 ; $2C Enemy_Wart
	.db $00 ; $2D Enemy_HawkmouthBoss
	.db $00 ; $2E Enemy_Spark1
	.db $00 ; $2F Enemy_Spark2
	.db $00 ; $30 Enemy_Spark3
	.db $00 ; $31 Enemy_Spark4
	.db $01 ; $32 Enemy_VegetableSmall
	.db $01 ; $33 Enemy_VegetableLarge
	.db $01 ; $34 Enemy_VegetableWart
IFDEF SHELL_FIX
	.db $00 ; $35 Enemy_Shell
ELSE
	.db $01 ; $35 Enemy_Shell
ENDIF
	.db $02 ; $36 Enemy_Coin
	.db $01 ; $37 Enemy_Bomb
	.db $00 ; $38 Enemy_Rocket
	.db $02 ; $39 Enemy_MushroomBlock
	.db $03 ; $3A Enemy_POWBlock
	.db $02 ; $3B Enemy_FallingLogs
	.db $04 ; $3C Enemy_SubspaceDoor
	.db $02 ; $3D Enemy_Key
	.db $02 ; $3E Enemy_SubspacePotion
	.db $02 ; $3F Enemy_Mushroom
	.db $02 ; $40 Enemy_Mushroom1up
	.db $02 ; $41 Enemy_FlyingCarpet
	.db $02 ; $42 Enemy_HawkmouthRight
	.db $02 ; $43 Enemy_HawkmouthLeft
	.db $02 ; $44 Enemy_CrystalBall
	.db $00 ; $45 Enemy_Starman
	.db $02 ; $46 Enemy_Stopwatch

; @TODO: use flag
; IFNDEF ENABLE_TILE_ATTRIBUTES_TABLE
;
; This table determines the "solidness" of tiles.
;
; Solidness is broken into four tiers:
;   - background (no collisions)
;   - background to player/enemies, solid to mushroom blocks
;   - jumpthrough block (collision on top only)
;   - solid block (collision on all sides)
;
; Tiles are divided into groups of $40. For each category, the corresponding
; the groups are divided into two groups: tiles that have a collision rule and
; tiles that don't.
;
TileSolidnessTable:
	; solid to mushroom blocks unless < these values
	.db $01
	.db $43
	.db $80
	.db $C0
	; solid on top unless < these values
	.db $12
	.db $60
	.db $91
	.db $CA
	; solid on all sides unless < these values
	.db $18
	.db $69
	.db $98
	.db $D5

IFDEF CUSTOM_TILE_IDS
CheckCustomSolidness:
	SEC
	SBC #$D8
	TAX
	LDA CustomSolid, X
	STA DrawTileId
	RTS
ENDIF

IFDEF ENABLE_TILE_ATTRIBUTES_TABLE
	.include "src/extras/level_gen/tile-attribute-table.asm"
ENDIF
;
; ### Warp destination lookup table
;
; The row is the (0-indexed) world that you're on, the value is the destination.
;
WarpDestinations:
	.db $03
	.db $01
	.db $04
	.db $05
	.db $06
	.db $05
	.db $06


;
; Updates joypad press/held values
;
UpdateJoypads:
	JSR ReadJoypads

UpdateJoypads_DoubleCheck:
	; Work around DPCM sample bug,
	; where some spurious inputs are read
IFDEF CONTROLLER_2_DEBUG
	LDY Player2JoypadPress
	STY UpdateJoypadsTemp
ENDIF
	LDY Player1JoypadPress
	JSR ReadJoypads

	CPY Player1JoypadPress
	BNE UpdateJoypads_DoubleCheck

IFDEF CONTROLLER_2_DEBUG
	LDY UpdateJoypadsTemp
	CPY Player2JoypadPress
	BNE UpdateJoypads_DoubleCheck
ENDIF

	LDX #$01

UpdateJoypads_Loop:
	LDA Player1JoypadPress, X ; Update the press/held values
	TAY
	EOR Player1JoypadHeld, X
	AND Player1JoypadPress, X
	STA Player1JoypadPress, X
	STY Player1JoypadHeld, X
	DEX
	BPL UpdateJoypads_Loop

	RTS


;
; Reads joypad pressed input
;
ReadJoypads:
	LDX #$01
	STX JOY1
	DEX
	STX JOY1

	LDX #$08
ReadJoypadLoop:
	LDA JOY1
	LSR A
	ROL Player1JoypadPress
	LSR A
	; @TODO These seem to never be read, and even then are using a
	; second bit from JOY1/JOY2 ... Was this reading from
	; the expansion port???
	ROL Player1JoypadUnk
	LDA JOY2
	LSR A
	ROL Player2JoypadPress
	LSR A
	ROL Player2JoypadUnk
	DEX
	BNE ReadJoypadLoop

	RTS

IFDEF HEALTH_REVAMP
	.include "src/extras/ui/health-revamp-3.asm"
ENDIF
;
; Load the area specified by the area pointer at the current page
;
FollowCurrentAreaPointer:
sub_BANKF_F6A1:
IFDEF CUSTOM_LEVEL_RLE
	LDA InJarType
	BEQ +
	CMP #1
	BNE +
	INC InJarType
	LDA #PRGBank_8_9
	JSR ChangeMappedPRGBankWithoutSaving
	LDA CurrentLevel
	STA AreaPointersByPage
	LDA CurrentLevelArea
	ASL
	ASL
	ASL
	ASL
	CLC
	ADC CurrentLevelPage
	STA AreaPointersByPage + 1

	LDY CurrentLevel
	LDA LevelAreaStartIndexes, Y
	CLC
	LDA #AreaIndex_Jar
	STA CurrentLevelArea
	LDA #$0
	STA CurrentLevelEntryPage
	LDA MMC3PRGBankTemp
	JMP ChangeMappedPRGBank
+
ENDIF
	LDA CurrentLevelPage
	ASL A
	TAY
	LDA AreaPointersByPage, Y
	STA CurrentLevel
	INY
	LDA AreaPointersByPage, Y
	LSR A
	LSR A
	LSR A
	LSR A
	STA CurrentLevelArea
	LDA AreaPointersByPage, Y
	AND #$0F
	STA CurrentLevelEntryPage
	RTS



;
; Checks that we're playing the correct music and switches if necessary, unless
; we're playing the invincibility music.
;
; ##### Input
; - `CompareMusicIndex`: music we should be playing
; - `CurrentMusicIndex`: music we're actually playing
; - `StarInvincibilityTimer`: whether the player is invincible
;
; ##### Output
; - `CurrentMusicIndex`: music we should be plathing
; - `MusicQueue1`: song to play if we need to change the music
;
EnsureCorrectMusic:
	LDA CompareMusicIndex
	CMP CurrentMusicIndex
	BEQ EnsureCorrectMusic_Exit

	TAX
	STX CurrentMusicIndex
	LDA StarInvincibilityTimer
	CMP #$08
	BCS EnsureCorrectMusic_Exit

	LDA LevelMusicIndexes, X
	STA MusicQueue1

EnsureCorrectMusic_Exit:
	RTS


DoAreaReset:
	LDA #$00
	STA AreaInitialized
	STA ObjectCarriedOver
	STA SubspaceTimer
	STA SubspaceDoorTimer
IFDEF CUSTOM_MUSH
	JSR LoadWorldCHRBanks
ENDIF
IFDEF CONTROLLER_2_DEBUG
	STA ChangeCharacterPoofTimer
ENDIF
	LDX #$08

DoAreaReset_EnemyLoop:
	LDA EnemyState, X
	BEQ DoAreaReset_EnemyLoopEnd

	LDA ObjectBeingCarriedTimer, X
	BEQ DoAreaReset_AfterCarryOver

	LDA ObjectType, X
	CMP #Enemy_MushroomBlock
	BEQ DoAreaReset_AfterCarryOver

	STA ObjectCarriedOver

DoAreaReset_AfterCarryOver:
	JSR AreaResetEnemyDestroy

DoAreaReset_EnemyLoopEnd:
	DEX
	BPL DoAreaReset_EnemyLoop

	LDX byte_RAM_12
	RTS

; End of function DoAreaReset

; =============== S U B R O U T I N E =======================================

AreaResetEnemyDestroy:
	; load raw enemy data offset so we can allow the level object to respawn
	LDY EnemyRawDataOffset, X
	; nothing to reset if offset is invalid
	BMI AreaResetEnemyDestroy_AfterAllowRespawn

	; disabling bit 7 allows the object to respawn
	LDA (RawEnemyData), Y
	AND #$7F
	STA (RawEnemyData), Y

AreaResetEnemyDestroy_AfterAllowRespawn:
	LDA #EnemyState_Inactive
	STA EnemyState, X
	RTS

; End of function AreaResetEnemyDestroy

; =============== S U B R O U T I N E =======================================

KillPlayer:
	LDA #PlayerState_Dying ; Mark player as dead
	STA PlayerState
	LDA #$00 ; Clear some variables
	STA PlayerHealth
	STA CrouchJumpTimer
	STA StarInvincibilityTimer
	LDA #SpriteAnimation_Dead ; Set player animation to dead?
	STA PlayerAnimationFrame
	LDA HoldingItem
	BEQ loc_BANKF_F749

	; Probably something to throw away
	; a held item on death
	DEC HoldingItem
	LDY ObjectBeingCarriedIndex
	STA EnemyArray_42F, Y
	LSR A
	STA ObjectBeingCarriedTimer, Y
	STA ObjectXVelocity, Y
	LDA #$E0
	STX byte_RAM_D
	LDX EnemyState, Y
	CPX #EnemyState_Sinking
	BEQ loc_BANKF_F747

	STA ObjectYVelocity, Y

loc_BANKF_F747:
	LDX byte_RAM_D

loc_BANKF_F749:
	; Set music to death jingle
	LDA #Music2_DeathJingle
	STA MusicQueue2
	; BUG: Setting DPCM at the same time as music
	LDA #DPCM_PlayerDeath
	STA DPCMQueue
	RTS


;
; Copies the raw level data to memory.
;
IFDEF CUSTOM_LEVEL_RLE
LoadLevelIntoMemoly_NoBank:
	; Determine the global area index from the current level and area.
	LDY CurrentLevel
	LDA LevelAreaStartIndexes, Y
	CLC
	ADC CurrentLevelArea
	TAY
IFDEF RANDOMIZER_FLAGS
    STA CurrentLevelAreaIndex
ENDIF

	; Calculate the pointer for the start of the level data.
	LDA LevelDataPointersHi, Y
	STA byte_RAM_8
	LDA LevelDataPointersLo, Y
	STA byte_RAM_7
	LDA LevelDataBank, Y
	STA byte_RAM_9
	RTS
LoadLevelDataPtrIntoMemoly:
	LDA #PRGBank_8_9
	JSR ChangeMappedPRGBank
	JSR LoadLevelIntoMemoly_NoBank
	LDA #PRGBank_6_7
	JSR ChangeMappedPRGBank
	RTS

CopyLevelDataMemory_Switch:
	LDA byte_RAM_9
	JSR ChangeMappedPRGBank
	; Blindly copy 255 bytes of data, which is presumed to contain the full area.
	LDY #$2
	LDX #$FD
	-
	LDA (byte_RAM_7), Y
	STA (byte_RAM_5), Y
	INY
	DEX
	BNE -
	LDA #PRGBank_6_7
	JSR ChangeMappedPRGBank
	RTS
ENDIF
CopyLevelDataToMemory:
	; Determine the global area index from the current level and area.
	LDY CurrentLevel
	LDA LevelAreaStartIndexes, Y
	CLC
	ADC CurrentLevelArea
	TAY
IFDEF RANDOMIZER_FLAGS
    STA CurrentLevelAreaIndex
ENDIF

	; Calculate the pointer for the start of the level data.
	LDA LevelDataPointersLo, Y
	STA byte_RAM_5
	LDA LevelDataPointersHi, Y
	STA byte_RAM_6
IFDEF CUSTOM_LEVEL_RLE
	LDA LevelDataBank, Y
	JSR ChangeMappedPRGBank
ENDIF

	; Blindly copy 255 bytes of data, which is presumed to contain the full area.
	LDX #$FF

	; Set the destination address in RAM for copying level data.
	LDA #>RawLevelData
	STA byte_RAM_2
	LDY #<RawLevelData
	STY byte_RAM_1

	; `Y = $00`
CopyLevelDataToMemory_Loop:
	LDA (byte_RAM_5), Y
	STA (byte_RAM_1), Y
	INY
	DEX
	BNE CopyLevelDataToMemory_Loop

	; We end up copying the first byte twice!
	STA (byte_RAM_1), Y


;
; Copies the raw enemy data to memory.
;
CopyEnemyDataToMemory:
IFDEF CUSTOM_LEVEL_RLE
	LDA #PRGBank_8_9
	JSR ChangeMappedPRGBank
ENDIF
	; Determine the address of the level's enemy pointer tables.
	LDY CurrentLevel
	LDA EnemyPointersByLevel_HiHi, Y
	STA byte_RAM_1
	LDA EnemyPointersByLevel_HiLo, Y
	STA byte_RAM_0
	LDA EnemyPointersByLevel_LoHi, Y
	STA byte_RAM_3
	LDA EnemyPointersByLevel_LoLo, Y
	STA byte_RAM_2

	; Determine whether we want the enemy data for the area or for the jar.
	LDA InSubspaceOrJar
	CMP #$01
	BNE CopyEnemyDataToMemory_Area

CopyEnemyDataToMemory_Jar:
	LDY #AreaIndex_Jar
	JMP CopyEnemyDataToMemory_SetAddress

CopyEnemyDataToMemory_Area:
	LDY CurrentLevelArea

CopyEnemyDataToMemory_SetAddress:
	; Calculate the pointer for the start of the enemy data.
	LDA (byte_RAM_0), Y
	STA byte_RAM_1
	LDA (byte_RAM_2), Y
	STA byte_RAM_0

	; Blindly copy 255 bytes of data, which is presumed to contain the full area.
	LDX #$FF

	; Set the destination address in RAM for copying level data.
	LDA #>RawEnemyDataAddr
	STA byte_RAM_3
	LDY #<RawEnemyDataAddr
	STY byte_RAM_2

	; `Y = $00`
CopyEnemyDataToMemory_Loop:
	LDA (byte_RAM_0), Y
	STA (byte_RAM_2), Y
	INY
	DEX
	BNE CopyEnemyDataToMemory_Loop

	RTS


;
; Copies the raw level data for a jar to memory.
;
CopyJarDataToMemory:
	; Determine the global area index from the current level and area.
	LDY CurrentLevel
	LDA LevelAreaStartIndexes, Y
	CLC
	ADC #AreaIndex_Jar
	TAY
IFDEF RANDOMIZER_FLAGS
    STA CurrentLevelAreaIndex
ENDIF
	; Calculate the pointer for the start of the level data.
	LDA LevelDataPointersLo, Y
	STA byte_RAM_5
	LDA LevelDataPointersHi, Y
	STA byte_RAM_6

	; Set the destination address in RAM for copying level data.
	LDA #>RawJarData
	STA byte_RAM_2
	LDY #<RawJarData
	STY byte_RAM_1
IFDEF CUSTOM_LEVEL_RLE
	LDA LevelDataBank, Y
	JSR ChangeMappedPRGBank
ENDIF


	; `Y = $00`
CopyJarDataToMemory_Loop:
	LDA (byte_RAM_5), Y
	; Unlike `CopyLevelDataToMemory`, which always copies 255 bytes, this stops on any `$FF` read!
	;
	; This isn't technically "correct", but in practice it's not the most devastating limitation.
	; Just don't expect to use a waterfall object that is exactly 16 tiles wide inside a jar.
	;
	; Fun fact: The largest possible waterfall objects are only used in two areas of World 5!
	CMP #$FF ; This one actually terminates on any $FF read! Welp.
	BEQ CopyJarDataToMemory_Exit

	STA (byte_RAM_1), Y
	INY
	JMP CopyJarDataToMemory_Loop

CopyJarDataToMemory_Exit:
	STA (byte_RAM_1), Y
	RTS


IFNDEF MIGRATE_QUADS
.include "src/systems/tile_quads.asm"
ENDIF

EndOfLevelDoor: ; PPU data
	.db $22,$D0,$04,$FC,$FC,$AD,$FA
	.db $22,$F0,$04,$FC,$FC,$AC,$AD
	.db $23,$10,$06,$FC,$FC,$AC,$AC,$AD,$FA
	.db $23,$30,$06,$FC,$FC,$AC,$AC,$AC,$AD
	.db $00

EndOfLevelDoorRowOffsets:
	.db $00
	.db $07
	.db $0E
	.db $17

DefaultCHRAnimationSpeed_Level:
	.db $00 ; 1-1
	.db $00 ; 1-1
	.db $06 ; 3-1
	.db $06 ; 3-1
	.db $0A ; 4-2
	.db $0A ; 4-2
	.db $0B ; 4-3
	.db $0D ; 5-2
	.db $0E ; 5-3
	.db $11 ; 6-3
	.db $11 ; 6-3
	.db $12 ; 7-1
	.db $12 ; 7-1
	.db $12 ; 7-1
	.db $12 ; 7-1
	.db $13 ; 7-2

DefaultCHRAnimationSpeed_Area:
	.db $01 ; 1-1 upward climb
	.db $05 ; 1-1 birdo
	.db $01 ; 3-1 main part
	.db $03 ; 3-1 sky part
	.db $01 ; 4-2 sky ice
	.db $02 ; 4-2 whales
	.db $04 ; 4-3 tower tops
	.db $02 ; 5-2 upward climb
	.db $04 ; 5-3 miniboss birdo
	.db $03 ; 6-3 upward climb
	.db $04 ; 6-3 sky pyramid
	.db $00 ; 7-1 beginning area
	.db $01 ; 7-1 albatoss area
	.db $02 ; 7-1 cloud maze
	.db $03 ; 7-1 upward climb
	.db $00 ; 7-2 entrance

BackgroundCHRAnimationSpeedByWorld:
	.db $07 ; World 1
	.db $07 ; World 2
	.db $07 ; World 3
	.db $07 ; World 4
	.db $09 ; World 5
	.db $07 ; World 6
	.db $05 ; World 7
	.db $0B ; Default


;
; Increments the frame of the CHR animation using the world/area speed
;
AnimateCHRRoutine:
	DEC BackgroundCHR2Timer
	BPL AnimateCHRRoutine_Exit

	LDX #$07 ; default index for animation speed table

	; Certain level/area combinations use a fixed animation speed.
	; It seems to be used in areas that prominently feature cloud platforms.
	; This loop performs the lookup to see if that should happen.
	LDY #(DefaultCHRAnimationSpeed_Area - DefaultCHRAnimationSpeed_Level - 1)
AnimateCHRRoutine_DefaultSpeedLoop:
	LDA CurrentLevel_Init
	CMP DefaultCHRAnimationSpeed_Level, Y
	BNE AnimateCHRRoutine_DefaultSpeedNext

	LDA CurrentLevelArea_Init
	CMP DefaultCHRAnimationSpeed_Area, Y
	BEQ AnimateCHRRoutine_SetSpeed

AnimateCHRRoutine_DefaultSpeedNext:
	DEY
	BPL AnimateCHRRoutine_DefaultSpeedLoop

	LDX CurrentWorldTileset

AnimateCHRRoutine_SetSpeed:
	LDA BackgroundCHRAnimationSpeedByWorld, X
	STA BackgroundCHR2Timer
	LDY BackgroundCHR2
	INY
	INY

AnimatedCHRCheck:
IFDEF FIX_CHR_CYCLE
	CPY #CHRBank_Animated8 + 1
ELSE
	; Bug: This is in the original game
	; The last frame of the animation is effectively skipped because
	; we immediately reset to the first frame when we hit it.
	CPY #CHRBank_Animated8
ENDIF

	BCC AnimateCHRRoutine_SetCHR

	LDY #CHRBank_Animated1

AnimateCHRRoutine_SetCHR:
	STY BackgroundCHR2

AnimateCHRRoutine_Exit:
	RTS


;
; Looks for an unused sprite slot
;
; ##### Input
; - `X`: enemy slot
;
; ##### Output
; - `X`: byte_RAM_12
; - `Y`: sprite slot
;
FindSpriteSlot:
	LDX #$08

FindSpriteSlot_Loop:
	LDA EnemyState, X
	BEQ FindSpriteSlot_CheckInactiveSlot

FindSpriteSlot_LoopNext:
	DEX
	BPL FindSpriteSlot_Loop

FindSpriteSlot_Default:
	; Check that both halves of the default sprite slot are unused
	LDY #$00
	LDA SpriteDMAArea, Y
	CMP #$F8
	BNE FindSpriteSlot_FallbackExit

	LDA SpriteDMAArea + 4, Y
	CMP #$F8
	BEQ FindSpriteSlot_Exit

FindSpriteSlot_FallbackExit:
	; If all else fails, here's $10
	LDY #$10

FindSpriteSlot_Exit:
	LDX byte_RAM_12
	RTS

; The object slot is inactive, so check that something else hasn't claimed the
; corresponding sprite slot.
FindSpriteSlot_CheckInactiveSlot:
	; Calculate the sprite slot using the flicker offset
	TXA
	CLC
	ADC SpriteFlickerSlot
	TAY
	LDA SpriteFlickerDMAOffset, Y

	; Check that both halves of the object's sprite slot are unused
	TAY
	LDA SpriteDMAArea, Y
	CMP #$F8
	BNE FindSpriteSlot_LoopNext
	LDA SpriteDMAArea + 4, Y
	CMP #$F8
	BNE FindSpriteSlot_LoopNext
	BEQ FindSpriteSlot_Exit


; Unused space in the original ($FB36 - $FDFF)
unusedSpace $FE00, $FF

IFDEF RESET_CHR_LATCH
CHRBank_Boss:
	.db CHRBank_EnemiesGrass ; Mouser
	.db CHRBank_EnemiesDesert ; Tryclyde
	.db CHRBank_EnemiesIce ; Fryguy
	.db CHRBank_EnemiesGrass ; Clawgrip
	.db CHRBank_EnemiesSky ; Wart
ENDIF

CHRBank_WorldEnemies:
	.db CHRBank_EnemiesGrass
	.db CHRBank_EnemiesDesert
	.db CHRBank_EnemiesGrass
	.db CHRBank_EnemiesIce
	.db CHRBank_EnemiesGrass
	.db CHRBank_EnemiesDesert
	.db CHRBank_EnemiesSky

CHRBank_WorldBossBackground:
	.db CHRBank_BackgroundGrass
	.db CHRBank_BackgroundDesert
	.db CHRBank_BackgroundGrass
	.db CHRBank_BackgroundIce
	.db CHRBank_BackgroundGrassClawgrip
	.db CHRBank_BackgroundDesert
	.db CHRBank_BackgroundSky

CHRBank_CharacterSize:
	.db CHRBank_Mario
	.db CHRBank_MarioSmall
	.db CHRBank_Princess
	.db CHRBank_PrincessSmall
	.db CHRBank_Toad
	.db CHRBank_ToadSmall
	.db CHRBank_Luigi
	.db CHRBank_LuigiSmall


LoadWorldCHRBanks:
	LDY #CHRBank_CommonEnemies1
	STY SpriteCHR2
	INY
	STY SpriteCHR3
	LDY CurrentWorldTileset
	LDA CHRBank_WorldEnemies, Y
	STA SpriteCHR4
	LDA CHRBank_WorldBossBackground, Y
	STA BackgroundCHR1
	LDA #CHRBank_Animated1
	STA BackgroundCHR2

IFDEF RESET_CHR_LATCH
	LDY BossTileset
	BMI LoadCharacterCHRBanks
	LDA CHRBank_Boss, Y
	STA SpriteCHR4
ENDIF

LoadCharacterCHRBanks:
	LDA CurrentCharacter
	ASL A
	ORA PlayerCurrentSize
	TAY
	LDA CHRBank_CharacterSize, Y
	STA SpriteCHR1
	RTS

IFDEF RESET_CHR_LATCH
CheckResetCHRLatch:
	LDA ResetCHRLatch
	BEQ CheckResetCHRLatch_Exit

	LDA #$00
	STA ResetCHRLatch

	LDY #CHRBank_CommonEnemies1
	STY SpriteCHR2
	INY
	STY SpriteCHR3

	LDY CurrentWorldTileset
	LDA CHRBank_WorldEnemies, Y
	STA SpriteCHR4
	LDA CHRBank_WorldBossBackground, Y
	STA BackgroundCHR1
	LDA #CHRBank_Animated1
	STA BackgroundCHR2

	LDY BossTileset
	BMI CheckResetCHRLatch_Exit
	LDA CHRBank_Boss, Y
	STA SpriteCHR4

CheckResetCHRLatch_Exit:
	RTS
ENDIF


LoadTitleScreenCHRBanks:
	LDA #CHRBank_TitleScreenBG1
	STA BackgroundCHR1
	LDA #CHRBank_TitleScreenBG2
	STA BackgroundCHR2
	RTS


LoadCelebrationSceneBackgroundCHR:
	LDA #CHRBank_CelebrationBG1
	STA BackgroundCHR1
	LDA #CHRBank_CelebrationBG2
	STA BackgroundCHR2
	RTS


LoadCharacterSelectCHRBanks:
	LDA #CHRBank_CharacterSelectSprites
	STA SpriteCHR1
	LDA #CHRBank_CharacterSelectBG1
	STA BackgroundCHR1
	LDA #CHRBank_CharacterSelectBG2
	STA BackgroundCHR2
	RTS


TitleCardCHRBanks:
	.db CHRBank_TitleCardGrass
	.db CHRBank_TitleCardDesert
	.db CHRBank_TitleCardGrass
	.db CHRBank_TitleCardIce
	.db CHRBank_TitleCardGrass
	.db CHRBank_TitleCardDesert
	.db CHRBank_TitleCardSky


ChangeTitleCardCHR:
	LDY CurrentWorld
	LDA TitleCardCHRBanks, Y
	STA BackgroundCHR2
	RTS


LoadBonusChanceCHRBanks:
	LDA #CHRBank_ChanceBG1
	STA BackgroundCHR1
	LDA #CHRBank_ChanceBG2
	STA BackgroundCHR2
	RTS


LoadMarioSleepingCHRBanks:
	LDY #CHRBank_EndingSprites
	STY SpriteCHR1
	INY
	STY SpriteCHR2
	LDA #CHRBank_EndingBackground1
	STA BackgroundCHR1
	LDA #CHRBank_EndingBackground1 + 2
	STA BackgroundCHR2
	RTS


; Unused space in the original ($FE97 - $FF4F)
unusedSpace $FF50, $FF


; public RESET
; This code is called when the NES is reset
RESET:
	SEI
	CLD
	LDA #PPUCtrl_Base2000 | PPUCtrl_WriteHorizontal | PPUCtrl_Sprite0000 | PPUCtrl_Background0000 | PPUCtrl_SpriteSize8x8 | PPUCtrl_NMIDisabled
	STA PPUCTRL
	LDX #$FF ; Reset stack pointer
	TXS

RESET_VBlankLoop:
	; Wait for first VBlank
	LDA PPUSTATUS
	AND #PPUStatus_VBlankHit
	BEQ RESET_VBlankLoop

RESET_VBlank2Loop:
	; Wait for second VBlank
	LDA PPUSTATUS
	BPL RESET_VBlank2Loop

IFDEF DEBUG
	LDA #$00
	STA Debug_InMenu
ENDIF

IF INES_MAPPER == MAPPER_FME7
	LDA #$0C
	STA $8000
	LDA #VMirror
	STA $A000
ELSE
	LDA #VMirror
	STA NametableMapping
	LDA #$80
	STA $A001 ; PRG-RAM protect
ENDIF
	JMP StartGame


;
; Switches the current CHR banks
;
IF INES_MAPPER == MAPPER_FME7
ChangeCHRBanks:
	JMP ChangeCHRBanks_FME7

	; Maintain location of the next subroutine
	unusedSpace $FF85, $FF

ELSEIF INES_MAPPER == MAPPER_MMC5
ChangeCHRBanks:
	JMP ChangeCHRBanks_MMC5

	; Maintain location of the next subroutine
	unusedSpace $FF85, $FF

ELSE ; INES_MAPPER == MAPPER_MMC3
ChangeCHRBanks:
	LDY #$05
ChangeCHRBanks_Loop:
	TYA
	ORA #$80
	STA $8000
	LDA BackgroundCHR1, Y
	STA $8001
	DEY
	BPL ChangeCHRBanks_Loop

	RTS
ENDIF


;
; Calling this one will save the changed bank
; to RAM, so if something uses the below version
; the original bank set with this can be restored.
;
ChangeMappedPRGBank:
	STA MMC3PRGBankTemp ; See below comment.

;
; Any call to this subroutine switches the lower two banks together.
;
; For example, loading Bank 0/1:
;
; ```
; LDA #$00
; JSR ChangeMappedPRGBank
; ```
;
; Loading Bank 2/3:
;
; ```
; LDA #$01
; JSR ChangeMappedPRGBank
; ```
;
; Etc.
;
; This version changes the bank numbers without
; saving the change to RAM, so the previous bank
; can be recalled later (mostly for temporary switches,
; like music handling and such)
;
ChangeMappedPRGBankWithoutSaving:
	ASL A

IF INES_MAPPER == MAPPER_FME7
	PHA
	LDA #$09
	STA $8000
	PLA
	STA $A000 ; Change first bank
	ORA #$01 ; Use the bank right after this one next
	PHA
	LDA #$0A
	STA $8000
	PLA
	STA $A000 ; Change second bank

	RTS

ELSEIF INES_MAPPER == MAPPER_MMC5
	ORA #$80
	STA $5114
	ORA #$01
	STA $5115
	RTS

	; Maintain location of the next subroutine
	unusedSpace $FFA0, $FF

ELSE ; INES_MAPPER == MAPPER_MMC3
	PHA
	LDA #$86
	STA $8000
	PLA
	STA $8001 ; Change first bank
	ORA #$01 ; Use the bank right after this one next
	PHA
	LDA #$87
	STA $8000
	PLA
	STA $8001 ; Change second bank
	RTS

ENDIF


;
; Sets the nametable mirroring by writing `$A000`.
;
; ##### Input
; - `A`: `$00` =  vertical, `$01` = horizontal
;
ChangeNametableMirroring:
IF INES_MAPPER == MAPPER_FME7
	PHA
	LDA #$0C
	STA $8000
	PLA
	STA $A000
ELSE
	STA NametableMapping
ENDIF
	RTS

; Unused space in the original ($FFA4 - $FFEA)
unusedSpace $FFEB, $FF

; Technically you can delete the stuff from here to the vector table as well,
; but because it looks slightly less like unused space it isn't being removed.

; Not used; leftover part of FamicomBox cart title?
UnusedTextZELDA:
	.db 'ZELDA'

; Note that this is NOT CODE.
; If the NES actually hits a BRK, the game will probably just explode.
; If you wanted, you could write  some sort of crash handler though.
IRQ:
	.db $DF
	.db $E6
	.db $00
	.db $00
	.db $38
	.db $04
	.db $01
	.db $04
	.db $01
	.db $BE

; Ensure our vectors are always here
	.pad $FFFA, $FF

; Vectors for the NES CPU. These should ALWAYS be at $FFFA!
; Add a .pad or .base before here if you change code above.
; NMI = VBlank
; RESET = ...well, reset.
; IRQ is not used, but you could if you wanted.
NESVectorTables:
	.dw NMI
IF INES_MAPPER == MAPPER_FME7
	.dw RESET_FME7
ELSEIF INES_MAPPER == MAPPER_MMC5
	.dw RESET_MMC5
ELSE ; INES_MAPPER == MAPPER_MMC3
	.dw RESET
ENDIF
	.dw IRQ



