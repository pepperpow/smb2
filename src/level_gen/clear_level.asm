;
; Resets level data and PPU scrolling.
;
; This starts at the end of the last page and works backwards to create a blank slate upon which to
; render the current area's level data.
;
ResetLevelData:
	LDA #<DecodedLevelData
	STA byte_RAM_A
	LDY #>(DecodedLevelData+$0900)
	STY byte_RAM_B
	LDY #>(DecodedLevelData-$0100)

	; Set all tiles to sky
	LDA #BackgroundTile_Sky

ResetLevelData_Loop:
	STA (byte_RAM_A), Y
	DEY
	CPY #$FF
	BNE ResetLevelData_Loop

	DEC byte_RAM_B
	LDX byte_RAM_B
	CPX #>DecodedLevelData
	BCS ResetLevelData_Loop

	LDA #$00
	STA PPUScrollXMirror
	STA PPUScrollYMirror
	STA CurrentLevelPageX
	STA byte_RAM_D5
	STA byte_RAM_E6
	STA ScreenYHi
	STA ScreenYLo
	STA ScreenBoundaryLeftHi
	STA ScreenBoundaryLeftLo
	STA_abs NeedsScroll
	RTS