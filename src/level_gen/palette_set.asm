;
; Reads a color from the world's background palette
;
; ##### Input
; - `X`: color index
;
; ##### Output
; - `A`: background palette color
;
ReadWorldBackgroundColor:
	; stash X and Y registers
	STY byte_RAM_E
	STX byte_RAM_D
	; look up the address of the current world's palette
	LDY CurrentWorldTileset
	LDA WorldBackgroundPalettePointersLo, Y
	STA byte_RAM_7
	LDA WorldBackgroundPalettePointersHi, Y
	STA byte_RAM_8
	; load the color
	LDY byte_RAM_D
	LDA (byte_RAM_7), Y
	; restore prior X and Y registers
	LDY byte_RAM_E
	LDX byte_RAM_D
	RTS

;
; Reads a color from the world's sprite palette
;
; ##### Input
; - `X`: color index
;
; ##### Output
; - `A`: background palette color
;
ReadWorldSpriteColor:
	; stash X and Y registers
	STY byte_RAM_E
	STX byte_RAM_D
	; look up the address of the current world's palette
	LDY CurrentWorldTileset
	LDA WorldSpritePalettePointersLo, Y
	STA byte_RAM_7
	LDA WorldSpritePalettePointersHi, Y
	STA byte_RAM_8
	; load the color
	LDY byte_RAM_D
	LDA (byte_RAM_7), Y
	; restore prior X and Y registers
	LDY byte_RAM_E
	LDX byte_RAM_D
	RTS

;
; Loads the current area or jar palette
;
LoadCurrentPalette:
	LDA InSubspaceOrJar
	CMP #$01
	BNE LoadCurrentPalette_NotJar

	; This function call will overwrite the
	; normal level loading area with $7A00
	JSR HijackLevelDataCopyAddressWithJar

	JMP LoadCurrentPalette_AreaOffset

; ---------------------------------------------------------------------------

LoadCurrentPalette_NotJar:
	JSR RestoreLevelDataCopyAddress

; Read the palette offset from the area header
LoadCurrentPalette_AreaOffset:
	LDY #$00
	LDA (byte_RAM_5), Y

; End of function LoadCurrentPalette

;
; Loads a world palette to RAM
;
; ##### Input
; - `A`: background palette header byte
;
ApplyPalette:
	; Read background palette index from area header byte
	STA byte_RAM_F
	AND #%00111000
	ASL A
	TAX
	JSR ReadWorldBackgroundColor

	; Something PPU-related. If it's not right, the colors are very wrong.
	STA SkyColor
	LDA #$3F
	STA PPUBuffer_301
	LDA #$00
	STA PPUBuffer_301 + 1
	LDA #$20
	STA PPUBuffer_301 + 2

	LDY #$00
ApplyPalette_BackgroundLoop:
	JSR ReadWorldBackgroundColor
	STA PPUBuffer_301 + 3, Y
	INX
	INY
	CPY #$10
	BCC ApplyPalette_BackgroundLoop

	; Read sprite palette index from area header byte
	LDA byte_RAM_F
	AND #$03
	ASL A
	STA byte_RAM_F
	ASL A
	ADC byte_RAM_F
	ASL A
	TAX

	LDY #$00
ApplyPalette_SpriteLoop:
	JSR ReadWorldSpriteColor
	STA unk_RAM_318, Y
	INX
	INY
	CPY #$0C
	BCC ApplyPalette_SpriteLoop

	LDA #$00
	STA unk_RAM_318, Y
	LDY #$03

ApplyPalette_PlayerLoop:
	LDA RestorePlayerPalette0, Y
	STA unk_RAM_314, Y
	DEY
	BPL ApplyPalette_PlayerLoop

	LDX #$03
	LDY #$10
ApplyPalette_SkyLoop:
	LDA SkyColor
	STA PPUBuffer_301 + 3, Y
	INY
	INY
	INY
	INY
	DEX
	BPL ApplyPalette_SkyLoop

	RTS
