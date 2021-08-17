;
; ## Area loading and rendering (from original)
;
; This is the main subroutine for parsing and rendering an entire area of a level.
;
ENUM $0
	RawLevelData_PtrIndex = byte_RAM_4
	RawLevelData_Ptr = byte_RAM_5
	Obj_XPos = byte_RAM_E5
	Obj_YPos = byte_RAM_E6
	Obj_Page = byte_RAM_E8
	Obj_RLECommand = byte_RAM_50D
	Obj_Length = byte_RAM_50E
	Gen_XPos = PseudoRNGValues + 1
	Gen_YPos = PseudoRNGValues + 2
	Gen_Size = $503
ENDE

LoadCurrentArea:
	; First, reset the level data and PPU scrolling.
	JSR ResetLevelData

	JSR ResetPPUScrollHi_Bank6

	; Determine the address of the raw level data.
	JSR RestoreLevelDataCopyAddress

	;
	; ### Read area header
	;
	; The level header is read backwards starting at the last byte.
	;

	; Queue any changes to the background music.
	JSR LoadAreaMusic

	; This doesn't hurt, but shouldn't be necessary.
	JSR RestoreLevelDataCopyAddress

	; Determine whether this area is Horizontal or vertical.
	LDY #$00
	LDA (RawLevelData_Ptr), Y
	ASL A
	LDA #$00
	ROL A
	STA IsHorizontalLevel

	; Reset the area page so that we can start drawing from the beginning.
	LDA #$00
	STA Obj_Page

	; Determine the level length (in pages).
	LDY #$01
	LDA (RawLevelData_Ptr), Y
	LSR A
	LSR A
	LSR A
	LSR A
	STA CurrentLevelPages

	IFDEF AREA_HEADER_TILESET
	; World tileset to use for the area.
	; LDA (RawLevelData_Ptr), Y
	; ROL A
	; ROL A
	; ROL A
	; ROL A
	; AND #%00000111
	; CMP #$07 ; only $00-06 are valid, force $07 to CurrentWorld
	; BCC LoadCurrentArea_IsValid
	LDA CurrentWorld
	STA CurrentWorldTileset
	ENDIF

;; cropped out code here

LoadCurrentArea_ForegroundData:
	; Reset the tile placement offset for the second pass.
	LDA #$00
	STA Obj_YPos

	; Advance to the first object in the level data.
	LDA #$01
	STA RawLevelData_PtrIndex

	; Run the second pass of level rendering to place regular objects in the level.
	JSR ReadLevelForegroundData

	; Bootstrap the pseudo-random number generator.
	LDA #$22
	ORA byte_RAM_10
	STA PseudoRNGValues
	RTS

;
; ### Render foreground level data
;
; Reads level data from the beginning and processes individual objects.
;
; ##### Input
; - `RawLevelData_PtrIndex`: raw data offset
;
ReadLevelForegroundData:
	; start at area page 0
	LDA #$00
	STA Obj_Page
	STA PlayerXHi

ReadLevelForegroundData_FromLastPage:
	JSR LoadLevelDataPtrIntoMemoly

	; weird? the next lines do nothing
	LDY #$00
	JMP ReadLevelForegroundData_NextByteObject

ReadLevelForegroundData_NextByteObject:
	LDA Gen_Size
	BEQ +
		LDY byte_RAM_E7
		JSR IncrementXYInverse
		STY byte_RAM_E7
		DEC Gen_Size
		BPL ++
			LDA (byte_RAM_1), Y
			CMP #BackgroundTile_Sky
			BNE +x
			LDA Obj_Page
			CMP #$A
			BCS +x
			LDA IsHorizontalLevel
			AND Obj_RLECommand
			EOR #1
			BEQ ++ 
			CPY #$E0
			BCS +x
		++
		LDA Obj_RLECommand
		JMP JumpTableRLE
		+x
		LDA #$0
		STA Gen_Size
	+
	LDY RawLevelData_PtrIndex


ReadLevelForegroundData_NextByte:
	INY

ReadLevelForegroundData_ProcessObject:
	; Stash the lower nybble of the first byte.
	; For a special object, this will be the special object type.
	; For a regular object, this will be the X Pos,
	; If the upper nybble of the first byte is $F, this is a special object.
	LDA (RawLevelData_Ptr), Y
	AND #$F0
	CMP #$F0
	BNE ReadLevelForegroundData_RegularObject

