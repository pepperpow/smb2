  
;
; ### Render foreground level data
;
; Reads level data from the beginning and processes individual objects.
;
; ##### Input
; - `byte_RAM_4`: raw data offset
;
ReadLevelForegroundData:
	; start at area page 0
	LDA #$00
	STA byte_RAM_E8
	STA PlayerXHi
	JSR LoadLevelDataPtrIntoMemoly

	; weird? the next lines do nothing
	LDY #$00
	JMP ReadLevelForegroundData_NextByteObject

ReadLevelForegroundData_NextByteObject:
	LDY byte_RAM_4

ReadLevelForegroundData_NextByte:
	INY

ReadLevelForegroundData_ProcessObject:
	; Stash the lower nybble of the first byte.
	; For a special object, this will be the special object type.
	; For a regular object, this will be the X position.
	; If the upper nybble of the first byte is $F, this is a special object.
	LDA (byte_RAM_5), Y
	CMP #$FF
	BNE +
	; Encountering `$FF` indicates the end of the level data.
	RTS
+
	LDA (byte_RAM_5), Y
	AND #$F0
	CMP #$F0
	BNE ReadLevelForegroundData_RegularObject

ReadLevelForegroundData_SpecialObject:  
	LDA (byte_RAM_5), Y
	CMP #$FE ;; Move Level Window
	BNE +
	JSR CopyLevelDataMemory_Switch
	JMP ReadLevelForegroundData_ProcessObject
	+
	CMP #$FD ;; Set Page 
	BNE +
	STY byte_RAM_F
	JSR SetAreaPointer
	INY
	STY byte_RAM_4
	JMP ReadLevelForegroundData_ProcessObject
	+
	CMP #$FC ;; Set Random Memory Address
	BNE +
	JSR SetArbitraryMemAddress
	LDA (byte_RAM_5), Y
	TAX
	INY
	STY byte_RAM_5
	JSR SetAddressLinear
	JMP ReadLevelForegroundData_ProcessObject
	+
	CMP #$FB ;; Set Random Memory Address Single
	BNE +
	JSR SetArbitraryMemAddress
	STY byte_RAM_F
	JSR SetAddressSingle
	JMP ReadLevelForegroundData_ProcessObject
	+
	CMP #$FA ;; Jump Random Memory Address
	BNE +
	JSR SetArbitraryMemAddress
	JSR SetArbitraryJump
	LDY byte_RAM_F
	JMP ReadLevelForegroundData_ProcessObject
	+
;	CMP #$F9 ;; Jump Object Memory Address
;	BNE +
;	JSR SetArbitraryMemAddress
;	LDA (byte_RAM_5), Y
;	AND #$0F
;	STA byte_RAM_E5
;	; If the upper nybble of the first byte is $F, this is a special object.
;	LDA (byte_RAM_5), Y
;	AND #$F0
;	STA byte_RAM_E6
;	STY byte_RAM_4
;	JSR SetTileOffsetAndAreaPageAddr_Bank6
;	JSR SetArbitraryJump
;	JMP ReadLevelForegroundData_ProcessObject
;	+
	AND #$0F
	STA byte_RAM_E8

	JMP ReadLevelForegroundData_NextByte

ReadLevelForegroundData_RegularObject:

	; check object type
	; upper nybble
	LSR A
	LSR A
	LSR A
	LSR A
	LSR A
	STA byte_RAM_50D ; commands 0-7 + h/z

	PHA
	LDA (byte_RAM_5), Y
	AND #%00011111
	STA $503 ;; size
	STA byte_RAM_50E ;; size
	PLA

	PHA

	LDA (byte_RAM_5), Y
	AND #%00011111

	; pos is now second byte
	INY
	LDA (byte_RAM_5), Y
	AND #$0F
	STA byte_RAM_E5
	; If the upper nybble of the first byte is $F, this is a special object.
	LDA (byte_RAM_5), Y
	AND #$F0
	STA byte_RAM_E6
	STY byte_RAM_4
	JSR SetTileOffsetAndAreaPageAddr_Bank6

	PLA

	JSR JumpToTableAfterJump
	.dw SimplePlace ;; position, command/size, tile
	.dw SimplePlace ;; position, command/size, tile
	.dw ArrayPlace ;; position, command/size, array
	.dw ArrayPlace ;; position, command/size, array
	.dw DimensionPlace ;; position, command/size, array, dimension
	.dw DimensionPlace ;; position, command/size, array, dimension
	.dw DimensionCapped ;; position, command/size, array (1x3), dimension
	.dw DimensionCapped ;; position, command/size, array (1x3), dimension

SetArbitraryMemAddress:
	STY byte_RAM_F
	INY
	LDA (byte_RAM_5), Y
	STA $c5+1 ;; ld 1
	INY
	LDA (byte_RAM_5), Y
	STA $c5 ;; ld 2
	INY
	RTS

SetArbitraryJump:
	STY byte_RAM_F
	LDA #$0
	STA byte_RAM_5
	JMP ($c5)

SetAddressSingle:
	LDA (byte_RAM_5), Y
	LDY #$0
	STA ($c5), Y
	LDY byte_RAM_F
	INY
	RTS

SetAddressLinear:
	LDY #$0
	-
	LDA (byte_RAM_5), Y
	STA ($c5), Y
	INY
	DEX
	BNE -
	CLC
	TYA 
	ADC byte_RAM_5
	TAY
	LDA #$0
	STA byte_RAM_5
	STY byte_RAM_F
	RTS

