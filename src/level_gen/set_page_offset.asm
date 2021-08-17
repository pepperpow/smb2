;
; Updates the area page and tile placement offset
;
; ##### Input
; - `byte_RAM_E8`: area page
; - `byte_RAM_E5`: tile placement offset shift
; - `byte_RAM_E6`: previous tile placement offset
;
; ##### Output
; - `byte_RAM_1`: low byte of decoded level data RAM
; - `byte_RAM_2`: high byte of decoded level data RAM
; - `byte_RAM_E7`: target tile placement offset
;
SetTileOffsetAndAreaPageAddr_Bank6:
	LDX byte_RAM_E8
	JSR SetAreaPageAddr_Bank6

	LDA byte_RAM_E6
	CLC
	ADC byte_RAM_E5
	STA byte_RAM_E7
	RTS

;
; Updates the area page that we're drawing tiles to
;
; ##### Input
; - `X`: area page
;
; ##### Output
; - `byte_RAM_1`: low byte of decoded level data RAM
; - `byte_RAM_2`: high byte of decoded level data RAM
;
SetAreaPageAddr_Bank6:
	LDA DecodedLevelPageStartLo_Bank6, X
	STA byte_RAM_1
	LDA DecodedLevelPageStartHi_Bank6, X
	STA byte_RAM_2
	RTS

IncrementAreaXOffset:
	INY
	TYA
	AND #$0F
	BNE IncrementAreaXOffset_Exit

	TYA
	SEC
	SBC #$10
	TAY
	STX byte_RAM_B
	LDX byte_RAM_E8
	INX
	STX byte_RAM_D
	JSR SetAreaPageAddr_Bank6
	LDX byte_RAM_B

IncrementAreaXOffset_Exit:
	RTS


; Moves one row down and increments the page, if necessary
IncrementAreaYOffset:
	TYA
	CLC
	ADC #$10
	TAY
	CMP #$F0
	BCC IncrementAreaYOffset_Exit

	; increment the area page
	LDX byte_RAM_E8
	INX
	JSR SetAreaPageAddr_Bank6

	TYA
	AND #$0F
	TAY

IncrementAreaYOffset_Exit:
	RTS