ReadLevelForegroundData_SpecialObject:  
	LDA (RawLevelData_Ptr), Y
	CMP #$FF
	BNE + ; Encountering `$FF` indicates the end of the level data.
	RTS
	+ CMP #$FE ;; Move Level Window
	BNE +
	INY
	LDA (RawLevelData_Ptr), Y
	STA byte_RAM_7
	INY
	LDA (RawLevelData_Ptr), Y
	STA byte_RAM_8
	LDY #$0
	STY RawLevelData_PtrIndex
	JSR CopyLevelDataMemory_Switch
	LDY #$2
	JMP ReadLevelForegroundData_ProcessObject
	+ CMP #$FD ;; Set Pointer
	BNE +
	STY byte_RAM_F
	JSR SetAreaPointer
	INY
	STY RawLevelData_PtrIndex
	JMP ReadLevelForegroundData_ProcessObject
	+ CMP #$FC ;; Set Random Memory Address
	BNE +
	JSR SetArbitraryMemAddress
	LDA (RawLevelData_Ptr), Y
	TAX
	INY
	STY RawLevelData_Ptr
	JSR SetAddressLinear
	JMP ReadLevelForegroundData_ProcessObject
	+ CMP #$FB ;; Set Random Memory Address Single
	BNE +
	JSR SetArbitraryMemAddress
	STY byte_RAM_F
	JSR SetAddressSingle
	JMP ReadLevelForegroundData_ProcessObject
	+ CMP #$FA ;; Jump Random Memory Address
	BNE +
	JSR SetArbitraryMemAddress
	JSR SetArbitraryJump
	LDY byte_RAM_F
	JMP ReadLevelForegroundData_ProcessObject
	+ AND #$F ;; check last number...
	BNE + ;; 0 == Increase Page
	INC Obj_Page
	LDA Obj_Page
	AND #$F
	BNE +e ; always jump... 
	+ CMP Obj_Page ;; if byte != page, set page
	BNE +e ;; if byte == Page, set to zero
	LDA #$0
	+e STA Obj_Page
	JMP ReadLevelForegroundData_NextByte

ReadLevelForegroundData_RegularObject:
	; check object type
	; upper nybble
	LSR A
	LSR A
	LSR A
	LSR A
	LSR A

	CMP #CMD_RepeatLine
	BNE +
		LDA (RawLevelData_Ptr), Y
		AND #%00011111
		STA Gen_Size ;; size
		BNE ++
		DEC Gen_Size
		++
		INY
		JMP ReadLevelForegroundData_ProcessObject
	+

	STA Obj_RLECommand ; commands 0-7 + h/z

	LDA (RawLevelData_Ptr), Y
	AND #%00011111
	STA Obj_Length ;; size

	LDA Obj_RLECommand
	
	; pos is now second byte
	INY
	LDA (byte_RAM_5), Y
	AND #$0F
	STA Obj_XPos
	; If the upper nybble of the first byte is $F, this is a special object.
	LDA (byte_RAM_5), Y
	AND #$F0
	STA Obj_YPos
	STY RawLevelData_PtrIndex
	JSR SetTileOffsetAndAreaPageAddr_Bank6

	LDA Obj_RLECommand

JumpTableRLE:
	JSR JumpToTableAfterJump
	.dw SimplePlace ;; commandAndSize, Pos, tile
	.dw SimplePlace ;; commandAndSize, Pos, tile
	.dw ArrayPlace ;; commandAndSize, Pos, array
	.dw ArrayPlace ;; commandAndSize, Pos, array
	.dw DimensionCapped ;; commandAndSize, Pos, array (1x3)
	; .dw DimensionPlace ;; commandAndSize, Pos, array, dimension
	; .dw DimensionPlace ;; commandAndSize, Pos, array, dimension
	; .dw DimensionCapped ;; commandAndSize

CMD_SimpleHorizontal = %000
CMD_SimpleVertical = %001
CMD_ArrayHorizontal = %010
CMD_ArrayVertical = %011
CMD_CappedHort = %100
CMD_CappedVert = %101

CMD_RepeatLine = %111

SetArbitraryMemAddress:
	STY byte_RAM_F
	INY
	LDA (RawLevelData_Ptr), Y
	STA $c5+1 ;; ld 1
	INY
	LDA (RawLevelData_Ptr), Y
	STA $c5 ;; ld 2
	INY
	RTS

SetArbitraryJump:
	STY byte_RAM_F
	LDA #$0
	STA RawLevelData_Ptr
	JMP ($c5)

SetAddressSingle:
	LDA (RawLevelData_Ptr), Y
	LDY #$0
	STA ($c5), Y
	LDY byte_RAM_F
	INY
	RTS

SetAddressLinear:
	LDY #$0
	-
	LDA (RawLevelData_Ptr), Y
	STA ($c5), Y
	INY
	DEX
	BNE -
	CLC
	TYA 
	ADC RawLevelData_Ptr
	TAY
	LDA #$0
	STA RawLevelData_Ptr
	STY byte_RAM_F
	RTS

SetAddressSingleRepeat:
	INY
	STY byte_RAM_F
	LDY #$0
	LDA (RawLevelData_Ptr), Y
	-
	STA ($c5), Y
	INY
	DEX
	BNE -
	LDA #$0
	STA RawLevelData_Ptr
	LDY byte_RAM_F
	RTS