SetAddressSingleRepeat:
	INY
	STY byte_RAM_F
	LDY #$0
	LDA (byte_RAM_5), Y
	-
	STA ($c5), Y
	INY
	DEX
	BNE -
	LDA #$0
	STA byte_RAM_5
	LDY byte_RAM_F
	RTS

GoJumpArbitrary:

IncrementXY:
	TXA
	PHA
	LDA byte_RAM_50D
	AND #$1
	BNE +
	JSR IncrementAreaXOffset
	PLA
	TAX
	RTS
+   JSR IncrementAreaYOffset
	PLA
	TAX
	RTS

IncrementXYInverse:
	LDA byte_RAM_50D
	AND #$1
	BNE +
	JSR IncrementAreaYOffset
	RTS
+   
	JSR IncrementAreaXOffset
	JSR SetTileOffsetAndAreaPageAddr_Bank6
	RTS

SimplePlace: ;; position, command/size, tile
	LDA #>ReadLevelForegroundData_NextByteObject
	PHA
	LDA #<ReadLevelForegroundData_NextByteObject - 1
	PHA
	JSR LdSingleTile
	LDY byte_RAM_E7
	-
	LDA $6A01 
	STA (byte_RAM_1), Y
	JSR IncrementXY
	DEC byte_RAM_50E
	BNE -
	RTS

ArrayPlace:
	LDA #>ReadLevelForegroundData_NextByteObject
	PHA
	LDA #<ReadLevelForegroundData_NextByteObject - 1
	PHA
	JSR LdTilesToRam
	LDY byte_RAM_E7
ArrayPlaceNoSet:
	LDX #$0
	-
	LDA $6B01, X 
	STA (byte_RAM_1), Y
	INX
	CPX PseudoRNGValues ;; size
	BNE +
	DEX
	+
	JSR IncrementXY
	DEC byte_RAM_50E
	BNE -
	RTS

DimensionPlace: 
	JSR LdDimensions
	JSR LdTilesToRam
	---
	LDA PseudoRNGValues + 1 ;; load 
	STA byte_RAM_50E
	LDY byte_RAM_E7
	JSR ArrayPlaceNoSet
	LDY byte_RAM_E7
	JSR IncrementXYInverse
	STY byte_RAM_E7
	DEC PseudoRNGValues + 2
	BNE ---
	JMP ReadLevelForegroundData_NextByteObject
	
DimensionCapped:
	JSR LdDimensions
	LDA byte_RAM_50E
	BNE +
	JSR LdTilesToRam_Last
	LDA #$3
	STA byte_RAM_50E
	BNE +++
	+
	LDA #$3
	STA byte_RAM_50E
	JSR LdTilesToRam
	+++
	---
	LDA PseudoRNGValues + 1 ;; load 
	STA byte_RAM_50E
	LDY byte_RAM_E7
	JSR ArrayPlaceCapped
	LDY byte_RAM_E7
	JSR IncrementXYInverse
	STY byte_RAM_E7
	DEC PseudoRNGValues + 2
	BNE ---
	JMP ReadLevelForegroundData_NextByteObject

ArrayPlaceCapped:
	LDA $6B01
	STA (byte_RAM_1), Y
	JSR IncrementXY
	LDA byte_RAM_50E
	BEQ +
	-
	LDA $6B02
	STA (byte_RAM_1), Y
	JSR IncrementXY
	DEC byte_RAM_50E
	BNE -
	+
	LDA $6B03
	STA (byte_RAM_1), Y
	JSR IncrementXY
	RTS


LdSingleTile:
	LDA byte_RAM_50E ;; if no length, repeat last tile length and tile
	BEQ +
	LDY byte_RAM_4
	INY
	LDA (byte_RAM_5), Y
	STA $6A01
	STY byte_RAM_4
	LDA byte_RAM_50E ;; load 
	STA $6A00
	+
	LDA $6A00	
	STA PseudoRNGValues
	STA byte_RAM_50E
	RTS

LdTilesToRam:
	LDA byte_RAM_50E
	BEQ LdTilesToRam_Last
	LDX #$0
	LDY byte_RAM_4
	--
	INY
	LDA (byte_RAM_5), Y
	STA $6B01, X
	INX
	CPX byte_RAM_50E
	BNE --
	STY byte_RAM_4
	LDA byte_RAM_50E ;; load 
	STA $6B00
LdTilesToRam_Last:
	LDA $6B00	
	STA PseudoRNGValues
	STA byte_RAM_50E
	RTS

ConvertTilesIf:
	LDX #$32
	--
	LDA $6B01, X
	CMP #BackgroundTile_DoorBottomLock
	BNE +
	LDA #BackgroundTile_DoorBottom
	STA $6B01, X
	+
	DEX
	BNE --
	RTS

IfLockedSkipX:
	LDA KeyUsed
	BEQ +
	LDX byte_RAM_50E
	LDY byte_RAM_F
-
	INY
	DEX
	BNE -
+   STY byte_RAM_F
	RTS

	

LdDimensions:
	LDX #$0
	LDY byte_RAM_4
	INY
	LDA (byte_RAM_5), Y
	AND #$F
	STA PseudoRNGValues + 1
	LDA (byte_RAM_5), Y
	LSR
	LSR
	LSR
	LSR
	STA PseudoRNGValues + 2
	STY byte_RAM_4
	RTS

