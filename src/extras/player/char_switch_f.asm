;
; 
;
CustomCopyChar:
      LDA     #PRGBank_A_B
      JSR     ChangeMappedPRGBank
CharSel:
      LDA     CurrentCharacter
      STA     PreviousCharacter
      TAX
      LDY     StatOffsets,X
      LDX     #0
RptStats:
      LDA     MarioStats,Y
      STA     PickupSpeedAnimation,X
      INY
      INX
      CPX     #$17
      BCC     RptStats
GetCharBit:
      LDA     CurrentCharacter
      ASL     A
      ASL     A
      TAX
      JSR     RptPalette

EndCharacterSwap:
    LDA     #PRGBank_2_3
    JSR     ChangeMappedPRGBank
    ; load carry offsets
	; Copy the character-specific FINAL carrying heights into memory
	LDY CurrentCharacter
	LDA CarryYOffsetBigLo, Y
	STA ItemCarryYOffsetsRAM
	LDA CarryYOffsetSmallLo, Y
	STA ItemCarryYOffsetsRAM + $07
	LDA CarryYOffsetBigHi, Y
	STA ItemCarryYOffsetsRAM + $0E
	LDA CarryYOffsetSmallHi, Y
	STA ItemCarryYOffsetsRAM + $15
    LDA     #PRGBank_0_1
    JSR     ChangeMappedPRGBank
	; update chr for character
	JSR LoadCharacterCHRBanks
    RTS

RptPalette:
    LDY #0
-
    LDA     MarioPalette,X
    STA     RestorePlayerPalette0,Y
    INX
    INY
    CPY     #4
    BNE     -
    LDX byte_RAM_300
    LDA #$3F
    STA PPUBuffer_301, X
    LDA #$10
    STA PPUBuffer_301 + 1, X
    LDA #$04
    STA PPUBuffer_301 + 2, X
    LDA SkyColor
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
+
    RTS