IncrementXY:
	TXA
	PHA
	LDA Obj_RLECommand
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
	LDA Obj_RLECommand
	AND #$1
	BNE +
	JSR IncrementAreaYOffset
	RTS
	+   
	JSR IncrementAreaXOffset
	JSR SetTileOffsetAndAreaPageAddr_Bank6
	RTS

SimplePlace: ;; commandAndSize, Pos, tile
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
	DEC Obj_Length
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
	DEC Obj_Length
	BNE -
	RTS

DimensionPlace: 
	JSR LdDimensions
	JSR LdTilesToRam
	---
	LDA Gen_XPos ;; load 
	STA Obj_Length
	LDY byte_RAM_E7
	JSR ArrayPlaceNoSet
	LDY byte_RAM_E7
	JSR IncrementXYInverse
	STY byte_RAM_E7
	DEC Gen_YPos
	BNE ---
	JMP ReadLevelForegroundData_NextByteObject
	
DimensionCapped:
	LDA Obj_Length
	BNE +
	JSR LdTilesToRam_Last
	BNE +++
	+ JSR LdTilesToRam
	+++ 
	LDA Obj_Length
	STA Gen_XPos
	LDA #$3 ; ---
	STA Obj_Length
	LDA Gen_XPos ;; load 
	STA Obj_Length
	; LDY byte_RAM_E7
	JSR ArrayPlaceCapped
	; LDY byte_RAM_E7
	; JSR IncrementXYInverse
	; STY byte_RAM_E7
	; DEC Gen_YPos
	; BNE ---
	JMP ReadLevelForegroundData_NextByteObject

ArrayPlaceCapped:
	LDA $6B01
	STA (byte_RAM_1), Y
	JSR IncrementXY
	LDA Obj_Length
	BEQ +
	-
	LDA $6B02
	STA (byte_RAM_1), Y
	JSR IncrementXY
	DEC Obj_Length
	BNE -
	+
	LDA $6B03
	STA (byte_RAM_1), Y
	JSR IncrementXY
	RTS

LdSingleTile:
	LDA Obj_Length ;; if no length, repeat last tile length and tile
	BEQ +
	LDY RawLevelData_PtrIndex
	INY
	LDA (RawLevelData_Ptr), Y
	STA $6A01
	STY RawLevelData_PtrIndex
	LDA Obj_Length ;; load 
	STA $6A00
	+
	LDA $6A00	
	STA PseudoRNGValues
	STA Obj_Length
	RTS

LdTilesToRam:
	LDA Obj_Length
	BEQ LdTilesToRam_Last
	LDX #$0
	LDY RawLevelData_PtrIndex
	--
	INY
	LDA (RawLevelData_Ptr), Y
	STA $6B01, X
	INX
	CPX Obj_Length
	BNE --
	STY RawLevelData_PtrIndex
	LDA Obj_Length ;; load 
	STA $6B00
LdTilesToRam_Last:
	LDA $6B00	
	STA PseudoRNGValues
	STA Obj_Length
	RTS

; ConvertTilesIf:
; 	LDX #$32
; 	--
; 	LDA $6B01, X
; 	CMP #BackgroundTile_DoorBottomLock
; 	BNE +
; 	LDA #BackgroundTile_DoorBottom
; 	STA $6B01, X
; 	+
; 	DEX
; 	BNE --
; 	RTS

; IfLockedSkipX:
; 	LDA KeyUsed
; 	BEQ +
; 	LDX Obj_Length
; 	LDY byte_RAM_F
; -
; 	INY
; 	DEX
; 	BNE -
; +   STY byte_RAM_F
; 	RTS

	
LdDimensions:
	LDX #$0
	LDY RawLevelData_PtrIndex
	INY
	LDA (RawLevelData_Ptr), Y
	AND #$F
	STA Gen_XPos
	LDA (RawLevelData_Ptr), Y
	LSR
	LSR
	LSR
	LSR
	STA Gen_YPos
	STY RawLevelData_PtrIndex
	RTS

;
; #### Area Pointer Object `$F5` (pulled from original)
;
; Sets the area pointer for this page.
;
; ##### Input
; - `byte_RAM_F`: level data byte offset
; - `Obj_Page`: area page
;
; ##### Output
; - `byte_RAM_F`: level data byte offset
;
SetAreaPointer:
	LDY byte_RAM_F
	INY
	LDA Obj_Page
	ASL A
	TAX
	LDA (RawLevelData_Ptr), Y
	STA AreaPointersByPage, X
	INY
	INX
	LDA (RawLevelData_Ptr), Y
	STA AreaPointersByPage, X
	STY byte_RAM_F
	RTS
