;
; Bank 0 & Bank 1
; ===============
;
; What's inside:
;
;   - Title screen
;   - Player controls
;   - Player state handling
;   - Enemy handling
;

;
; Initializes a vertical area
;
InitializeAreaVertical:
	LDA byte_RAM_502
	BNE loc_BANK0_805D

	LDA #HMirror
	JSR ChangeNametableMirroring

	LDA CurrentLevelEntryPage
	BNE loc_BANK0_8013

loc_BANK0_800F:
	LDA #$09
	BNE loc_BANK0_8016

loc_BANK0_8013:
	SEC
	SBC #$01

loc_BANK0_8016:
	ORA #$C0
	STA BackgroundUpdateBoundaryBackward
	SEC
	SBC #$40
	STA BackgroundUpdateBoundary
	LDA CurrentLevelEntryPage

loc_BANK0_8022:
	CLC
	ADC #$01
	CMP #$0A
	BNE loc_BANK0_802B

	LDA #$00

loc_BANK0_802B:
	ORA #$10
	STA BackgroundUpdateBoundaryForward
	LDA CurrentLevelEntryPage
	LDY #$00
	JSR ResetPPUScrollHi

	LDA #$20
	STA DrawBackgroundTilesPPUAddrLoBackward
	LDA #$60
	STA DrawBackgroundTilesPPUAddrLoForward

	; Set the flag for the initial screen render
	INC byte_RAM_502

	; Initialize the PPU update boundary
	LDA #$E0
	STA byte_RAM_E2
	LDA #$01
	STA byte_RAM_E4
	STA byte_RAM_53A
	LSR A
	STA DrawBackgroundTilesPPUAddrLo

	; Set the screen y-position
	LDY CurrentLevelEntryPage
	JSR PageHeightCompensation
	STA ScreenYLo
	STY ScreenYHi

	; Cue player transition
	JSR ApplyAreaTransition

loc_BANK0_805D:
	LDA #$00
	STA byte_RAM_6
	LDA #$FF
	STA byte_RAM_505
	LDA #$A0
	STA PPUScrollCheckLo

	JSR sub_BANK0_823D

	LDA byte_RAM_53A
	BNE InitializeAreaVertical_Exit

	; Initial screen render is complete
	INC BreakStartLevelLoop

	LDA #$E8
	STA byte_RAM_E1
	LDA #$C8
	STA byte_RAM_E2

	LDA #$00
	STA byte_RAM_502

InitializeAreaVertical_Exit:
	RTS


;
; Applies vertical screen scrolling if `DetermineVerticalScroll` indicated that
; it was necessary.
;
ApplyVerticalScroll:
	LDA NeedsScroll
	AND #%00000100
	BNE loc_BANK0_809D

	;	Not currently in a scroll interval
	LDA NeedsScroll
	AND #%00000111
	BNE loc_BANK0_8092

	JMP loc_BANK0_819C

; ---------------------------------------------------------------------------

loc_BANK0_8092:
	LDA NeedsScroll
	ORA #%00000100
	STA NeedsScroll
	LDA #$12
	STA CameraScrollTiles

loc_BANK0_809D:
	LDA NeedsScroll
	LSR A
	LDA PPUScrollYMirror
	BCC loc_BANK0_8103

	BNE loc_BANK0_80B1

	LDA BackgroundUpdateBoundaryBackward
	AND #$0F
	CMP #$09
	BNE loc_BANK0_80B1

	JMP loc_BANK0_819C

; ---------------------------------------------------------------------------

loc_BANK0_80B1:
	LDA #$01
	JSR SetObjectLocks

	LDA PPUScrollYMirror
	SEC
	SBC #$04
	STA PPUScrollYMirror
	LDA ScreenYLo
	SEC
	SBC #$04
	STA ScreenYLo
	BCS loc_BANK0_80C8

	DEC ScreenYHi

loc_BANK0_80C8:
	LDA PPUScrollYMirror
	CMP #$0FC
	BNE loc_BANK0_80DB

	LDA #$EC
	STA PPUScrollYMirror
	LDA PPUScrollYHiMirror
	EOR #$02
	STA PPUScrollYHiMirror
	LSR A
	STA PPUScrollXHiMirror

loc_BANK0_80DB:
	LDA PPUScrollYMirror
	AND #$07
	BEQ loc_BANK0_80E2

	RTS

; ---------------------------------------------------------------------------

loc_BANK0_80E2:
	LDX #$00
	JSR loc_BANK0_8287

	INX
	JSR loc_BANK0_8287

	LDA PPUScrollYMirror
	AND #$0F
	BNE loc_BANK0_80FB

	LDX #$00
	JSR DecrementVerticalScrollRow

	LDX #$01
	JSR DecrementVerticalScrollRow

loc_BANK0_80FB:
	LDX #$01
	JSR PrepareBackgroundDrawing_Vertical

	JMP loc_BANK0_8170

; ---------------------------------------------------------------------------

loc_BANK0_8103:
	BNE loc_BANK0_8121

	LDA CurrentLevelPages
	STA byte_RAM_F
	CMP #$09
	BNE loc_BANK0_8114

	LDA #$00
	STA byte_RAM_F
	BEQ loc_BANK0_8116

loc_BANK0_8114:
	INC byte_RAM_F

loc_BANK0_8116:
	LDA BackgroundUpdateBoundaryForward
	AND #$0F
	CMP byte_RAM_F
	BNE loc_BANK0_8121

	JMP loc_BANK0_819C

; ---------------------------------------------------------------------------

loc_BANK0_8121:
	LDA #$01
	JSR SetObjectLocks

	LDA PPUScrollYMirror
	CLC
	ADC #$04
	STA PPUScrollYMirror
	LDA ScreenYLo
	CLC
	ADC #$04
	STA ScreenYLo
	BCC loc_BANK0_8138

	INC ScreenYHi

loc_BANK0_8138:
	LDA PPUScrollYMirror
	AND #$07
	BEQ loc_BANK0_813F

	RTS

; ---------------------------------------------------------------------------

loc_BANK0_813F:
	LDA PPUScrollYMirror
	CMP #$F0
	BNE loc_BANK0_8152

	LDA #$00
	STA PPUScrollYMirror
	LDA PPUScrollYHiMirror
	EOR #$02
	STA PPUScrollYHiMirror
	LSR A
	STA PPUScrollXHiMirror

loc_BANK0_8152:
	LDX #$02
	JSR sub_BANK0_828F

	DEX
	JSR sub_BANK0_828F

	LDA DrawBackgroundTilesPPUAddrLoForward
	AND #$20
	BNE loc_BANK0_816B

	LDX #$02
	JSR IncrementVerticalScrollRow

	LDX #$01
	JSR IncrementVerticalScrollRow

loc_BANK0_816B:
	LDX #$02
	JSR PrepareBackgroundDrawing_Vertical

loc_BANK0_8170:
	LDA CameraScrollTiles
	CMP #$12
	BNE loc_BANK0_818F

	LDA #$01
	STA byte_RAM_E4
	LDA NeedsScroll
	LSR A
	BCC loc_BANK0_8186

; up
	LDX #$01
	LDA #$00
	BEQ loc_BANK0_818A

; down
loc_BANK0_8186:
	LDX #$02
	LDA #$10

loc_BANK0_818A:
	STA byte_RAM_1
	JSR sub_BANK0_8314

loc_BANK0_818F:
	; Update PPU for scrolling
	JSR CopyBackgroundToPPUBuffer_Vertical

	DEC CameraScrollTiles
	BNE locret_BANK0_81A0

	LDA #$00
	JSR SetObjectLocks

loc_BANK0_819C:
	LDA #$00
	STA NeedsScroll

locret_BANK0_81A0:
	RTS


; ---------------------------------------------------------------------------
	.db $01


;
; Stashes screen scrolling information so that it can be restored after leaving
; the pause screen
;
StashScreenScrollPosition:
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
	LDA #$00
	STA PPUScrollYMirror
	STA PPUScrollXMirror
	STA PPUScrollYHiMirror
	STA PPUScrollXHiMirror
	RTS


RestoreScreenScrollPosition:
	LDA PPUScrollYMirror_Backup
	STA PPUScrollYMirror
	LDA PPUScrollXMirror_Backup
	STA PPUScrollXMirror
	STA ScreenBoundaryLeftLo
	LDA PPUScrollYHiMirror_Backup
	STA PPUScrollYHiMirror
	LDA PPUScrollXHiMirror_Backup
	STA PPUScrollXHiMirror
	LDA ScreenBoundaryLeftHi_Backup
	STA ScreenBoundaryLeftHi
	LDA ScreenYHi_Backup
	STA ScreenYHi
	LDA ScreenYLo_Backup
	STA ScreenYLo
	RTS


; Used for redrawing the screen in a vertical area after unpausing
sub_BANK0_81FE:
	LDA BackgroundUpdateBoundaryBackward
	AND #$10
	BEQ loc_BANK0_820B

	LDA byte_RAM_E1
	SEC
	SBC #$08
	STA byte_RAM_E1

loc_BANK0_820B:
	LDA #$01
	STA byte_RAM_E4
	LDA BackgroundUpdateBoundaryBackward
	STA BackgroundUpdateBoundary
	LDA #$10
	STA byte_RAM_1
	LDX #$00
	JSR sub_BANK0_8314

	LDA DrawBackgroundTilesPPUAddrLoBackward
	STA DrawBackgroundTilesPPUAddrLo
	LDA byte_RAM_E1
	STA byte_RAM_E2
	LDX #$01
	JSR sub_BANK0_846A

	LDA #$F0
	STA PPUScrollCheckHi
	STA PPUScrollCheckLo
	LDA BackgroundUpdateBoundaryForward
	STA byte_RAM_505
	INC byte_RAM_D5
	LDA #$01
	STA byte_RAM_6
	RTS


; Used for redrawing the background tiles in a vertical area
sub_BANK0_823D:
	; Clear the flag to indicate that we're drawing
	LDX #$00
	STX byte_RAM_537

	JSR PrepareBackgroundDrawing_Vertical

	; Update PPU for area init
	JSR CopyBackgroundToPPUBuffer_Vertical

	LDX #$00
	JSR sub_BANK0_828F

	LDA PPUScrollCheckHi
	CMP DrawBackgroundTilesPPUAddrHi
	BNE loc_BANK0_8277

	LDA PPUScrollCheckLo
	CLC
	ADC #$20
	CMP DrawBackgroundTilesPPUAddrLo
	BNE loc_BANK0_8277

loc_BANK0_825E:
	LDA byte_RAM_6
	TAX
	BEQ loc_BANK0_8268

	LDA byte_RAM_517
	STA byte_RAM_E1

loc_BANK0_8268:
	; Set the flag to indicate that we've finished drawing
	INC byte_RAM_537

	LDA #$00
	STA byte_RAM_53A, X
	STA byte_RAM_53D
	STA byte_RAM_53E

	RTS

; ---------------------------------------------------------------------------

loc_BANK0_8277:
	LDA DrawBackgroundTilesPPUAddrLo
	AND #$20
	BNE locret_BANK0_828E

	LDA BackgroundUpdateBoundary
	CMP byte_RAM_505
	BEQ loc_BANK0_825E

	JMP IncrementVerticalScrollRow

; ---------------------------------------------------------------------------

; Decrement tiles row
loc_BANK0_8287:
	LDA DrawBackgroundTilesPPUAddrLoBackward, X
	SEC
	SBC #$20
	STA DrawBackgroundTilesPPUAddrLoBackward, X

locret_BANK0_828E:
	RTS


; Increment tiles row
sub_BANK0_828F:
	LDA DrawBackgroundTilesPPUAddrLo, X
	CLC
	ADC #$20
	STA DrawBackgroundTilesPPUAddrLo, X
	RTS


;
; Decrement the drawing boundary table entry by one row of tiles
;
DecrementVerticalScrollRow:
	; Decrement the row offset
	LDA BackgroundUpdateBoundaryBackward, X
	SEC
	SBC #$10
	STA BackgroundUpdateBoundaryBackward, X
	AND #$F0
	CMP #$F0
	BNE DecrementVerticalScrollRow_Exit

	; Decrement the page
	LDA BackgroundUpdateBoundaryBackward, X
	AND #$0F
	CLC
	ADC #$E0
	STA BackgroundUpdateBoundaryBackward, X
	DEC BackgroundUpdateBoundaryBackward, X
	LDA BackgroundUpdateBoundaryBackward, X
	CMP #$DF
	BNE loc_BANK0_82B9

	; Wrap around to the last row of the last page
	LDA #$E9
	STA BackgroundUpdateBoundaryBackward, X

; @TODO: What's this doing, exactly?
loc_BANK0_82B9:
	LDA #$A0
	STA DrawBackgroundTilesPPUAddrLoBackward, X

DecrementVerticalScrollRow_Exit:
	RTS


;
; Increment the drawing boundary table entry by one column of tiles
;
IncrementVerticalScrollRow:
	; Increment the row offset
	LDA BackgroundUpdateBoundary, X
	CLC
	ADC #$10
	STA BackgroundUpdateBoundary, X
	AND #$F0
	CMP #$F0
	BNE IncrementVerticalScrollRow_Exit

	; Increment the page
	LDA BackgroundUpdateBoundary, X
	AND #$0F
	STA BackgroundUpdateBoundary, X
	INC BackgroundUpdateBoundary, X
	LDA BackgroundUpdateBoundary, X
	CMP #$0A
	BNE loc_BANK0_82DD

	; Wrap around to the first row of the first page
	LDA #$00
	STA BackgroundUpdateBoundary, X

; @TODO: What's this doing, exactly?
loc_BANK0_82DD:
	LDA #$00
	STA DrawBackgroundTilesPPUAddrLo, X

IncrementVerticalScrollRow_Exit:
	RTS


;
; Determines which background tiles from the decoded level data to draw to the
; screen and where to draw them for vertical areas.
;
; ##### Input
; - `BackgroundUpdateBoundary`: drawing boundary table
; - `X`: drawing boundary index (`$00` = full, `$01` = up, `$02` = down)
;
; ##### Output
; - `ReadLevelDataAddress`: decoded level data address
; - `ReadLevelDataOffset`: level data offset
; - `DrawBackgroundTilesPPUAddrHi`/`DrawBackgroundTilesPPUAddrLo`: PPU start address
;
PrepareBackgroundDrawing_Vertical:
	; Lower nybble is used for page
	LDA BackgroundUpdateBoundary, X
	AND #$0F
	TAY
	; Get the address of the decoded level data
	LDA DecodedLevelPageStartLo_Bank1, Y
	STA ReadLevelDataAddress
	LDA DecodedLevelPageStartHi_Bank1, Y
	STA ReadLevelDataAddress + 1

	; Upper nybble is used for the tile offset (rows)
	LDA BackgroundUpdateBoundary, X
	AND #$F0
	STA ReadLevelDataOffset

	; Determine where on the screen we should draw the tile
	LDA BackgroundUpdateBoundary, X
	LSR A
	BCC PrepareBackgroundDrawing_Vertical_Nametable2800

	LDA #$20
	BNE PrepareBackgroundDrawing_Vertical_SetNametableHi

PrepareBackgroundDrawing_Vertical_Nametable2800:
	LDA #$28

PrepareBackgroundDrawing_Vertical_SetNametableHi:
	STA DrawBackgroundTilesPPUAddrHi

	LDA BackgroundUpdateBoundary, X
	AND #$C0
	ASL A
	ROL A
	ROL A
	ADC DrawBackgroundTilesPPUAddrHi
	STA DrawBackgroundTilesPPUAddrHi

	LDA DrawBackgroundTilesPPUAddrLo, X
	STA DrawBackgroundTilesPPUAddrLo

PrepareBackgroundDrawing_Vertical_Exit:
	RTS


;
; =============== S U B R O U T I N E =======================================
;
sub_BANK0_8314:
	LDA BackgroundUpdateBoundary, X
	AND #$10
	BEQ PrepareBackgroundDrawing_Vertical_Exit

	LDA BackgroundUpdateBoundary, X
	STA byte_RAM_3
	SEC
	SBC byte_RAM_1
	STA BackgroundUpdateBoundary, X
	JSR PrepareBackgroundDrawing_Vertical

; loop through tiles to generate PPU attribute data
loc_BANK0_8326:
	LDA #$0F
	STA PPUAttributeUpdateCounter
	LDA #$00
	STA CopyBackgroundCounter

loc_BANK0_832E:
	JSR ReadNextTileAndSetPaletteInPPUAttribute

	LDA PPUAttributeUpdateCounter
	BPL loc_BANK0_832E

	LDA byte_RAM_3
	STA BackgroundUpdateBoundary, X
	DEC byte_RAM_E4
	JMP PrepareBackgroundDrawing_Vertical


;
; This draws ground tiles to the PPU buffer
;
; ##### Input
; - `byte_RAM_300`: offset in PPU buffer
; - `DrawBackgroundTilesPPUAddrHi`/`DrawBackgroundTilesPPUAddrLo`: PPU start address
; - `ReadLevelDataAddress`: decoded level data address
; - `ReadLevelDataOffset`: level data offset
;
CopyBackgroundToPPUBuffer_Vertical:
	; Set the PPU start address (ie. where we're going to draw tiles)
	LDX byte_RAM_300
	LDA DrawBackgroundTilesPPUAddrHi
	STA PPUBuffer_301, X
	INX
	LDA DrawBackgroundTilesPPUAddrLo
	STA PPUBuffer_301, X
	INX

	; We're going to draw a full row of tiles on the screen
	LDA #$20
	STA PPUBuffer_301, X

	; Prepare the counters
	INX
	LDA #$00
	STA CopyBackgroundCounter
	LDA #$0F
	STA PPUAttributeUpdateCounter

	LDA byte_RAM_D5
	BEQ CopyBackgroundToPPUBuffer_Vertical_Loop

	LDY ReadLevelDataOffset
	CPY #$E0
	BNE CopyBackgroundToPPUBuffer_Vertical_Loop

	LDA #$00
	STA byte_RAM_E4
	INC UpdatingPPUAttributeBottomRow

CopyBackgroundToPPUBuffer_Vertical_Loop:
	LDY ReadLevelDataOffset
	LDA (ReadLevelDataAddress), Y
IFDEF CUSTOM_TILE_IDS
	.include "src/extras/level_gen/custom-tile-id.asm"
	JMP ++ ;; leaves to flag outside...
	+
ENDIF
IFDEF DRAW_SECRET
	JSR DetectSecret
ENDIF
IFDEF CUSTOM_LEVEL_RLE
	JSR DetectLocked
ENDIF
	STA DrawTileId
	AND #%11000000
	ASL A
	ROL A
	ROL A
	TAY
	; Get the tile quad pointer
	LDA TileQuadPointersLo, Y
	STA byte_RAM_0
	LDA TileQuadPointersHi, Y
	STA byte_RAM_1
IFNDEF CUSTOM_LEVEL_RLE
	LDY ReadLevelDataOffset
	LDA (ReadLevelDataAddress), Y
ENDIF
IFDEF CUSTOM_LEVEL_RLE
	LDA DrawTileId
ENDIF

	ASL A
	ASL A
	TAY
	++
	LDA byte_RAM_D5
	BEQ loc_BANK0_8390

	INY
	INY

loc_BANK0_8390:
	; Write the tile to the PPU buffer
	LDA (byte_RAM_0), Y
	STA PPUBuffer_301, X
	INC CopyBackgroundCounter
	INX
	INY
	LDA CopyBackgroundCounter
	LSR A
	BCS loc_BANK0_8390

	INC ReadLevelDataOffset
	LDA byte_RAM_D5
	BEQ loc_BANK0_83A7

	JSR SetTilePaletteInPPUAttribute

loc_BANK0_83A7:
	; Did we finish drawing the row yet?
	LDA CopyBackgroundCounter
	CMP #$20
	BCC CopyBackgroundToPPUBuffer_Vertical_Loop

	LDA #$00
	STA PPUBuffer_301, X
	STX byte_RAM_300
	LDA byte_RAM_D5
	BEQ loc_BANK0_840B

	LDA byte_RAM_E4
	BEQ loc_BANK0_83C2

	DEC byte_RAM_E4
	JMP loc_BANK0_83DE

; ---------------------------------------------------------------------------

loc_BANK0_83C2:
	LDA NeedsScroll
	LSR A
	BCS loc_BANK0_83D4

; down
	LDX #$01
	JSR CopyBackgroundAttributesToPPUBuffer_Vertical

	LDX #$01
	JSR sub_BANK0_846A

	JMP loc_BANK0_83DE

; up
loc_BANK0_83D4:
	LDX #$00
	JSR CopyBackgroundAttributesToPPUBuffer_Vertical

	LDX #$00
	JSR sub_BANK0_8478

loc_BANK0_83DE:
	LDX #$00
	LDA NeedsScroll
	LSR A
	BCC loc_BANK0_83FA

; up
	INX
	LDA BackgroundUpdateBoundaryBackward, X
	AND #$F0
	CMP #$E0
	BEQ loc_BANK0_83F4

	LDA BackgroundUpdateBoundaryBackward, X
	AND #$10
	BNE loc_BANK0_840B

loc_BANK0_83F4:
	JSR sub_BANK0_8478

	JMP loc_BANK0_840B

; down
loc_BANK0_83FA:
	LDA BackgroundUpdateBoundaryBackward, X
	AND #$F0
	CMP #$E0
	BEQ loc_BANK0_8408

	LDA BackgroundUpdateBoundaryBackward, X
	AND #$10
	BEQ loc_BANK0_840B

loc_BANK0_8408:
	JSR sub_BANK0_846A

loc_BANK0_840B:
	LDA byte_RAM_D5
	EOR #$01
	STA byte_RAM_D5
	RTS


;
; This draws ground background attributes to the PPU buffer
;
CopyBackgroundAttributesToPPUBuffer_Vertical:
	LDY byte_RAM_300
	; Setting the attribute address to update
	LDA DrawBackgroundTilesPPUAddrHi
	ORA #$03
	STA PPUBuffer_301, Y
	INY
	LDA byte_RAM_E1, X
	STA PPUBuffer_301, Y
	INY
	; We're updating 8 blocks of attribute data
	LDA #$08
	STA PPUBuffer_301, Y
	INY

	LDX #$07
CopyBackgroundAttributesToPPUBuffer_Vertical_Loop:
	LDA UpdatingPPUAttributeBottomRow
	BEQ CopyBackgroundAttributesToPPUBuffer_Vertical_FullRow

CopyBackgroundAttributesToPPUBuffer_Vertical_HalfRow:
	; Bottom row of PPU attributes has half-sized blocks
  ; Shift background palettes down one quad
	LDA ScrollingPPUAttributeUpdateBuffer, X
	LSR A
	LSR A
	LSR A
	LSR A
	STA ScrollingPPUAttributeUpdateBuffer, X
	JMP CopyBackgroundAttributesToPPUBuffer_Vertical_Next

CopyBackgroundAttributesToPPUBuffer_Vertical_FullRow:
	LDA NeedsScroll
	LSR A
	BCC CopyBackgroundAttributesToPPUBuffer_Vertical_Next

CopyBackgroundAttributesToPPUBuffer_Vertical_Reverse:
	; Swap palettes for upper and lower background quads, since tiles are drawn
	; in the reverse order when scrolling up
	LDA ScrollingPPUAttributeUpdateBuffer, X
	ASL A
	ASL A
	ASL A
	ASL A
	STA byte_RAM_1
	LDA ScrollingPPUAttributeUpdateBuffer, X
	LSR A
	LSR A
	LSR A
	LSR A
	ORA byte_RAM_1
	STA ScrollingPPUAttributeUpdateBuffer, X

CopyBackgroundAttributesToPPUBuffer_Vertical_Next:
	LDA ScrollingPPUAttributeUpdateBuffer, X
	STA PPUBuffer_301, Y
	INY
	DEX
	BPL CopyBackgroundAttributesToPPUBuffer_Vertical_Loop

	LDA #$01
	STA byte_RAM_E4
	LSR A
	STA UpdatingPPUAttributeBottomRow
	STA PPUBuffer_301, Y
	STY byte_RAM_300
	RTS


; Increment attributes row
sub_BANK0_846A:
	LDA byte_RAM_E1, X
	CLC
	ADC #$08
	STA byte_RAM_E1, X
	BCC locret_BANK0_8477

	LDA #$C0
	STA byte_RAM_E1, X

locret_BANK0_8477:
	RTS


; Decrement attributes row
sub_BANK0_8478:
	LDA byte_RAM_E1, X
	SEC
	SBC #$08
	STA byte_RAM_E1, X
	CMP #$C0
	BCS locret_BANK0_8487

	LDA #$F8
	STA byte_RAM_E1, X

locret_BANK0_8487:
	RTS


;
; Sets the palette for the tile in the current PPU attribute block.
; We effectively write these two bits at a time, since each attribute block
; contains four background tiles.
;
; This subroutine is only used in vertical areas.
;
; ##### Input
; - `DrawTileId`: tile ID to use for the palette
; - `PPUAttributeUpdateCounter`: determines index to update in buffer
;
SetTilePaletteInPPUAttribute:
	LDA PPUAttributeUpdateCounter
	LSR A
	TAY
	; Shift two bits to the right to make room for the next tile
	LDA ScrollingPPUAttributeUpdateBuffer, Y
	LSR A
	LSR A
	STA ScrollingPPUAttributeUpdateBuffer, Y
	; Load the color for the next tile and apply it to the attribute value
	LDA DrawTileId
	AND #%11000000
	ORA ScrollingPPUAttributeUpdateBuffer, Y
	STA ScrollingPPUAttributeUpdateBuffer, Y

	; Move on to the next block
	DEC PPUAttributeUpdateCounter
	RTS


; Unused?
_code_04A2:
	LDX #$07
	LDA #$00

; Unused?
loc_BANK0_84A6:
	STA ScrollingPPUAttributeUpdateBuffer, X
	DEX
	BNE loc_BANK0_84A6

	RTS


;
; Loads a background tile from the level data and determines its PPU attribute data
;
; ##### Input
; - `ReadLevelDataAddress`: decoded level data address
;
; ##### Output
; - `DrawTileId` - tile ID
;
ReadNextTileAndSetPaletteInPPUAttribute:
sub_BANK0_84AC:
	LDY ReadLevelDataOffset
	LDA (ReadLevelDataAddress), Y
	STA DrawTileId
	INC ReadLevelDataOffset
	JMP SetTilePaletteInPPUAttribute


IFNDEF CUSTOM_UNUSED
; Unused space in the original ($84B8 - $84FF)
unusedSpace $8500, $FF
ENDIF


;
; Initializes a horizontal area
;
InitializeAreaHorizontal:
	LDA byte_RAM_502
	BNE loc_BANK0_855C

	LDA #VMirror
	JSR ChangeNametableMirroring

	JSR ApplyAreaTransition

	LDA #$00
	STA PPUScrollYMirror

	LDA CurrentLevelEntryPage
	BNE loc_BANK0_851A

	LDA #$09
	BNE loc_BANK0_851D

loc_BANK0_851A:
	SEC
	SBC #$01

loc_BANK0_851D:
	ORA #$D0
	STA BackgroundUpdateBoundaryBackward
	SEC
	SBC #$20
	STA BackgroundUpdateBoundary
	LDA CurrentLevelEntryPage
	CLC
	ADC #$01
	CMP #$0A
	BNE loc_BANK0_8532

	LDA #$00

loc_BANK0_8532:
	ORA #$10
	STA BackgroundUpdateBoundaryForward
	LDA CurrentLevelEntryPage
	LDY #$01
	JSR ResetPPUScrollHi

	; Set the flag for the initial screen render
	INC byte_RAM_502

	; Set the screen x-position
	LDA CurrentLevelEntryPage
	STA ScreenBoundaryLeftHi

	; Initialize the PPU update boundary
	LDA #$01
	STA byte_RAM_53A
	LSR A
	STA byte_RAM_6
	LDA #$FF
	STA byte_RAM_505
	LDA #$0F
	STA PPUScrollCheckLo

	JSR sub_BANK0_856A

loc_BANK0_855C:
	JSR sub_BANK0_87AA

	LDA byte_RAM_53A
	BNE InitializeAreaHorizontal_Exit

	STA byte_RAM_502
	INC BreakStartLevelLoop

InitializeAreaHorizontal_Exit:
	RTS


; =============== S U B R O U T I N E =======================================

sub_BANK0_856A:
	LDA CurrentLevelEntryPage
	BNE loc_BANK0_8576

	LDA MoveCameraX
	BMI loc_BANK0_85E7

	LDA CurrentLevelEntryPage

loc_BANK0_8576:
	CMP CurrentLevelPages
	BNE loc_BANK0_857F

	LDA MoveCameraX
	BPL loc_BANK0_85E7

loc_BANK0_857F:
	LDX #$02
	LDA MoveCameraX
	BPL loc_BANK0_858B

	LDA #$FF
	STA byte_RAM_B
	BNE loc_BANK0_858F

loc_BANK0_858B:
	LDA #$00
	STA byte_RAM_B

loc_BANK0_858F:
	LDA MoveCameraX
	AND #$F0
	CLC
	ADC BackgroundUpdateBoundary, X
	PHP
	ADC byte_RAM_B
	PLP
	STA byte_RAM_C
	LDA byte_RAM_B
	BNE loc_BANK0_85B1

	BCC loc_BANK0_85C2

	LDA BackgroundUpdateBoundary, X
	AND #$0F
	CMP #$09
	BNE loc_BANK0_85C2

	LDA byte_RAM_C
	AND #$F0
	JMP loc_BANK0_85C4

; ---------------------------------------------------------------------------

loc_BANK0_85B1:
	BCS loc_BANK0_85C2

	LDA BackgroundUpdateBoundary, X
	AND #$0F
	BNE loc_BANK0_85C2

	LDA byte_RAM_C
	AND #$F0
	ADC #$09
	JMP loc_BANK0_85C4

; ---------------------------------------------------------------------------

loc_BANK0_85C2:
	LDA byte_RAM_C

loc_BANK0_85C4:
	STA BackgroundUpdateBoundary, X
	DEX
	BPL loc_BANK0_858F

	LDA MoveCameraX
	STA PPUScrollXMirror
	STA ScreenBoundaryLeftLo
	AND #$F0
	STA CurrentLevelPageX
	LDA MoveCameraX
	BPL loc_BANK0_85E7

	DEC ScreenBoundaryLeftHi
	LDA PPUScrollXHiMirror
	EOR #$01
	STA PPUScrollXHiMirror
	LDA #$01
	STA PPUScrollCheckLo

loc_BANK0_85E7:
	LDA #$00
	STA MoveCameraX
	RTS

; End of function sub_BANK0_856A


;
; Applies horizontal screen scrolling.
;
; Unlike vertical scrolling, horizontal scrolling can happen continuously as
; the player moves left and right.
;
;
;
ApplyHorizontalScroll:
	; Reset the PPU tile update flag
	LDA #$00
	STA HasScrollingPPUTilesUpdate

	; Are we scrolling in more tiles?
	LDA HorizontalScrollDirection
	BEQ ApplyHorizontalScroll_CheckMoveCameraX

	; Which direction?
	LDA HorizontalScrollDirection
	LSR A
	BCS ApplyHorizontalScroll_Left

ApplyHorizontalScroll_Right:
	LDX #$02
	STX byte_RAM_9
	LDA #$10
	STA byte_RAM_1
	DEX
	LDA HorizontalScrollDirection
	STA NeedsScroll
	JSR CopyAttributesToHorizontalBuffer

	LDA byte_RAM_3
	STA BackgroundUpdateBoundaryForward
	LDA #$00
	STA HorizontalScrollDirection
	BEQ ApplyHorizontalScroll_CheckMoveCameraX

ApplyHorizontalScroll_Left:
	LDX #$01
	STX byte_RAM_9
	DEX
	STX byte_RAM_1
	LDA HorizontalScrollDirection
	STA NeedsScroll
	JSR CopyAttributesToHorizontalBuffer

	LDA #$00
	STA HorizontalScrollDirection

ApplyHorizontalScroll_CheckMoveCameraX:
	LDA MoveCameraX
	BNE ApplyMoveCameraX

	RTS


ApplyMoveCameraX:
	LDA MoveCameraX
	BPL ApplyMoveCameraX_Right

ApplyMoveCameraX_ScrollLeft:
	LDA #$01
	STA NeedsScroll

	; Weird `JMP`, but okay...
	JMP ApplyMoveCameraX_Left

ApplyMoveCameraX_Right:
	LDA #$02
	STA NeedsScroll

	LDX MoveCameraX
ApplyMoveCameraX_Right_Loop:
	LDA PPUScrollXMirror
	BNE loc_BANK0_8651

	LDA ScreenBoundaryLeftHi
	CMP CurrentLevelPages
	BNE loc_BANK0_8651

	; Can't scroll past beyond the last page of the area
	JMP ApplyMoveCameraX_Exit

; Scrolling one pixel at a time in a tight loop seems crazy at first, but in
; practice it only ends up being like 3 iterations at most.
ApplyMoveCameraX_Right_AddPixel:
loc_BANK0_8651:
	LDA PPUScrollXMirror
	CLC
	ADC #$01
	STA PPUScrollXMirror
	STA ScreenBoundaryLeftLo
	BCC loc_BANK0_8669

	INC ScreenBoundaryLeftHi
	LDA PPUScrollXHiMirror
	EOR #$01
	STA PPUScrollXHiMirror
	ASL A
	STA PPUScrollYHiMirror

loc_BANK0_8669:
	LDA ScreenBoundaryLeftHi
	CMP CurrentLevelPages
	BEQ loc_BANK0_8685

	LDA PPUScrollXMirror
	AND #$F0
	CMP CurrentLevelPageX
	BEQ ApplyMoveCameraX_Right_Next

	STA CurrentLevelPageX
	LDA #$01
	STA HasScrollingPPUTilesUpdate

ApplyMoveCameraX_Right_Next:
	DEX
	BNE ApplyMoveCameraX_Right_Loop

loc_BANK0_8685:
	LDA HasScrollingPPUTilesUpdate
	BEQ ApplyMoveCameraX_Exit

	LDX #$02
loc_BANK0_868C:
	JSR IncrementHorizontalScrollColumn

	DEX
	BNE loc_BANK0_868C

	LDX #$02
	JSR PrepareBackgroundDrawing_Horizontal

	JMP loc_BANK0_86E6


ApplyMoveCameraX_Left:
	LDX MoveCameraX
ApplyMoveCameraX_Left_Loop:
	LDA PPUScrollXMirror
	BNE loc_BANK0_86A8

	LDA ScreenBoundaryLeftHi
	BNE loc_BANK0_86A8

	; Can't scroll past beyond the first page of the area
	JMP ApplyMoveCameraX_Exit

loc_BANK0_86A8:
	LDA PPUScrollXMirror
	SEC
	SBC #$01
	STA PPUScrollXMirror
	STA ScreenBoundaryLeftLo
	BCS loc_BANK0_86C0

	DEC ScreenBoundaryLeftHi
	LDA PPUScrollXHiMirror
	EOR #$01
	STA PPUScrollXHiMirror
	ASL A
	STA PPUScrollYHiMirror

loc_BANK0_86C0:
	LDA PPUScrollXMirror
	AND #$F0
	CMP CurrentLevelPageX
	BEQ loc_BANK0_86D1

	STA CurrentLevelPageX
	LDA #$01
	STA HasScrollingPPUTilesUpdate

loc_BANK0_86D1:
	INX
	BNE ApplyMoveCameraX_Left_Loop

	LDA HasScrollingPPUTilesUpdate
	BEQ ApplyMoveCameraX_Exit

	LDX #$02
loc_BANK0_86DB:
	JSR DecrementHorizontalScrollColumn

	DEX
	BNE loc_BANK0_86DB

	LDX #$01
	JSR PrepareBackgroundDrawing_Horizontal

loc_BANK0_86E6:
	JSR CopyBackgroundToPPUBuffer_Horizontal

ApplyMoveCameraX_Exit:
	LDA #$00
	STA NeedsScroll
	RTS


;
; Resets the PPU high scrolling values and sets the high byte of the PPU scroll offset.
;
; ##### Input
; - `A`: 0 = use nametable A, 1 = use nametable B
; - `Y`: 0 = vertical, 1 = horizontal
;
; ##### Output
; - `PPUScrollYHiMirror`
; - `PPUScrollXHiMirror`
; - `PPUScrollCheckHi`: PPU scroll offset high byte
;
ResetPPUScrollHi:
	LSR A
	BCS ResetPPUScrollHi_NametableB

ResetPPUScrollHi_NametableA:
	LDA #$01
	STA PPUScrollXHiMirror
	ASL A
	STA PPUScrollYHiMirror
	LDA #$20
	BNE ResetPPUScrollHi_Exit

ResetPPUScrollHi_NametableB:
	LDA #$00
	STA PPUScrollXHiMirror
	STA PPUScrollYHiMirror
	LDA PPUScrollHiOffsets, Y

ResetPPUScrollHi_Exit:
	STA PPUScrollCheckHi
	RTS


;
; High byte of the PPU scroll offset for nametable B.
;
; When mirroring vertically, nametable A is `$2000` and nametable B is `$2800`.
; When mirroring horizontally, nametable A is `$2000` and nametable B is `$2400`.
;
PPUScrollHiOffsets:
	.db $28 ; vertical
	.db $24 ; horizontal


; The sub-area "page" is the index in the DecodedLevelPageStart table.
; This is why there are 10 blank pages in the jar enemy data.
SubAreaPage:
	.db $0A


; Stash the PPU scrolling data from the main area and rest it for the subarea
UseSubareaScreenBoundaries:
	LDA PPUScrollXMirror
	STA PPUScrollXMirror_Backup
	LDA PPUScrollXHiMirror
	STA PPUScrollXHiMirror_Backup
IFDEF TEST_FLAG_VERT_SUB
	LDA PPUScrollYMirror
	STA PPUScrollYMirror_Backup
	LDA PPUScrollYHiMirror
	STA PPUScrollYHiMirror_Backup
	LDA #0
	STA PPUScrollYMirror
	STA PPUScrollYHiMirror
ENDIF
	LDA ScreenBoundaryLeftHi
	STA ScreenBoundaryLeftHi_Backup
	INC byte_RAM_53D
	LDA SubAreaPage
	STA CurrentLevelEntryPage
	JSR ResetPPUScrollHi

	LDA #$00
	STA PPUScrollXMirror
	STA ScreenBoundaryLeftLo
	LDA SubAreaPage
	STA ScreenBoundaryLeftHi

	JSR ApplyAreaTransition

	LDA SubAreaPage
	STA BackgroundUpdateBoundary
	LDA #$E0
	STA PPUScrollCheckHi
	LDA SubAreaPage
	CLC
	ADC #$F0
	STA byte_RAM_505
	RTS


; Restore the PPU scrolling data for the main area
UseMainAreaScreenBoundaries:
	LDA PPUScrollXMirror_Backup
	STA PPUScrollXMirror
	STA ScreenBoundaryLeftLo
	LDA PPUScrollXHiMirror_Backup
	STA PPUScrollXHiMirror
	LDA ScreenBoundaryLeftHi_Backup
	STA ScreenBoundaryLeftHi
	LDA byte_RAM_53D
	BNE UseMainAreaScreenBoundaries_Exit

	INC byte_RAM_53E
	INC byte_RAM_53D
	INC byte_RAM_D5
	JSR RestorePlayerPosition

	LDA BackgroundUpdateBoundaryBackward
	STA BackgroundUpdateBoundary
	LDA #$10
	STA byte_RAM_1
	LDA #$F0
	STA PPUScrollCheckHi
	STA PPUScrollCheckLo
	LDA BackgroundUpdateBoundaryForward
	STA byte_RAM_505

UseMainAreaScreenBoundaries_Exit:
	RTS


; Used for redrawing the screen in a horizontal area after unpausing
sub_BANK0_8785:
	LDA BackgroundUpdateBoundaryBackward
	STA BackgroundUpdateBoundary
	LDA #$10
	STA byte_RAM_1
	LDA #$F0
	STA PPUScrollCheckHi
	STA PPUScrollCheckLo
	LDA BackgroundUpdateBoundaryForward
	CLC
	ADC #$10
	ADC #$00
	CMP #$0A
	BNE loc_BANK0_87A2

	LDA #$00

loc_BANK0_87A2:
	STA byte_RAM_505
	LDA #$01
	STA byte_RAM_6
	RTS

; Used for redrawing the background tiles in a horizontal area
sub_BANK0_87AA:
	LDX #$00
	STX byte_RAM_537
	STX HasScrollingPPUTilesUpdate
	STX NeedsScroll

	JSR PrepareBackgroundDrawing_Horizontal

	JSR CopyBackgroundToPPUBuffer_Horizontal

	LDA PPUScrollCheckHi
	CMP DrawBackgroundTilesPPUAddrHi
	BNE loc_BANK0_87DA

	LDA PPUScrollCheckLo
	CLC
	ADC #$01
	CMP DrawBackgroundTilesPPUAddrLo
	BNE loc_BANK0_87DA

loc_BANK0_87CB:
	LDA #$00
	STA byte_RAM_53A
	STA byte_RAM_53D
	STA byte_RAM_53E
	INC byte_RAM_537
	RTS

; ---------------------------------------------------------------------------

loc_BANK0_87DA:
	LDA BackgroundUpdateBoundary
	CMP byte_RAM_505
	BEQ loc_BANK0_87CB

	LDX #$00
	JMP IncrementHorizontalScrollColumn

;
; Decrement the drawing boundary table entry by one column of tiles
;
DecrementHorizontalScrollColumn:
	; Decrement the column offset
	LDA BackgroundUpdateBoundary, X
	SEC
	SBC #$10
	STA BackgroundUpdateBoundary, X
	BCS DecrementHorizontalScrollColumn_Exit

	; Decrement the page
	DEC BackgroundUpdateBoundary, X
	LDA BackgroundUpdateBoundary, X
	CMP #$EF
	BNE DecrementHorizontalScrollColumn_Exit

	; Wrap around to the last column of the last page
	LDA #$F9
	STA BackgroundUpdateBoundary, X

DecrementHorizontalScrollColumn_Exit:
	RTS


;
; Increment the drawing boundary table entry by one column of tiles
;
IncrementHorizontalScrollColumn:
	; Increment the column offset
	LDA BackgroundUpdateBoundary, X
	CLC
	ADC #$10
	STA BackgroundUpdateBoundary, X
	BCC IncrementHorizontalScrollColumn_Exit

	; Increment the page
	INC BackgroundUpdateBoundary, X
	LDA BackgroundUpdateBoundary, X
	CMP #$0A
	BNE IncrementHorizontalScrollColumn_Exit

	; Wrap around to the first page
	LDA #$00
	STA BackgroundUpdateBoundary, X

IncrementHorizontalScrollColumn_Exit:
	RTS


;
; Determines which background tiles from the decoded level data to draw to the
; screen and where to draw them for horizontal areas.
;
; ##### Input
; - `BackgroundUpdateBoundary`: drawing boundary table
; - `X`: drawing boundary index (`$00` = full, `$01` = left, `$02` = right)
;
; ##### Output
; - `ReadLevelDataAddress`: decoded level data address
; - `ReadLevelDataOffset`: level data offset
; - `DrawBackgroundTilesPPUAddrHi`/`DrawBackgroundTilesPPUAddrLo`: PPU start address
;
PrepareBackgroundDrawing_Horizontal:
	; Stash Y so we can restore it later
	STY byte_RAM_F

	; Lower nybble is used for page
	LDA BackgroundUpdateBoundary, X
	AND #$0F
	TAY
	; Get the address of the decoded level data
	LDA DecodedLevelPageStartLo_Bank1, Y
	STA ReadLevelDataAddress
	LDA DecodedLevelPageStartHi_Bank1, Y
	STA ReadLevelDataAddress + 1

	; Upper nybble is used for the tile offset (columns)
	LDA BackgroundUpdateBoundary, X
	LSR A
	LSR A
	LSR A
	LSR A
	STA ReadLevelDataOffset

	; Determine where on the screen we should draw the tile
	ASL A
	STA DrawBackgroundTilesPPUAddrLo

	LDY #$20
	LDA BackgroundUpdateBoundary, X
	LSR A
	BCS PrepareBackgroundDrawing_Horizontal_Exit

	LDY #$24

PrepareBackgroundDrawing_Horizontal_Exit:
	STY DrawBackgroundTilesPPUAddrHi

	; Restore original Y value
	LDY byte_RAM_F

	RTS


;
; horizontal
;
sub_BANK0_883C:
	STX byte_RAM_8
	LDX byte_RAM_9
	LDY #$02
	LDA BackgroundUpdateBoundary, X
	STA byte_RAM_3
	SEC
	SBC byte_RAM_1
	STA BackgroundUpdateBoundary, X

	JSR PrepareBackgroundDrawing_Horizontal

	LDA #$07
	STA PPUAttributeUpdateCounter
	LDA #$00
	STA CopyBackgroundCounter

loc_BANK0_8856:
	JSR sub_BANK0_8925

	LDA PPUAttributeUpdateCounter
	BPL loc_BANK0_8856

	LDA DrawBackgroundTilesPPUAddrLo
	AND #$1C
	LSR A
	LSR A
	ORA #$C0
	STA DrawBackgroundAttributesPPUAddrLo
	LDA DrawBackgroundTilesPPUAddrHi
	ORA #$03
	STA DrawBackgroundAttributesPPUAddrHi
	LDX byte_RAM_8
	RTS

IFDEF DRAW_SECRET
	.include "src/extras/level_gen/secret-detection.asm"
ENDIF
IFDEF CUSTOM_LEVEL_RLE
	.include "src/extras/level_gen/locked-detection.asm"
ENDIF
;
; Draws the background data to the PPU buffer
;
CopyBackgroundToPPUBuffer_Horizontal:
	LDA #$0F
	STA PPUAttributeUpdateCounter

	LDA #$00
	STA CopyBackgroundCounter
	STA byte_RAM_D5
	TAX
CopyBackgroundToPPUBuffer_Horizontal_Loop:
	LDY ReadLevelDataOffset
	LDA (ReadLevelDataAddress), Y
IFDEF CUSTOM_TILE_IDS
	.include "src/extras/level_gen/custom-tile-id.asm"
	JMP ++ ;; leaves to flag outside...
	+
ENDIF
IFDEF DRAW_SECRET
	JSR DetectSecret
ENDIF
IFDEF CUSTOM_LEVEL_RLE
	JSR DetectLocked
ENDIF
	STA DrawTileId
	AND #%11000000
	ASL A
	ROL A
	ROL A
	TAY
	; Get the tile quad pointer
	LDA TileQuadPointersLo, Y
	STA byte_RAM_0
	LDA TileQuadPointersHi, Y
	STA byte_RAM_1

IFNDEF CUSTOM_LEVEL_RLE
	LDY ReadLevelDataOffset
	LDA (ReadLevelDataAddress), Y
ENDIF
IFDEF CUSTOM_LEVEL_RLE
	LDA DrawTileId
ENDIF
	ASL A
	ASL A
	TAY
	++
	LDA byte_RAM_D5
	BEQ loc_BANK0_88A0

	INY

loc_BANK0_88A0:
	LDA (byte_RAM_0), Y
	STA ScrollingPPUTileUpdateBuffer, X
	INY
	LDA (byte_RAM_0), Y
	STA unk_RAM_39E, X
	INY
	LDA (byte_RAM_0), Y
	STA unk_RAM_381, X
	INY
	LDA (byte_RAM_0), Y
	STA unk_RAM_39F, X
	INC CopyBackgroundCounter
	INX
	INX
	LDA ReadLevelDataOffset
	CLC
	ADC #$10
	STA ReadLevelDataOffset
	LDA CopyBackgroundCounter
	CMP #$0F
	BCC CopyBackgroundToPPUBuffer_Horizontal_Loop

	LDA #$00
	STA DrawBackgroundAttributesPPUAddrHi
	LDA NeedsScroll
	LSR A
	BCS loc_BANK0_88F2

; down
	LDA DrawBackgroundTilesPPUAddrLo
	AND #$02
	BEQ loc_BANK0_88FD

	LDA NeedsScroll
	BNE loc_BANK0_88F8

	LDA #$10
	STA byte_RAM_1
	LDX #$00
	STX byte_RAM_9
	INX
	JSR CopyAttributesToHorizontalBuffer

	LDA byte_RAM_3
	STA BackgroundUpdateBoundary
	JSR PrepareBackgroundDrawing_Horizontal

	JMP loc_BANK0_88FD

; up
loc_BANK0_88F2:
	LDA DrawBackgroundTilesPPUAddrLo
	AND #$02
	BNE loc_BANK0_88FD

loc_BANK0_88F8:
	LDA NeedsScroll
	STA HorizontalScrollDirection

loc_BANK0_88FD:
	INC HasScrollingPPUTilesUpdate
	RTS


;
; Does some kind of transformation to copy PPU attribute data from the common
; scrolling PPU update buffer to the horizontal-only buffer.
;
; I'm not totally sure why it is necessary to do this rather than writing the
; attribute data in the final order the first time?
;
; NOTE: There is code that assumes `X = $00` after running this subroutine!
;
CopyAttributesToHorizontalBuffer:
	JSR sub_BANK0_883C

	LDX #$07
	STX byte_RAM_E
	LDY #$00
CopyAttributesToHorizontalBuffer_Loop:
	LDX byte_RAM_E
	LDA ScrollingPPUAttributeUpdateBuffer, X
	STA HorizontalScrollingPPUAttributeUpdateBuffer, Y
	INY
	DEX
	DEX
	DEX
	DEX
	LDA ScrollingPPUAttributeUpdateBuffer, X
	STA HorizontalScrollingPPUAttributeUpdateBuffer, Y
	INY
	DEC byte_RAM_E
	LDA byte_RAM_E
	CMP #03
	BNE CopyAttributesToHorizontalBuffer_Loop

	RTS


;
; Determines the PPU attribute data for a group of four tiles in a horizontal area.
; Reads a group of four background tiles to determine the PPU attribute data
;
sub_BANK0_8925:
	STY byte_RAM_F
	LDA #01
	STA byte_RAM_4
	LDY ReadLevelDataOffset
	LDX PPUAttributeUpdateCounter

loc_BANK0_892F:
	LDA ScrollingPPUAttributeUpdateBuffer, X
	LSR A
	LSR A
	STA ScrollingPPUAttributeUpdateBuffer, X
	LDA (ReadLevelDataAddress), Y
	AND #%11000000
	ORA ScrollingPPUAttributeUpdateBuffer, X
	STA ScrollingPPUAttributeUpdateBuffer, X
	INY
	LDA ScrollingPPUAttributeUpdateBuffer, X
	LSR A
	LSR A
	STA ScrollingPPUAttributeUpdateBuffer, X
	LDA (ReadLevelDataAddress), Y
	AND #%11000000
	ORA ScrollingPPUAttributeUpdateBuffer, X
	STA ScrollingPPUAttributeUpdateBuffer, X
	LDA ReadLevelDataOffset
	CLC
	ADC #$10
	TAY
	STA ReadLevelDataOffset
	DEC byte_RAM_4
	BPL loc_BANK0_892F

	DEC PPUAttributeUpdateCounter
	LDY byte_RAM_F
	RTS


SetObjectLocks:
	LDX #$07

SetObjectLocks_Loop:
	STA ObjectLock - 1, X
	DEX
	BPL SetObjectLocks_Loop

	RTS



; Unused space in the original ($8966 - $89FF)
unusedSpace $8A00, $FF


GrowShrinkSFXIndexes:
	.db SoundEffect2_Shrinking
	.db SoundEffect2_Growing


HandlePlayerState:
IFDEF CONTROLLER_2_DEBUG
	JSR CheckPlayer2Joypad
ENDIF

	LDA PlayerState ; Handles player states?
	CMP #PlayerState_Lifting
	BCS loc_BANK0_8A26 ; If the player is changing size, just handle that

	LDA #$00 ; Check if the player needs to change size
	LDY #$10
	CPY PlayerHealth
	ROL A
	EOR PlayerCurrentSize
	BEQ loc_BANK0_8A26

	LDY PlayerCurrentSize
	LDA GrowShrinkSFXIndexes, Y
	STA SoundEffectQueue2
	LDA #$1E
	STA PlayerStateTimer
	LDA #PlayerState_ChangingSize
	STA PlayerState

loc_BANK0_8A26:
	LDA #ObjAttrib_Palette0
	STA PlayerAttributes
	LDA PlayerState
	JSR JumpToTableAfterJump ; Player state handling?

	.dw HandlePlayerState_Normal ; Normal
	.dw HandlePlayerState_Climbing ; Climbing
	.dw HandlePlayerState_Lifting ; Lifting
	.dw HandlePlayerState_ClimbingAreaTransition ; Climbing area transition
	.dw HandlePlayerState_GoingDownJar ; Going down jar
	.dw HandlePlayerState_ExitingJar ; Exiting jar
	.dw HandlePlayerState_HawkmouthEating ; Hawkmouth eating
	.dw HandlePlayerState_Dying ; Dying
	.dw HandlePlayerState_ChangingSize ; Changing size

IFDEF CHAR_SWITCH
	.include "src/extras/player/char_switch_0.asm"
HandlePlayerState_Normal:
    JSR HandlePlayer_ChangeChar
ELSE
HandlePlayerState_Normal:
ENDIF
	JSR PlayerGravity

	; player animation frame, crouch jump charging
	JSR sub_BANK0_8C1A

	; maybe only y-collision?
	JSR PlayerTileCollision

	; screen boundary x-collision
	JSR PlayerAreaBoundaryCollision

	JSR ApplyPlayerPhysicsY


;
; Applies player physics on the x-axis
;
ApplyPlayerPhysicsX:
	LDX #$00
	JSR ApplyPlayerPhysics

	LDA IsHorizontalLevel
	BNE ApplyPlayerPhysicsX_Exit

	STA PlayerXHi

ApplyPlayerPhysicsX_Exit:
	RTS


;
; What goes up must come down
;
HandlePlayerState_Dying:
	LDA PlayerStateTimer
	BNE locret_BANK0_8A86

	LDA PlayerScreenYHi
	CMP #02
	BEQ LoseALife

	JSR ApplyPlayerPhysicsY

	LDA PlayerYVelocity
	BMI loc_BANK0_8A72

	CMP #$39
	BCS locret_BANK0_8A86

loc_BANK0_8A72:
	INC PlayerYVelocity
	INC PlayerYVelocity
	RTS

; ---------------------------------------------------------------------------

LoseALife:
	LDA #02
	STA PlayerAnimationFrame
	LDY #$01 ; Set game mode to title card
	DEC ExtraLives
IFDEF INDIE_LIVES
	.include "src/extras/player/lose-a-life-independent-check.asm"
ENDIF
	BNE SetGameModeAfterDeath

	INY ; If no lives, increase game mode
; from 1 (title card) to 2 (game over)

SetGameModeAfterDeath:
	STY GameMode

locret_BANK0_8A86:
	RTS

; ---------------------------------------------------------------------------

HandlePlayerState_Lifting:
	LDA PlayerStateTimer
	BNE locret_BANK0_8AC1

	LDX ObjectBeingCarriedIndex
	LDY ObjectBeingCarriedTimer, X
	CPY #$02
	BCC loc_BANK0_8ABB

	CPY #$07
	BNE loc_BANK0_8A9D

	LDA #DPCM_ItemPull
	STA DPCMQueue

loc_BANK0_8A9D:
	DEC ObjectBeingCarriedTimer, X
	LDA PlayerLiftFrames, Y
	STA PlayerAnimationFrame
	LDA EnemyState, X
	CMP #$06
	BEQ loc_BANK0_8AB0

	LDA ObjectType, X
	CMP #Enemy_VegetableSmall
	BNE loc_BANK0_8AB5

loc_BANK0_8AB0:
	LDA PlayerLiftTimer - 2, Y
	BPL loc_BANK0_8AB8

loc_BANK0_8AB5:
	LDA PickupSpeedAnimation - 2, Y

loc_BANK0_8AB8:
	STA PlayerStateTimer
IFDEF CUSTOM_MUSH
    LDX #CustomBitFlag_PowerGrip
    JSR ChkFlagPlayer
	BNE +
	LDA #$0
	STA PlayerStateTimer
+
ENDIF
	RTS

; ---------------------------------------------------------------------------

loc_BANK0_8ABB:
	STA PlayerState
	INC PlayerInAir

loc_BANK0_8ABF:
	INC PlayerDucking

locret_BANK0_8AC1:
	RTS


PlayerLiftTimer:
	.db $00
	.db $01
	.db $01
	.db $01

PlayerLiftFrames:
	.db $01
	.db $02
	.db $04
	.db $04
	.db $04
	.db $04
	.db $08
	.db $08

byte_BANK0_8ACE:
	.db $00
	.db $10
	.db $F0
; ---------------------------------------------------------------------------

HandlePlayerState_Climbing:
	LDA Player1JoypadHeld
	AND #ControllerInput_Down | ControllerInput_Up
	LSR A
	LSR A
	TAY
	CPY #$02
	BNE loc_BANK0_8ADF

	JSR PlayerClimbAnimation

loc_BANK0_8ADF:
	LDA ClimbSpeed, Y
	STA PlayerYVelocity
	LDA Player1JoypadHeld
	AND #ControllerInput_Right | ControllerInput_Left
	TAY
	LDA byte_BANK0_8ACE, Y
	STA PlayerXVelocity
	LDA PlayerXLo
	CLC
	ADC #$04
	AND #$0F
	CMP #$08
	BCS loc_BANK0_8B14

	LDY TileCollisionHitboxIndex + $0B
	LDA PlayerYVelocity
	BMI loc_BANK0_8B01

	INY

loc_BANK0_8B01:
	LDX #$00
	JSR PlayerTileCollision_CheckClimbable

	BCS loc_BANK0_8B0E

loc_BANK0_8B08:
	LDA PlayerYVelocity
	BPL loc_BANK0_8B14

	STX PlayerYVelocity

loc_BANK0_8B0E:
	JSR ApplyPlayerPhysicsX

	JMP ApplyPlayerPhysicsY

; ---------------------------------------------------------------------------

loc_BANK0_8B14:
	LDA #$00
	STA PlayerState
	RTS


;
; Does climbing animation and sound
;
PlayerClimbAnimation:
	LDA byte_RAM_10
	AND #$07
	BNE PlayerClimbAnimation_Exit

	LDA PlayerDirection
	EOR #$01
	STA PlayerDirection
	LDA #SoundEffect2_Climbing
	STA SoundEffectQueue2

PlayerClimbAnimation_Exit:
	RTS


ClimbableTiles:
	.db BackgroundTile_Vine
	.db BackgroundTile_VineStandable
	.db BackgroundTile_VineBottom
	.db BackgroundTile_ClimbableSky
	.db BackgroundTile_Chain
	.db BackgroundTile_Ladder
	.db BackgroundTile_LadderShadow
	.db BackgroundTile_LadderStandable
	.db BackgroundTile_LadderStandableShadow
	.db BackgroundTile_ChainStandable


;
; Checks whether the player is on a climbable tile
;
; Input
;   byte_RAM_0 = tile ID
; Output
;   C = set if the player is on a climbable tile
;
PlayerTileCollision_CheckClimbable:
	JSR sub_BANK0_924F

	LDA byte_RAM_0
	LDY #$09

PlayerTileCollision_CheckClimbable_Loop:
	CMP ClimbableTiles, Y
	BEQ PlayerTileCollision_CheckClimbable_Exit

	DEY
	BPL PlayerTileCollision_CheckClimbable_Loop

	CLC

PlayerTileCollision_CheckClimbable_Exit:
	RTS


HandlePlayerState_GoingDownJar:
	LDA #ObjAttrib_BehindBackground
	STA PlayerAttributes
	INC PlayerYLo
	LDA PlayerYLo
	AND #$0F
	BNE HandlePlayerState_GoingDownJar_Exit

	STA PlayerState
	JSR DoAreaReset

	PLA
	PLA
	JSR StashPlayerPosition_Bank0

	LDA #TransitionType_Jar
	STA TransitionType
	LDA InJarType
	BNE HandlePlayerState_GoingDownJar_NonWarp

	LDA #GameMode_Warp
	STA GameMode
	RTS

HandlePlayerState_GoingDownJar_NonWarp:
	CMP #$01
	BEQ HandlePlayerState_GoingDownJar_Regular

	STA DoAreaTransition
	RTS

HandlePlayerState_GoingDownJar_Regular:
	STA InSubspaceOrJar

HandlePlayerState_GoingDownJar_Exit:
	RTS


HandlePlayerState_ExitingJar:
	LDA #ObjAttrib_BehindBackground
	STA PlayerAttributes
	DEC PlayerYLo
	LDA PlayerYLo
	AND #$0F
	BNE locret_BANK0_8B86

	STA PlayerState

locret_BANK0_8B86:
	RTS


; The climb transition triggers on particular player screen y-positions
ClimbTransitionYExitPositionHi:
	.db $00 ; down
	.db $FF ; up

ClimbTransitionYExitPositionLo:
	.db $EE ; down
	.db $DE ; up

; The second climbing trigger table uses $00 as the high value
ClimbTransitionYEnterPositionLo:
	.db $09 ; down
	.db $A1 ; up


HandlePlayerState_ClimbingAreaTransition:
	; Determine the climbing direction from the y-velocity ($00 = down, $00 = up)
	LDA PlayerYVelocity
	ASL A
	ROL A
	AND #$01
	TAY

HandlePlayerState_CheckExitPosition:
	; Determine whether the player screen y-position matches the table entry
	LDA PlayerScreenYHi
	CMP ClimbTransitionYExitPositionHi, Y
	BNE HandlePlayerState_CheckEnterPosition

	LDA PlayerScreenYLo
	CMP ClimbTransitionYExitPositionLo, Y
	BNE HandlePlayerState_CheckEnterPosition

	; The position matches, so keep climbing and transition to the next area
	JSR DoAreaReset

	INC DoAreaTransition
	LDA #TransitionType_Vine
	STA TransitionType
	RTS

HandlePlayerState_CheckEnterPosition:
	LDA PlayerScreenYHi
	BNE HandlePlayerState_JustClimb

	; Climbing until player reaches the desired position
	LDA PlayerScreenYLo
	CMP ClimbTransitionYEnterPositionLo, Y
	BEQ HandlePlayerState_SetClimbing

HandlePlayerState_JustClimb:
	; do the climb animation if the player is going up
	TYA
	BEQ HandlePlayerState_JustClimb_Physics

	JSR PlayerClimbAnimation

HandlePlayerState_JustClimb_Physics:
	JMP ApplyPlayerPhysicsY

HandlePlayerState_SetClimbing:
IFDEF RANDOMIZER_FLAGS_DISABLED
	JSR PlayerTileCollision_CheckClimbable
	BCS +ok
	LDY #$02
	LDA byte_RAM_0
	JSR CheckTileUsesCollisionType
	BCC +ok
	JSR AreaTransitionPlacement_DoorCustom
	LDA #$0
	STA PlayerState
+ok
ENDIF
	LDA #PlayerState_Climbing
	STA PlayerState
	RTS



HandlePlayerState_HawkmouthEating:
	LDA PlayerStateTimer
	BEQ loc_BANK0_8BE9

	JSR ApplyPlayerPhysicsY

	LDA_abs PlayerCollision

	BEQ locret_BANK0_8BEB

	LDA #ObjAttrib_BehindBackground
	STA PlayerAttributes
IFDEF HAWKMOUTH_FIX
	LDA PlayerDirection
	BEQ +
	LDA #$04
	BNE ++
+   LDA #$F8
++  STA PlayerXVelocity
ELSE
	LDA #$04
	STA PlayerXVelocity
	LDA #$01
	STA PlayerDirection
ENDIF

loc_BANK0_8BE3:
	JSR ApplyPlayerPhysicsX

	JMP PlayerWalkJumpAnim

; ---------------------------------------------------------------------------

loc_BANK0_8BE9:
	STA PlayerState

locret_BANK0_8BEB:
	RTS


; Alternate between large and small graphics on these frames when changing size
ChangingSizeKeyframes:
	.db $05
	.db $0A
	.db $0F
	.db $14
	.db $19


HandlePlayerState_ChangingSize:
	LDA PlayerStateTimer
	BEQ loc_BANK0_8C0D

	INC DamageInvulnTime

	LDY #$04
HandlePlayerState_ChangingSize_Loop:
	CMP ChangingSizeKeyframes, Y
	BNE HandlePlayerState_ChangingSize_Next

	LDA PlayerCurrentSize
	EOR #$01
	STA PlayerCurrentSize
	JMP LoadCharacterCHRBanks

HandlePlayerState_ChangingSize_Next:
	DEY
	BPL HandlePlayerState_ChangingSize_Loop

	RTS

; ---------------------------------------------------------------------------

loc_BANK0_8C0D:
	LDY PlayerAnimationFrame
	CPY #$0A
	BNE loc_BANK0_8C15

	LDA #PlayerState_Climbing

loc_BANK0_8C15:
	STA PlayerState
	RTS

; ---------------------------------------------------------------------------

PlayerControlAcceleration:
	.db $FE
	.db $02

; =============== S U B R O U T I N E =======================================

; player crouch subroutine
sub_BANK0_8C1A:
	JSR PlayerWalkJumpAnim
IFDEF CUSTOM_MUSH
	.include "src/extras/jump-routine-bonus.asm"
ENDIF

	LDA PlayerInAir
	BNE ResetPartialCrouchJumpTimer

	LDA PlayerDucking
	BEQ loc_BANK0_8C2B

	LDA PlayerStateTimer
	BNE loc_BANK0_8C92

	DEC PlayerDucking

loc_BANK0_8C2B:
	LDA Player1JoypadPress
	BPL loc_BANK0_8C3D ; branch if not pressing A Button

	INC PlayerInAir
IFDEF CUSTOM_PLAYER_RENDER
	LDA HoldingItem
	BNE +
	LDA #SpriteAnimation_Jumping
	STA PlayerAnimationFrame
+
ELSE
	LDA #SpriteAnimation_Jumping
	STA PlayerAnimationFrame
ENDIF
	JSR PlayerStartJump

	LDA #SoundEffect2_Jump
	STA SoundEffectQueue2

loc_BANK0_8C3D:
	LDA PlayerRidingCarpet
	BNE loc_BANK0_8C92

	LDA QuicksandDepth
	BNE ResetPartialCrouchJumpTimer

	LDA Player1JoypadHeld ; skip if down button is not pressed
	AND #ControllerInput_Down
	BEQ ResetPartialCrouchJumpTimer

	INC PlayerDucking ; set ducking state?
	LDA #SpriteAnimation_Ducking ; set ducking animation
	STA PlayerAnimationFrame
	LDA PlayerInAir ; skip ahead if player is in air
	BNE ResetPartialCrouchJumpTimer

	LDA CrouchJumpTimer ; check if crouch jump is charged
	CMP #$3C
	BCS loc_BANK0_8C92

	INC CrouchJumpTimer ; increment crouch jump charge
IFDEF CUSTOM_MUSH
    JSR Player_PowerCharge
ENDIF
	BNE loc_BANK0_8C92

ResetPartialCrouchJumpTimer: ; reset crouch jump timer if it isn't full
	LDA CrouchJumpTimer
	CMP #$3C ; max crouch jump timer
	BCS loc_BANK0_8C6F

	LDA #$00 ; reset crouch jump timer to zero
	STA CrouchJumpTimer

loc_BANK0_8C6F:
	LDA Player1JoypadHeld
	AND #ControllerInput_Right | ControllerInput_Left
	BEQ loc_BANK0_8C92

	AND #$01
	STA PlayerDirection
	TAY
	LDA GroundSlipperiness
	LSR A
	LSR A
	AND byte_RAM_10
	BNE ResetCrouchJumpTimer

	LDA PlayerXVelocity
	CLC
	ADC PlayerControlAcceleration, Y
	STA PlayerXVelocity

ResetCrouchJumpTimer:
	LDA #$00
	STA CrouchJumpTimer
	BEQ loc_BANK0_8C95 ; unconditional branch?

loc_BANK0_8C92:
	JSR sub_BANK0_8D2C

loc_BANK0_8C95:
	JSR sub_BANK0_8DC0

	RTS

; End of function sub_BANK0_8C1A


;
; Starts a jump
;
; The jump height is based on a lookup table using the following bitfield:
;
; %xxxxxRCI
;   R = whether the player is running
;   C = whether the crouch timer is charged
;   I = whether the player is holding an item
;
PlayerStartJump:
	LDA QuicksandDepth
	CMP #$02
	BCC PlayerStartJump_LoadXVelocity

IFDEF CUSTOM_MUSH
    LDX #CustomBitFlag_AllTerrain
    JSR ChkFlagPlayer2
    BEQ PlayerStartJump_LoadXVelocity
ENDIF

	; Quicksand
	LDA JumpHeightQuicksand
	STA PlayerYVelocity
	BNE PlayerStartJump_Exit

PlayerStartJump_LoadXVelocity:
	; The x-velocity may affect the jump
	LDA PlayerXVelocity
	BPL PlayerStartJump_CheckXSpeed

	; Absolute value of x-velocity
	EOR #$FF
	CLC
	ADC #$01

PlayerStartJump_CheckXSpeed:
	; Set carry flag if the x-speed is fast enough
	CMP #$08
	; Clear y subpixel
	LDA #$00
	STA PlayerYSubpixel
	; Set bit for x-speed using carry flag
	ROL A

	; Check crouch jump timer
	LDY CrouchJumpTimer
	CPY #$3C
	BCC PlayerStartJump_SetYVelocity

IFDEF JUMP_THROW_FIX
    LDA #$F0 ;; thx smb2 improvement patch (spiderdave) 
    AND Player1JoypadHeld
    STA Player1JoypadHeld
    LDA #$0
ENDIF
IFNDEF JUMP_THROW_FIX
	LDA #$00
	STA Player1JoypadHeld
ENDIF

PlayerStartJump_SetYVelocity:
	; Set bit for charged jump using carry flag
	ROL A
	; Set bit for whether player is holding an item
	ASL A
	ORA HoldingItem
	TAY
	LDA JumpHeightStanding, Y
	STA PlayerYVelocity
IFDEF CUSTOM_MUSH
    JSR Player_HiJump
ENDIF

	LDA JumpFloatLength
	STA JumpFloatTimer

PlayerStartJump_Exit:
	LDA #$00
	STA CrouchJumpTimer
	RTS


; =============== S U B R O U T I N E =======================================

;
; Apply gravity to the player's y-velocity
;
; This also handles floating
;
PlayerGravity:
	LDA QuicksandDepth
	CMP #$02
	BCC loc_BANK0_8CE5

IFDEF CUSTOM_MUSH
    LDX #CustomBitFlag_AllTerrain
    JSR ChkFlagPlayer2
    BEQ loc_BANK0_8CE5
ENDIF

	LDA GravityQuicksand
	BNE loc_BANK0_8D13

loc_BANK0_8CE5:
	LDA GravityWithoutJumpButton
	LDY Player1JoypadHeld ; holding jump button to fight physics
	BPL PlayerGravity_Falling

	LDA GravityWithJumpButton
	LDY PlayerYVelocity
	CPY #$0FC
	BMI PlayerGravity_Falling

	LDY JumpFloatTimer
	BEQ PlayerGravity_Falling

	DEC JumpFloatTimer
	LDA byte_RAM_10
	LSR A
	LSR A
	LSR A
	AND #$03
	TAY
	LDA FloatingYVelocity, Y
	STA PlayerYVelocity
	RTS

PlayerGravity_Falling:
	LDY PlayerYVelocity
	BMI loc_BANK0_8D13

	CPY #$39
	BCS loc_BANK0_8D18

loc_BANK0_8D13:
	CLC
	ADC PlayerYVelocity
	STA PlayerYVelocity

loc_BANK0_8D18:
	LDA JumpFloatTimer
	CMP JumpFloatLength
	BEQ PlayerGravity_Exit

	LDA #$00
	STA JumpFloatTimer

PlayerGravity_Exit:
	RTS


FloatingYVelocity:
	.db $FC
	.db $00
	.db $04
	.db $00

PlayerXDeceleration:
	.db $FD
	.db $03


; =============== S U B R O U T I N E =======================================

sub_BANK0_8D2C:
	LDA PlayerInAir
	BNE locret_BANK0_8D61

	LDA byte_RAM_10
	AND GroundSlipperiness
	BNE loc_BANK0_8D4D

	LDA PlayerXVelocity
	AND #$80
	ASL A
	ROL A
	TAY
	LDA PlayerXVelocity
	ADC PlayerXDeceleration, Y
	TAX
	EOR PlayerControlAcceleration, Y
	BMI loc_BANK0_8D4B

	LDX #$00

loc_BANK0_8D4B:
	STX PlayerXVelocity

loc_BANK0_8D4D:
	LDA PlayerDucking
	BNE locret_BANK0_8D61

	LDA PlayerAnimationFrame
	CMP #SpriteAnimation_Throwing
	BEQ locret_BANK0_8D61

	LDA #SpriteAnimation_Standing
	STA PlayerAnimationFrame
	LDA #$00
	STA PlayerWalkFrameCounter

loc_BANK0_8D5F:
	STA PlayerWalkFrame

locret_BANK0_8D61:
	RTS

; End of function sub_BANK0_8D2C

; ---------------------------------------------------------------------------

PlayerWalkFrameDurations:
	.db $0C
	.db $0A
	.db $08
	.db $05
	.db $03
	.db $02
	.db $02
	.db $02
	.db $02
	.db $02

PlayerWalkFrames:
	.db SpriteAnimation_Standing ; $00
	.db SpriteAnimation_Walking ; $01
	.db SpriteAnimation_Throwing ; ; $02

; =============== S U B R O U T I N E =======================================

; jump animation subroutine
PlayerWalkJumpAnim:
	LDA PlayerDucking ; exit if we're ducking, since the player will be ducking
	BNE ExitPlayerWalkJumpAnim

	; if we're not in the air, skip ahead
	LDA PlayerInAir
	BEQ PlayerWalkAnim

IFNDEF CUSTOM_PLAYER_RENDER
	LDA CurrentCharacter ; does this character get to flutter jump?
	CMP #Character_Luigi
	BNE ExitPlayerWalkJumpAnim
ELSE
	LDX CurrentCharacter ; does this character get to flutter jump?
    LDA DokiMode, X
    AND #CustomCharFlag_Fluttering
	BEQ ExitPlayerWalkJumpAnim
ENDIF

	LDA PlayerWalkFrameCounter
	BNE UpdatePlayerAnimationFrame ; maintain current frame

	LDA #$02 ; fast animation
	BNE NextPlayerWalkFrame

PlayerWalkAnim:
	LDA PlayerWalkFrameCounter
	BNE UpdatePlayerAnimationFrame ; maintain current frame

	LDA #$05
	LDY GroundSlipperiness
	BNE NextPlayerWalkFrame

	LDA PlayerXVelocity
	BPL PlayerWalkFrameDuration

	; use absolute value of PlayerXVelocity
	EOR #$FF
	CLC
	ADC #$01

PlayerWalkFrameDuration:
	LSR A
	LSR A
	LSR A
	TAY
	LDA PlayerWalkFrameDurations, Y

NextPlayerWalkFrame:
	STA PlayerWalkFrameCounter ; hold frame for duration specified in accumulator
	DEC PlayerWalkFrame
	BPL UpdatePlayerAnimationFrame

	LDA #$01 ; next walk frame
	STA PlayerWalkFrame

UpdatePlayerAnimationFrame:
	LDY PlayerWalkFrame
	LDA PlayerWalkFrames, Y
	STA PlayerAnimationFrame

ExitPlayerWalkJumpAnim:
	RTS


ThrowXVelocity:
	.db $00 ; standing, left (blocks)
	.db $00 ; standing, right (blocks)
	.db $D0 ; moving, left (blocks)
	.db $30 ; moving, right (blocks)
	.db $D0 ; standing, left (projectiles)
	.db $30 ; standing, right (projectiles)
	.db $D0 ; moving, left (projectiles)
	.db $30 ; moving, right (projectiles)

ThrowYVelocity:
	.db $18 ; standing (blocks)
	.db $00 ; moving (blocks)
	.db $18 ; standing (projectiles)
	.db $F8 ; moving (projectiles)

; used for objects that can be thrown next to the player
SoftThrowOffset:
	.db $F0
	.db $10



; Determine the max speed based on the terrain and what the player is carrying.
sub_BANK0_8DC0:
	LDY #$02
	LDA QuicksandDepth
	CMP #$02
	BCS loc_BANK0_8DE0

	DEY
	LDA HoldingItem
	BEQ loc_BANK0_8DDF

	LDX ObjectBeingCarriedIndex
	LDA ObjectType, X
	CMP #Enemy_VegetableSmall
	BCC loc_BANK0_8DE0

	CMP #Enemy_MushroomBlock
	BCC loc_BANK0_8DDF

	CMP #Enemy_FallingLogs
	BCC loc_BANK0_8DE0

loc_BANK0_8DDF:
	DEY

; 1.5x max speed when the run button is held!
loc_BANK0_8DE0:
	LDA RunSpeedRight, Y
	BIT Player1JoypadHeld
	BVC loc_BANK0_8DEC

	LSR A
	CLC
	ADC RunSpeedRight, Y

loc_BANK0_8DEC:
	CMP PlayerXVelocity
	BPL loc_BANK0_8DF2

	STA PlayerXVelocity

loc_BANK0_8DF2:
	LDA RunSpeedLeft, Y
	BIT Player1JoypadHeld
	BVC loc_BANK0_8DFF

	SEC
	ROR A
	CLC
	ADC RunSpeedLeft, Y

loc_BANK0_8DFF:
	CMP PlayerXVelocity
	BMI loc_BANK0_8E05

	STA PlayerXVelocity

; Check to see if we have an item that we want to throw.
loc_BANK0_8E05:
	BIT Player1JoypadPress
	BVC locret_BANK0_8E41

IFDEF CUSTOM_MUSH
    JSR StoreItem
SkipToThrowCheck:
ENDIF
	LDA HoldingItem
	BEQ locret_BANK0_8E41

	LDY #$00
	LDX ObjectBeingCarriedIndex
	LDA EnemyState, X
	CMP #EnemyState_Sand
	BEQ locret_BANK0_8E41

	LDA ObjectType, X
	CMP #Enemy_MushroomBlock
	BCC loc_BANK0_8E22

	CMP #Enemy_POWBlock
	BCC loc_BANK0_8E28

loc_BANK0_8E22:
	CMP #Enemy_Bomb
	BCC loc_BANK0_8E42

	LDY #$02

loc_BANK0_8E28:
	STY byte_RAM_7
	LDA PlayerDirection
	ASL A
	ORA PlayerDucking
	TAX
	LDY TileCollisionHitboxIndex + $06, X
	LDX #$00
	JSR sub_BANK0_924F

	LDA byte_RAM_0
	LDY byte_RAM_7
	JSR CheckTileUsesCollisionType

	BCC loc_BANK0_8E42
	; else carried item can't be thrown

locret_BANK0_8E41:
	RTS

; ---------------------------------------------------------------------------

loc_BANK0_8E42:
	LDA #SpriteAnimation_Throwing
	STA PlayerAnimationFrame
	LDA #$02
	STA PlayerWalkFrame
	LDA #$0A
	STA PlayerWalkFrameCounter
	DEC HoldingItem
	LDA #SoundEffect1_ThrowItem
	STA SoundEffectQueue1
	LDA #$00
	STA PlayerDucking
	STA Player1JoypadPress
	STA byte_RAM_1
	LDX ObjectBeingCarriedIndex
	LDA #Enemy_Coin
	CMP ObjectType, X
	ROL byte_RAM_1
	LDA PlayerXVelocity
	BPL loc_BANK0_8E6F

	EOR #$FF
	CLC
	ADC #$01

loc_BANK0_8E6F:
	CMP #$08
	ROL byte_RAM_1
	BNE loc_BANK0_8E89

	LDY PlayerDirection
	LDA SoftThrowOffset, Y
	CLC
	ADC ObjectXLo, X
	STA ObjectXLo, X
	LDA IsHorizontalLevel
	BEQ loc_BANK0_8E89

	DEY
	TYA
	ADC ObjectXHi, X

loc_BANK0_8E87:
	STA ObjectXHi, X

loc_BANK0_8E89:
	LDY byte_RAM_1
	LDA ThrowYVelocity, Y
	STA ObjectYVelocity, X
	LDA byte_RAM_1
	ASL A
	ORA PlayerDirection
	TAY
	LDA ThrowXVelocity, Y
IFDEF CUSTOM_MUSH
	.include "src/extras/power-throw-logic.asm"
ENDIF
IFNDEF CUSTOM_MUSH
	STA ObjectXVelocity, X
ENDIF
IFDEF CUSTOM_MUSH
	LDA ObjectType, X
	CMP #Enemy_Egg
	BNE +
	LDA EnemyVariable, X
	BEQ +
	LDA ObjectYLo, X
	CLC
	ADC #$C
	STA ObjectYLo, X
	LDA ObjectYHi, X
	ADC #$0
	STA ObjectYHi, X
+
ENDIF
	LDA #$01
	STA EnemyArray_42F, X
	LSR A
	STA ObjectBeingCarriedTimer, X
	RTS


;
; Applies player physics on the y-axis
;
ApplyPlayerPhysicsY:
	LDX #$0A

;
; Applies player physics, although could theoretically be used for objects too
;
; Input
;   X = direction ($00 for horizontal, $0A for vertical)
;
ApplyPlayerPhysics:
	; Add acceleration to velocity
	LDA PlayerXVelocity, X
	CLC
	ADC PlayerXAcceleration, X
	PHP
	BPL loc_BANK0_8EB4

	EOR #$FF
	CLC
	ADC #$01

loc_BANK0_8EB4:
	PHA
	; Upper nybble of velocity is for lo position
	LSR A
	LSR A
	LSR A
	LSR A
	TAY

	; Lower nybble of velocity is for subpixel position
	PLA
	ASL A
	ASL A
	ASL A
	ASL A
	CLC

	ADC PlayerXSubpixel, X
	STA PlayerXSubpixel, X

	TYA
	ADC #$00
	PLP
	BPL loc_BANK0_8ED1

	EOR #$FF
	CLC
	ADC #$01

loc_BANK0_8ED1:
	LDY #$00
	CMP #$00
	BPL loc_BANK0_8ED8

	DEY

loc_BANK0_8ED8:
	CLC
	ADC PlayerXLo, X
	STA PlayerXLo, X
	TYA
	ADC PlayerXHi, X
	STA PlayerXHi, X
	LDA #$00
	STA PlayerXAcceleration, X
	RTS


;
; Jumpthrough collision results
;
; This table determines per direction whether a tile is solid (for jumpthrough
; blocks) or interactive (for spikes/ice/conveyors)
;
;   $01 = true
;   $02 = false
;
JumpthroughTileCollisionTable:
InteractiveTileCollisionTable:
	.db $02 ; jumpthrough bottom (y-velocity < 0)
	.db $02
	.db $01 ; jumpthrough top (y-velocity > 0)
	.db $01
	.db $02 ; jumpthrough right (x-velocity < 0)
	.db $02
	.db $02 ; jumpthrough left (x-velocity > 0)
	.db $02

IFDEF ENABLE_TILE_ATTRIBUTES_TABLE
CheckPlayerTileCollisionAttributesTable:
	.db %00001000 ; jumpthrough bottom (y-velocity < 0)
	.db %00001000
	.db %00000100 ; jumpthrough top (y-velocity > 0)
	.db %00000100
	.db %00000010 ; jumpthrough right (x-velocity < 0)
	.db %00000010
	.db %00000001 ; jumpthrough left (x-velocity > 0)
	.db %00000001
ENDIF

;
; Collision flags that should be set if a given collision check passes
;
EnableCollisionFlagTable:
	.db CollisionFlags_Up
	.db CollisionFlags_Up
	.db CollisionFlags_Down
	.db CollisionFlags_Down
	.db CollisionFlags_Left
	.db CollisionFlags_Left
	.db CollisionFlags_Right
	.db CollisionFlags_Right

ConveyorSpeedTable:
	.db $F0
	.db $10


;
; Player Tile Collision
; =====================
;
; Handles player collision with background tiles
;
PlayerTileCollision:
	; Reset a bunch of collision flags
	LDA #$00
	STA PlayerCollision
	STA GroundSlipperiness
	STA byte_RAM_7
	STA byte_RAM_A ; conveyor
	STA byte_RAM_E ; spikes
	STA byte_RAM_C ; ice

	JSR PlayerTileCollision_CheckCherryAndClimbable

	; Determine bounding box lookup index
	LDA PlayerDucking
IFDEF SMALL_HITBOX
	ORA PlayerCurrentSize
ENDIF
	ASL A
	ORA HoldingItem
	TAX

	; Look up the bounding box for collision detection
	LDA TileCollisionHitboxIndex, X
	STA byte_RAM_8

	; Determine whether the player is going up
	LDA PlayerYVelocity
	CLC
	ADC PlayerYAcceleration
	BPL PlayerTileCollision_Downward

PlayerTileCollision_Upward:
	JSR CheckPlayerTileCollision_Twice ; use top two tiles
	JSR CheckPlayerTileCollision_IncrementTwice ; skip bottom two tiles

	LDA PlayerCollision
	BNE PlayerTileCollision_CheckDamageTile
	BEQ PlayerTileCollision_Horizontal

PlayerTileCollision_Downward:
	JSR CheckPlayerTileCollision_IncrementTwice ; skip top two tiles
	JSR CheckPlayerTileCollision_Twice ; use bottom two tiles

	LDA PlayerCollision
	BNE PlayerTileCollision_CheckInteractiveTiles

	LDA #$00
	LDX #$01

	; Do the quicksand check in worlds 2 and 6
	LDY CurrentWorldTileset
	CPY #$01
	BEQ PlayerTileCollision_Downward_CheckQuicksand

	CPY #$05
IFNDEF ALWAYS_ALLOW_QUICKSAND
	BNE PlayerTileCollision_Downward_AfterCheckQuicksand
ELSE
	NOP
	NOP
ENDIF

PlayerTileCollision_Downward_CheckQuicksand:
	JSR PlayerTileCollision_CheckQuicksand

PlayerTileCollision_Downward_AfterCheckQuicksand:
	STA QuicksandDepth
	STX PlayerInAir
	JMP PlayerTileCollision_Horizontal

PlayerTileCollision_CheckInteractiveTiles:
	; Reset quicksand depth
	LDA #$00
	STA QuicksandDepth

	LDA PlayerYLo
	AND #$0C
	BNE PlayerTileCollision_Horizontal

	STA PlayerInAir
	LDA PlayerYLo
	AND #$F0
	STA PlayerYLo

IFDEF CUSTOM_MUSH
    LDA byte_RAM_A
    ORA byte_RAM_C
    BEQ PlayerTileCollision_CheckJar
    LDX #CustomBitFlag_AllTerrain
    JSR ChkFlagPlayer2
    BNE +
    BEQ PlayerTileCollision_CheckJar
+
ENDIF

PlayerTileCollision_CheckConveyorTile:
	LSR byte_RAM_A
	BCC PlayerTileCollision_CheckSlipperyTile

	LDX byte_RAM_A
	LDA ConveyorSpeedTable, X
	STA PlayerXAcceleration

PlayerTileCollision_CheckSlipperyTile:
	LSR byte_RAM_C
	BCC PlayerTileCollision_CheckJar

	LDA #$0F
	STA GroundSlipperiness

PlayerTileCollision_CheckJar:
	JSR TileBehavior_CheckJar

PlayerTileCollision_CheckDamageTile:
IFDEF CUSTOM_MUSH
    JSR Player_GroundPoundHit
ENDIF
	LDA #$00
	STA PlayerYVelocity
	STA PlayerYAcceleration
	LDA StarInvincibilityTimer
	BNE PlayerTileCollision_Horizontal

	LSR byte_RAM_E
	BCC PlayerTileCollision_Horizontal

	LDA PlayerScreenX
	STA SpriteTempScreenX
	ROR byte_RAM_12

IFNDEF ENABLE_TILE_ATTRIBUTES_TABLE
	JSR PlayerTileCollision_HurtPlayer
ELSE
	LDA byte_RAM_E
	CMP #$02
	BCC PlayerTileCollision_DamageTile
	BNE PlayerTileCollision_HealthTile

	; instant kill
	LDY #$0F
	STY PlayerHealth

PlayerTileCollision_DamageTile:
	JSR PlayerTileCollision_HurtPlayer
	JMP PlayerTileCollision_Horizontal

PlayerTileCollision_HealthTile:
	JSR RestorePlayerToFullHealth
ENDIF

PlayerTileCollision_Horizontal:
	LDY #$02
	LDA PlayerXVelocity
	CLC
	ADC PlayerXAcceleration
	BMI loc_BANK0_8FA3

	DEY
	JSR CheckPlayerTileCollision_IncrementTwice

loc_BANK0_8FA3:
	STY PlayerMovementDirection
	JSR CheckPlayerTileCollision_Twice

	LDA PlayerCollision
	AND #CollisionFlags_Right | CollisionFlags_Left
	BEQ PlayerTileCollision_Exit

	JMP PlayerHorizontalCollision_Bank0

PlayerTileCollision_Exit:
	RTS


;
; Check collision attributes for the next two tiles
;
; Input
;   byte_RAM_7: collision direction
;   byte_RAM_8: bounding box offset
;
; Output
;   byte_RAM_7 += 2
;   byte_RAM_8 += 2
;
CheckPlayerTileCollision_Twice:
	JSR CheckPlayerTileCollision

IFNDEF ENABLE_TILE_ATTRIBUTES_TABLE
CheckPlayerTileCollision:
	LDX #$00
	LDY byte_RAM_8
	JSR sub_BANK0_924F

	LDX byte_RAM_7
	LDY JumpthroughTileCollisionTable, X
	LDA byte_RAM_0

	JSR CheckTileUsesCollisionType

IFNDEF BLOCK_CHECK
	BCC CheckPlayerTileCollision_Exit
ENDIF
IFDEF BLOCK_CHECK
	BCS + 
    JMP CheckPlayerTileCollision_Exit
+
    LDA PlayerYVelocity
    BPL ++
    LDA PlayerCollision
    CMP #CollisionFlags_Up
    BNE ++
    LDA byte_RAM_0
	CMP #BackgroundTile_MushroomBlock
    BNE +
    LDA HoldingItem
    BNE +
	BIT Player1JoypadHeld
	BVC +
    LDA #$0
	STA byte_RAM_9
    JSR loc_BANK0_9074
	LDA #$02
	STA PlayerStateTimer
    JMP CheckPlayerTileCollision_Exit
+
	LDA byte_RAM_0
	CMP #BackgroundTile_POWBlock
    BNE +
	JSR CreateEnemy_TryAllSlots_Bank1
	LDX byte_RAM_0
	STA byte_RAM_0
	CPY #$FF
	BEQ +
	LDA #$20
	STA POWQuakeTimer
	LDA #SoundEffect3_Rumble_B
	STA SoundEffectQueue3
	LDA byte_RAM_3
	STA ObjectXHi, X
	LDA byte_RAM_4
	STA ObjectYHi, X
	LDA byte_RAM_5
	STA ObjectXLo, X
	LDA byte_RAM_6
	STA ObjectYLo, X
    LDA #$1
    STA EnemyArray_42F, X
	LDA #EnemyState_BlockFizzle
	STA EnemyState, X
	LDA #$12
	STA EnemyTimer, X
	LDA #BackgroundTile_Sky
	JSR ReplaceTile_Bank0
+
    LDX #0
    JMP CheckPlayerTileCollision_UpdatePlayerCollision
	++
+
    LDA byte_RAM_0
	LDX byte_RAM_7
ENDIF

CheckPlayerTileCollision_CheckSpikes:
	CMP #BackgroundTile_Spikes
	BNE CheckPlayerTileCollision_CheckIce

	LDA InteractiveTileCollisionTable, X
	STA byte_RAM_E
IFDEF CUSTOM_MUSH
    LDX #CustomBitFlag_AllTerrain
    JSR ChkFlagPlayer2
    BNE + 
++
	LDA #$0
	STA byte_RAM_E
+
	LDX byte_RAM_7
ENDIF
	BNE CheckPlayerTileCollision_UpdatePlayerCollision

CheckPlayerTileCollision_CheckIce:
	CMP #BackgroundTile_JumpThroughIce
	BNE CheckPlayerTileCollision_CheckConveyor

	LDA InteractiveTileCollisionTable, X
	STA byte_RAM_C
	BNE CheckPlayerTileCollision_UpdatePlayerCollision

CheckPlayerTileCollision_CheckConveyor:
	SEC
	SBC #BackgroundTile_ConveyorLeft
	CMP #$02
	BCS CheckPlayerTileCollision_UpdatePlayerCollision

	ASL A
	ORA InteractiveTileCollisionTable, X
	STA byte_RAM_A

CheckPlayerTileCollision_UpdatePlayerCollision:
	LDA EnableCollisionFlagTable, X
	ORA PlayerCollision
	STA PlayerCollision

CheckPlayerTileCollision_Exit:
	JMP CheckPlayerTileCollision_Increment

ELSE
; custom behavior using tile attribute table
CheckPlayerTileCollision:
	LDX #$00
	LDY byte_RAM_8
	JSR sub_BANK0_924F

	LDX byte_RAM_7
	LDY byte_RAM_0

	; check tile attributes
	LDA TileCollisionAttributesTable, Y
	AND CheckPlayerTileCollisionAttributesTable, X

	BEQ CheckPlayerTileCollision_CheckSpikes

	LDA EnableCollisionFlagTable, X
	ORA PlayerCollision
	STA PlayerCollision

CheckPlayerTileCollision_CheckSpikes:
	LDA TileInteractionAttributesTable, Y
	AND #%00000011
	BEQ CheckPlayerTileCollision_CheckIce

	ASL A
	ORA #%00000001
	STA byte_RAM_E

CheckPlayerTileCollision_CheckIce:
	LDA TileInteractionAttributesTable, Y
	AND #%00001100
	BEQ CheckPlayerTileCollision_CheckConveyor
	CMP #%00000100
	BNE CheckPlayerTileCollision_CheckConveyor

	LDA #$01
	STA byte_RAM_C
	BNE CheckPlayerTileCollision_Exit

CheckPlayerTileCollision_CheckConveyor:
	CMP #%00001100
	BNE CheckPlayerTileCollision_Exit

	TYA
	AND #%00000001
	ASL A
	ORA #%00000001
	STA byte_RAM_A

CheckPlayerTileCollision_Exit:
	JMP CheckPlayerTileCollision_Increment
ENDIF


;
; Skip two tiles
;
; Output
;   byte_RAM_7 += 2
;   byte_RAM_8 += 2
;
CheckPlayerTileCollision_IncrementTwice:
	JSR CheckPlayerTileCollision_Increment

CheckPlayerTileCollision_Increment:
	INC byte_RAM_7
	INC byte_RAM_8
	RTS


PlayerTileCollision_CheckCherryAndClimbable:
	LDY TileCollisionHitboxIndex + $0A

	; byte_RAM_10 seems to be a global counter
	; this code increments Y every other frame, but why?
	; Seems like it alternates on each frame between checking the top and bottom of the player.
	LDA byte_RAM_10
	LSR A
	BCS PlayerTileCollision_CheckCherryAndClimbable_AfterTick
	INY

PlayerTileCollision_CheckCherryAndClimbable_AfterTick:
	LDX #$00
	JSR PlayerTileCollision_CheckClimbable

	BCS PlayerTileCollision_Climbable

	LDA byte_RAM_0
	CMP #BackgroundTile_Cherry
	BNE PlayerTileCollision_Climbable_Exit

	INC CherryCount
	LDA CherryCount
	SBC #$05
	BNE PlayerTileCollision_Cherry

	STA CherryCount
	JSR CreateStarman

PlayerTileCollision_Cherry:
	LDA #SoundEffect1_CherryGet
	STA SoundEffectQueue1
	LDA #BackgroundTile_Sky
	JMP loc_BANK0_937C

PlayerTileCollision_Climbable:
	LDA Player1JoypadHeld
	AND #ControllerInput_Down | ControllerInput_Up
	BEQ PlayerTileCollision_Climbable_Exit

	LDY HoldingItem
IFDEF CARRY_ON_VINE
	BEQ +
	LDX ObjectBeingCarriedIndex
	LDY ObjectType, X
	CPY #Enemy_Key
	BEQ +
	CPY #Enemy_SubspacePotion
	BNE PlayerTileCollision_Climbable_Exit
+   LDY #$0
ELSE
	BNE PlayerTileCollision_Climbable_Exit
ENDIF

	LDA PlayerXLo
	CLC
	ADC #$04
	AND #$0F
	CMP #$08
	BCS PlayerTileCollision_Climbable_Exit

	LDA #PlayerState_Climbing
	STA PlayerState
	STY PlayerInAir
	STY PlayerDucking
	LDA #SpriteAnimation_Climbing
	STA PlayerAnimationFrame

	; Break JSR PlayerTileCollision_CheckCherryAndClimbable
	PLA
	PLA
	; Break JSR PlayerTileCollision
	PLA
	PLA

PlayerTileCollision_Climbable_Exit:
	RTS


;
; Check whether a tile should use the given collision handler type
;
; Input
;   A = tile ID
;   Y = collision handler type (0 = solid for mushroom blocks, 1 = jumpthrough, 2 = solid)
; Output
;   C = whether or not collision type Y is relevant
;
CheckTileUsesCollisionType:
IFDEF CUSTOM_TILE_IDS_NOT
	CMP #$D8
	BCC +
	JSR CheckCustomSolidness
	+
ENDIF
	PHA ; stash tile ID for later

	; determine which tile table to use (0-3)
	AND #$C0
	ASL A
	ROL A
	ROL A

	; add the offset for the type of collision we're checking
	ADC TileGroupTable, Y
	TAY

	; check which side of the tile ID pivot we're on
	PLA
	CMP TileSolidnessTable, Y
	RTS


;
; These map the two high bits of a tile to offets in TileSolidnessTable
;
TileGroupTable:
	.db $00 ; solid to mushroom blocks
	.db $04 ; solid on top
	.db $08 ; solid on all sides


PickUpToEnemyTypeTable:
	.db Enemy_MushroomBlock ; $00
	.db Enemy_MushroomBlock ; $01
	.db Enemy_MushroomBlock ; $02
	.db Enemy_POWBlock ; $03
	.db Enemy_Coin ; $04
	.db Enemy_VegetableLarge ; $05
	.db Enemy_VegetableSmall ; $06
	.db Enemy_Rocket ; $07
	.db Enemy_Shell ; $08
	.db Enemy_Bomb ; $09
	.db Enemy_SubspacePotion ; $0A
	.db Enemy_Mushroom1up ; $0B
	.db Enemy_POWBlock ; $0C
	.db Enemy_BobOmb ; $0D
	.db Enemy_MushroomBlock ; $0E ; this one seems to be overridden for digging in sand


; find a slot for the item being lifted
loc_BANK0_9074:
	LDX #$06

loc_BANK0_9076:
	LDA EnemyState, X
	BEQ loc_BANK0_9080

	INX
	CPX #$09
	BCC loc_BANK0_9076

	RTS

; create the sprite for the item being picked up
loc_BANK0_9080:
	LDA byte_RAM_0
	STA EnemyVariable, X
	LDA byte_RAM_3
	STA ObjectXHi, X
	LDA byte_RAM_4
	STA ObjectYHi, X
	LDA byte_RAM_5
	STA ObjectXLo, X
	LDA byte_RAM_6
	STA ObjectYLo, X
	LDA #$00
	STA EnemyArray_42F, X
	STA ObjectAnimationTimer, X
	STA EnemyArray_B1, X
	JSR UnlinkEnemyFromRawData_Bank1

	LDA #EnemyState_Alive
	LDY byte_RAM_9
	CPY #$0E
	BNE loc_BANK0_90AE

	LDA #$20
	STA EnemyTimer, X
IFDEF CUSTOM_MUSH
    TXA
    PHA
    LDX #CustomBitFlag_PowerGrip
    JSR ChkFlagPlayer
	BNE +
    PLA
    TAX
	DEC HoldingItem
	LDA #$10
	STA PlayerYVelocity
	LDA #EnemyState_Sand
	BNE loc_BANK0_90AE
+
    PLA
    TAX
ENDIF
	LDA #EnemyState_Sand

loc_BANK0_90AE:
	STA EnemyState, X
	LDA PickUpToEnemyTypeTable, Y ; What sprite is spawned for you when lifting a bg object
	STA ObjectType, X

	LDY #$FF ; regular bomb fuse
	CMP #Enemy_Bomb
	BEQ loc_BANK0_90C1

	CMP #Enemy_BobOmb
	BNE loc_BANK0_90C5

	LDY #$50 ; BobOmb fuse

loc_BANK0_90C1:
	STY EnemyTimer, X
	BNE loc_BANK0_90EA

loc_BANK0_90C5:
	CMP #Enemy_Mushroom1up
	BNE loc_BANK0_90D5

IFDEF LEVEL_FLAGS
    TXA
    PHA
    LDX #CustomBitFlag_1up 
    JSR ApplyFlagLevel
    BEQ +
    INC Level_Count_1ups
    DEC Mushroom1upPulled
+   INC Mushroom1upPulled 
    PLA
    TAX
ENDIF

	LDA Mushroom1upPulled
	BEQ loc_BANK0_90EA

	LDA #Enemy_VegetableSmall
	STA ObjectType, X

	JMP loc_BANK0_90EA

loc_BANK0_90D5:
	CMP #Enemy_VegetableLarge
	BNE loc_BANK0_90EA

	LDY BigVeggiesPulled
	INY
	CPY #$05
	BCC loc_BANK0_90E7

	LDA #Enemy_Stopwatch
	STA ObjectType, X
	LDY #$00

loc_BANK0_90E7:
	STY BigVeggiesPulled

loc_BANK0_90EA:
	JSR loc_BANK1_B9EB

	LDA #CollisionFlags_Down
	STA EnemyCollision, X
	LDA #BackgroundTile_Sky
	JSR ReplaceTile_Bank0

	LDA #$07
	STA ObjectBeingCarriedTimer, X
	STX ObjectBeingCarriedIndex
	LDA #PlayerState_Lifting
	STA PlayerState
	LDA #$06
	STA PlayerStateTimer
	LDA #SpriteAnimation_Pulling
	STA PlayerAnimationFrame
	INC HoldingItem
	RTS


TileBehavior_CheckJar:
	LDY HoldingItem
	BNE loc_BANK0_917C

	LDA PlayerDucking
	BEQ TileBehavior_CheckPickUp

IFDEF UNUSED
	LDY HoldingItem
	BEQ +
	LDX ObjectBeingCarriedIndex
	LDY ObjectType, X
	CPY #Enemy_Key
	BEQ +
	CPY #Enemy_SubspacePotion
	BNE loc_BANK0_917C
+
ENDIF

	LDA byte_RAM_0
	LDX InSubspaceOrJar
	CPX #$02
	BNE TileBehavior_CheckJar_NotSubspace

	; In SubSpace, a non-enterable jar can be entered
	; Now Y = $00
IFDEF CUSTOM_LEVEL_RLE
NopThisForWarps:
	LDA #$0
ENDIF
	CMP #BackgroundTile_JarTopNonEnterable
	BEQ TileBehavior_GoDownJar

	BNE loc_BANK0_917C

TileBehavior_CheckJar_NotSubspace:
	INY
	; Now Y = $01
	CMP #BackgroundTile_JarTopGeneric
	BEQ TileBehavior_GoDownJar

	CMP #BackgroundTile_JarTopPointer
	BNE loc_BANK0_917C

	INY
	; Now Y = $02

TileBehavior_GoDownJar:
	LDA PlayerXLo
	CLC
	ADC #$04
	AND #$0F
	CMP #$08
	BCS loc_BANK0_917C

	; Stop horiziontal movement
	LDA #$00
	STA PlayerXVelocity

	; We're going down the jar!
	LDA #PlayerState_GoingDownJar
	STA PlayerState

	; What kind of jar are we going down?
	; $00 = warp, $01 = regular, $02 = pointer
	STY InJarType

;
; Snaps the player to the closest tile (for entering doors and jars)
;
SnapPlayerToTile:
	LDA PlayerXLo
	CLC
	ADC #$08
	AND #$F0
	STA PlayerXLo
	BCC SnapPlayerToTile_Exit

	LDA IsHorizontalLevel
	BEQ SnapPlayerToTile_Exit

	INC PlayerXHi

SnapPlayerToTile_Exit:
	RTS


TileBehavior_CheckPickUp:
	BIT Player1JoypadPress
	BVC loc_BANK0_917C

	; B button pressed

	LDA PlayerXLo
	CLC
	ADC #$06
	AND #$0F
	CMP #$0C
	BCS loc_BANK0_917C

	LDA byte_RAM_0
	CMP #BackgroundTile_DiggableSand
	BNE loc_BANK0_916E

	LDA #$0E
	BNE loc_BANK0_9177

; blocks that can be picked up
loc_BANK0_916E:
	CMP #BackgroundTile_Unused6D
	BCS loc_BANK0_917C

	; convert to an index in PickUpToEnemyTypeTable
	SEC
	SBC #BackgroundTile_MushroomBlock
	BCC loc_BANK0_917C

loc_BANK0_9177:
	STA byte_RAM_9
	JMP loc_BANK0_9074

; ---------------------------------------------------------------------------

loc_BANK0_917C:
	LDA PlayerDucking
	BNE locret_BANK0_91CE

	LDA byte_RAM_6
	SEC
	SBC #$10
	STA byte_RAM_6
	STA byte_RAM_E6
	LDA byte_RAM_4
	SBC #$00
	STA byte_RAM_4
	STA byte_RAM_1
	LDA byte_RAM_3
	STA byte_RAM_2
	JSR sub_BANK0_92C1

	BCS locret_BANK0_91CE

	JSR SetTileOffsetAndAreaPageAddr_Bank1

	LDY byte_RAM_E7
	LDA (byte_RAM_1), Y
	LDX HoldingItem
	BEQ loc_BANK0_91AE

IFDEF CARRY_ON_VINE
	LDX ObjectBeingCarriedIndex
	LDY ObjectType, X
	CPY #Enemy_Key
	BEQ loc_BANK0_91AE
	CPY #Enemy_SubspacePotion
	BNE locret_BANK0_91CE
ELSE
	LDX ObjectBeingCarriedIndex
	LDY ObjectType, X
	CPY #Enemy_Key
	BNE locret_BANK0_91CE
ENDIF

loc_BANK0_91AE:
	LDX InSubspaceOrJar
	CPX #$02
	BEQ loc_BANK0_91BF

	LDY #$04

; check to see if the tile matches one of the door tiles
loc_BANK0_91B7:
	CMP DoorTiles, Y
	BEQ loc_BANK0_91EB

	DEY
	BPL loc_BANK0_91B7

loc_BANK0_91BF:
	BIT Player1JoypadPress
	BVC locret_BANK0_91CE

	STA byte_RAM_0
	CMP #BackgroundTile_GrassInactive
	BCS locret_BANK0_91CE

	SEC
	SBC #BackgroundTile_GrassCoin
	BCS loc_BANK0_91CF

locret_BANK0_91CE:
	RTS

; ---------------------------------------------------------------------------

loc_BANK0_91CF:
	LDX InSubspaceOrJar
	CPX #$02
	BNE loc_BANK0_91E3

	LDA SubspaceVisits
	CMP #$02
	BCS loc_BANK0_91E2 ; skip if we've already visited Subspace twice

	INC SubspaceCoins
	LDX #$00

loc_BANK0_91E2:
	TXA

loc_BANK0_91E3:
	CLC
	ADC #$04
	STA byte_RAM_9
	JMP loc_BANK0_9074

; ---------------------------------------------------------------------------

;
; Checks to see if we're trying to go through the door
;
; Input
;   Y = tile index in DoorTiles
loc_BANK0_91EB:
	LDA Player1JoypadPress
	AND #ControllerInput_Up
	BEQ locret_BANK0_91CE

	; player is holding up and is trying to go through this door
	LDA PlayerXLo
	CLC
	ADC #$05
	AND #$0F
	CMP #$0A
	BCS locret_BANK0_91CE

	CPY #$04 ; index of BackgroundTile_LightDoorEndLevel
	BNE loc_BANK0_9205

	; setting GameMode to $03 to go to Bonus Chance
	DEY
	STY GameMode
	RTS

; ---------------------------------------------------------------------------

loc_BANK0_9205:
	LDA #TransitionType_Door
	STA TransitionType
	TYA
	JSR JumpToTableAfterJump

DoorHandlingPointers:
	.dw DoorHandling_UnlockedDoor ; unlocked door
	.dw DoorHandling_LockedDoor ; locked door
	.dw DoorHandling_Entrance ; dark door
	.dw DoorHandling_Entrance ; light door


DoorHandling_UnlockedDoor:
	JSR DoorAnimation_Unlocked

DoorHandling_GoThroughDoor:
	INC DoorAnimationTimer
	INC PlayerLock
	JSR SnapPlayerToTile

	LDA #DPCM_DoorOpenBombBom
	STA DPCMQueue

DoorHandling_Exit:
	RTS


DoorHandling_LockedDoor:
IFDEF LOCKED_DOOR
    LDX #CustomBitFlag_MasterKey
    LDA #$0
    JSR ChkFlagPlayer2
    BEQ SetFlagUnlock  ;; still need to have an object to set ?
    LDA KeyUsed
	BNE SetFlagUnlock
ENDIF
IFDEF CUSTOM_LEVEL_RLE
	LDA KeyUsed
	BEQ +no
	JSR DoorAnimation_Unlocked
	JMP DoorHandling_GoThroughDoor
+no
ENDIF
	LDA HoldingItem
	; don't come to a locked door empty-handed
	BEQ DoorHandling_Exit

	; and make sure you have a key
	LDY ObjectBeingCarriedIndex
	LDA ObjectType, Y
	CMP #Enemy_Key
	BNE DoorHandling_Exit

	; the key has been used
	INC KeyUsed
	TYA
	TAX

	JSR TurnKeyIntoPuffOfSmoke
IFDEF LOCKED_DOOR
SetFlagUnlock:
    LDX #CustomBitFlag_Key 
    JSR ApplyFlagLevel
    INC Level_Count_Unlocks
	INC KeyUsed
ENDIF
	JSR DoorAnimation_Locked
	JMP DoorHandling_GoThroughDoor


DoorHandling_Entrance:
	INC DoAreaTransition
	JMP DoAreaReset


DoorTiles:
	.db BackgroundTile_DoorBottom
	.db BackgroundTile_DoorBottomLock
	.db BackgroundTile_DarkDoor
	.db BackgroundTile_LightDoor
	.db BackgroundTile_LightDoorEndLevel


;
; Seems to determine what kind of tile the player has collided with?
;
; Input
;   X = object index (0 = player)
;   Y = bounding box offset
; Output
;   byte_RAM_0 = tile ID
;
sub_BANK0_924F:
	TXA
	PHA
	LDA #$00
	STA byte_RAM_0
	STA byte_RAM_1
	LDA VerticalTileCollisionHitboxX, Y
	BPL loc_BANK0_925E

	DEC byte_RAM_0

loc_BANK0_925E:
	CLC
	ADC PlayerXLo, X
	AND #$F0
	STA byte_RAM_5
	PHP
	LSR A
	LSR A
	LSR A
	LSR A
	STA byte_RAM_E5
	PLP
	LDA PlayerXHi, X
	ADC byte_RAM_0
	STA byte_RAM_2
	STA byte_RAM_3
	LDA IsHorizontalLevel
	BNE loc_BANK0_927D

	STA byte_RAM_2
	STA byte_RAM_3

loc_BANK0_927D:
	LDA VerticalTileCollisionHitboxY, Y
	BPL loc_BANK0_9284

	DEC byte_RAM_1

loc_BANK0_9284:
	CLC
	ADC PlayerYLo, X
	AND #$F0
	STA byte_RAM_6
	STA byte_RAM_E6
	LDA PlayerYHi, X
	ADC byte_RAM_1
	STA byte_RAM_1
	STA byte_RAM_4
	JSR sub_BANK0_92C1

	BCC loc_BANK0_929E

	LDA #$00
	BEQ loc_BANK0_92A5

loc_BANK0_929E:
	JSR SetTileOffsetAndAreaPageAddr_Bank1

	LDY byte_RAM_E7
	LDA (byte_RAM_1), Y

loc_BANK0_92A5:
	STA byte_RAM_0
	PLA
	TAX
	RTS


; =============== S U B R O U T I N E =======================================

sub_BANK0_92AA:
	STA byte_RAM_F
	TYA
	BMI locret_BANK0_92C0

	ASL A
	ASL A
	ASL A
	ASL A
	CLC
	ADC byte_RAM_F
	BCS loc_BANK0_92BC

	CMP #$F0
	BCC locret_BANK0_92C0

loc_BANK0_92BC:
	CLC
	ADC #$10
	INY

locret_BANK0_92C0:
	RTS

; End of function sub_BANK0_92AA


;
; NOTE: This is a copy of the "sub_BANK3_BC2E" routine in Bank 3
;
;
sub_BANK0_92C1:
	LDY byte_RAM_1
	LDA byte_RAM_E6
	JSR sub_BANK0_92AA

	STY byte_RAM_1
	STA byte_RAM_E6
	LDY IsHorizontalLevel
	LDA byte_RAM_1, Y
	STA byte_RAM_E8
	LDA byte_RAM_2
	CMP byte_BANK0_92E0 + 1, Y
	BCS locret_BANK0_92DF

	LDA byte_RAM_1
	CMP byte_BANK0_92E0, Y

locret_BANK0_92DF:
	RTS


byte_BANK0_92E0:
	.db $0A
	.db $01
	.db $0B


; Unused?
; Copy of DetermineVerticalScroll
_code_12E3:
	LDX NeedsScroll
	BNE locret_BANK0_9311

	LDA PlayerState
	CMP #PlayerState_Lifting
	BCS locret_BANK0_9311

	LDA PlayerScreenYLo
	LDY PlayerScreenYHi
	BMI loc_BANK0_92FF

	BNE loc_BANK0_9305

	CMP #$B4
	BCS loc_BANK0_9305

	CMP #$21
	BCS loc_BANK0_9307

loc_BANK0_92FF:
	LDY PlayerInAir
	BNE loc_BANK0_9307

	BEQ loc_BANK0_9306

loc_BANK0_9305:
	INX

loc_BANK0_9306:
	INX

loc_BANK0_9307:
	LDA VerticalScrollDirection
	STX VerticalScrollDirection
	BNE locret_BANK0_9311

loc_BANK0_930F:
	STX NeedsScroll

locret_BANK0_9311:
	RTS


PlayerCollisionDirectionTable:
	.db CollisionFlags_Right
	.db CollisionFlags_Left

PlayerCollisionResultTable_Bank0:
	.db CollisionFlags_80
	.db CollisionFlags_00


;
; Enforces the left/right boundaries of horizontal areas
;
PlayerAreaBoundaryCollision:
	LDA IsHorizontalLevel
	BEQ PlayerAreaBoundaryCollision_Exit

	LDA PlayerScreenX
	LDY PlayerMovementDirection
	CPY #$01
	BEQ PlayerAreaBoundaryCollision_CheckRight

PlayerAreaBoundaryCollision_CheckLeft:
	CMP #$08
	BCC PlayerAreaBoundaryCollision_BoundaryHit

PlayerAreaBoundaryCollision_Exit:
	RTS

PlayerAreaBoundaryCollision_CheckRight:
	CMP #$E8
	BCC PlayerAreaBoundaryCollision_Exit

PlayerAreaBoundaryCollision_BoundaryHit:
	LDA PlayerCollision
	ORA PlayerCollisionDirectionTable - 1, Y
	STA PlayerCollision

;
; NOTE: This is a copy of the "PlayerHorizontalCollision" routine in Bank 3
;
PlayerHorizontalCollision_Bank0:
	LDX #$00
	LDY PlayerMovementDirection
	LDA PlayerXVelocity
	EOR PlayerCollisionResultTable_Bank0 - 1, Y
	BPL loc_BANK0_9340

	STX PlayerXVelocity

loc_BANK0_9340:
	LDA PlayerXAcceleration
	EOR PlayerCollisionResultTable_Bank0 - 1, Y
	BPL loc_BANK0_934B

	STX PlayerXAcceleration

loc_BANK0_934B:
	STX PlayerXSubpixel
IFDEF CUSTOM_MUSH
	LDA Player1JoypadHeld
	AND #ControllerInput_Right | ControllerInput_Left
    BEQ +
    LDX #CustomBitFlag_WallCling | #CustomBitFlag_WallJump
    JSR ChkFlagPlayer3
    BNE +
    LDA #SpriteAnimation_CustomFrame1
    STA PlayerAnimationFrame
    LDA #CustomBitFlag_WallCling
    AND ($c5), Y
    BEQ +
    JSR Player_WallCling
+
    LDA PlayerInAir
    BEQ +
    LDX #CustomBitFlag_WallJump
    JSR ChkFlagPlayer3
    BNE +
	LDA Player1JoypadPress
	AND #ControllerInput_A
    BEQ +
    INC PlayerInAir
	LDA #SpriteAnimation_Jumping
	STA PlayerAnimationFrame
    LDA PlayerDirection
    BEQ ++
    LDA #$E0
    BNE +++
++
    LDA #$20
+++
    STA PlayerXVelocity
	JSR PlayerStartJump
+
ENDIF

locret_BANK0_934E:
	RTS


; =============== S U B R O U T I N E =======================================

;
; NOTE: This is a copy of the "sub_BANK3_BC50" routine in Bank 3
;
; Replaces tile when something is picked up
;
; Input
;   A = Target tile
;   X = Enemy index of object being picked up
;
ReplaceTile_Bank0:
	PHA ; Something to update the PPU for some tile change
	LDA ObjectXLo, X
	CLC
	ADC #$08
	PHP
	LSR A
	LSR A
	LSR A
	LSR A
	STA byte_RAM_E5
	PLP
	LDA ObjectXHi, X
	LDY IsHorizontalLevel
	BEQ ReplaceTile_StoreXHi_Bank0

	ADC #$00

ReplaceTile_StoreXHi_Bank0:
	STA byte_RAM_2
	LDA ObjectYLo, X
	CLC
	ADC #$08
	AND #$F0
	STA byte_RAM_E6
	LDA ObjectYHi, X
	ADC #$00
	STA byte_RAM_1
	JSR sub_BANK0_92C1

	PLA
	BCS locret_BANK0_934E

;
; Input
;   A = Target tile
;
loc_BANK0_937C:
	; Stash X so we can restore it later on
	STX byte_RAM_3

	; Stash the target tile and figure out where to draw it
	PHA
	JSR SetTileOffsetAndAreaPageAddr_Bank1
	PLA
	; Update the tile in the decoded level data
	LDY byte_RAM_E7
	STA (byte_RAM_1), Y

	PHA
	LDX byte_RAM_300
	LDA #$00
	STA PPUBuffer_301, X
	TYA
	AND #$F0
	ASL A
	ROL PPUBuffer_301, X
	ASL A
	ROL PPUBuffer_301, X
	STA PPUBuffer_301 + 1, X
	TYA
	AND #$0F
	ASL A

	ADC PPUBuffer_301 + 1, X
	STA PPUBuffer_301 + 1, X
	CLC
	ADC #$20
	STA PPUBuffer_301 + 6, X
	LDA IsHorizontalLevel
	ASL A
	TAY
	LDA byte_RAM_1
	AND #$10
	BNE loc_BANK0_93B9

	INY

loc_BANK0_93B9:
	LDA byte_BANK0_940A, Y
	CLC
	ADC PPUBuffer_301, X
	STA PPUBuffer_301, X
	STA PPUBuffer_301 + 5, X
	LDA #$02
	STA PPUBuffer_301 + 2, X
	STA PPUBuffer_301 + 7, X

	PLA
	PHA
	AND #%11000000
	ASL A
	ROL A
	ROL A
	TAY
	; Get the tile quad pointer
	LDA TileQuadPointersLo, Y
	STA byte_RAM_0
	LDA TileQuadPointersHi, Y
	STA byte_RAM_1
	PLA
	ASL A
	ASL A
	TAY
	LDA (byte_RAM_0), Y
	STA PPUBuffer_301 + 3, X
	INY
	LDA (byte_RAM_0), Y
	STA PPUBuffer_301 + 4, X
	INY
	LDA (byte_RAM_0), Y
	STA PPUBuffer_301 + 8, X
	INY
	LDA (byte_RAM_0), Y
	STA PPUBuffer_301 + 9, X
	LDA #$00
	STA PPUBuffer_301 + 10, X
	TXA
	CLC
	ADC #$0A
	STA byte_RAM_300
	LDX byte_RAM_3
	RTS


; Another byte of PPU high addresses for horiz/vert levels
byte_BANK0_940A:
	.db $20
	.db $28
	.db $20
	.db $24


;
; NOTE: This is a copy of the "StashPlayerPosition" routine in Bank 3
;
StashPlayerPosition_Bank0:
	LDA InSubspaceOrJar
	BNE StashPlayerPosition_Exit_Bank0

	LDA PlayerXHi
	STA PlayerXHi_Backup
	LDA PlayerXLo
	STA PlayerXLo_Backup
	LDA PlayerYHi
	STA PlayerYHi_Backup
	LDA PlayerYLo
	STA PlayerYLo_Backup

StashPlayerPosition_Exit_Bank0:
	RTS

;
; Restores the player position from the backup values after exiting a subarea
;
RestorePlayerPosition:
	LDA PlayerXHi_Backup
	STA PlayerXHi
	LDA PlayerXLo_Backup
	STA PlayerXLo
	LDA PlayerYHi_Backup
	STA PlayerYHi
	LDA PlayerYLo_Backup
	STA PlayerYLo
	LDA PlayerXLo
	SEC
	SBC ScreenBoundaryLeftLo
	STA PlayerScreenX
	LDA PlayerYLo
	SEC
	SBC ScreenYLo
	STA PlayerScreenYLo
	LDA PlayerYHi
	SBC ScreenYHi
	STA PlayerScreenYHi
	LDA TransitionType
	SEC
	SBC #TransitionType_SubSpace
	BNE StashPlayerPosition_Exit_Bank0

	; resetting these to zero (A=$00, otherwise we would have branched)
	STA PlayerState
	STA PlayerLock
	STA SubspaceTimer
	JSR DoorAnimation_Unlocked

	LDA #$0A
	STA SubspaceDoorTimer
	RTS


.include "./src/systems/transitions.asm"

IFNDEF ENABLE_TILE_ATTRIBUTES_TABLE
IFNDEF ROBUST_TRANSITION_SEARCH

; Unused space in the original ($95C3 - $95FF)
unusedSpace $9600, $FF
ENDIF
ENDIF

.include "./src/title_screen/main.asm"

; Unused space in the original ($9C58 - $A1FF)
unusedSpace $A200, $FF

.include "./src/systems/ending.asm"
; ---------------------------------------------------------------------------

; Unused space in the original ($AE5A - $B8FF)
unusedSpace $B900, $FF

MysteryCharacterData3900:
	.db $FB ; @TODO ??? Not sure what this is
	.db $FF
	.db $00
	.db $08
	.db $0C
	.db $18
	.db $1A


;
; NOTE: A copy of this subroutine also exists in Bank 2
;
; Applies object physics for the y-axis
;
; Input
;   X = enemy index
;
ApplyObjectPhysicsY_Bank1:
	TXA
	CLC
	ADC #$0A
	TAX

;
; NOTE: A copy of this subroutine also exists in Bank 2
;
; Applies object physics for the x-axis
;
; Input
;   X = enemy index, physics direction
;       ($00-$09 for horizontal, $0A-$13 for vertical)
;
; Output
;   X = RAM_12
;
ApplyObjectPhysicsX_Bank1:
	; Add acceleration to velocity
	LDA ObjectXVelocity, X
	CLC
	ADC ObjectXAcceleration, X

	PHA
	; Lower nybble of velocity is for subpixel position
	ASL A
	ASL A
	ASL A
	ASL A
	STA byte_RAM_1

	; Upper nybble of velocity is for lo position
	PLA
	LSR A
	LSR A
	LSR A
	LSR A

	CMP #$08
	BCC ApplyObjectPhysics_StoreVelocityLo_Bank1

	; Left/up: Carry negative bits through upper nybble
	ORA #$F0

ApplyObjectPhysics_StoreVelocityLo_Bank1:
	STA byte_RAM_0

	LDY #$00
	ASL A
	BCC ApplyObjectPhysics_StoreDirection_Bank1

	; Left/up
	DEY

ApplyObjectPhysics_StoreDirection_Bank1:
	STY byte_RAM_2

	; Add lower nybble of velocity for subpixel position
	LDA ObjectXSubpixel, X
	CLC
	ADC byte_RAM_1
	STA ObjectXSubpixel, X

	; Add upper nybble of velocity for lo position
	LDA ObjectXLo, X
	ADC byte_RAM_0
	STA ObjectXLo, X

ApplyObjectPhysics_PositionHi_Bank1:
	LSR byte_RAM_1
	LDA ObjectXHi, X
	ADC byte_RAM_2
	STA ObjectXHi, X

ApplyObjectPhysics_Exit_Bank1:
	LDX byte_RAM_12
	RTS



;
; Applies object physics
;
; Input
;   X = enemy index
;
ApplyObjectMovement_Bank1:
	LDA ObjectShakeTimer, X
	BNE ApplyObjectMovement_Vertical_Bank1

	JSR ApplyObjectPhysicsX_Bank1

ApplyObjectMovement_Vertical_Bank1:
	JSR ApplyObjectPhysicsY_Bank1

	LDA ObjectYVelocity, X
	BMI ApplyObjectMovement_Gravity_Bank1

	; Check terminal velocity
	CMP #$3E
	BCS ApplyObjectMovement_Exit_Bank1

ApplyObjectMovement_Gravity_Bank1:
	INC ObjectYVelocity, X
	INC ObjectYVelocity, X

ApplyObjectMovement_Exit_Bank1:
	RTS


DoorAnimation_Locked:
	LDA #$01
	BNE DoorAnimation

DoorAnimation_Unlocked:
	LDA #$00

DoorAnimation:
	PHA
	LDY #$08

DoorAnimation_Loop:
	; skip if inactive
	LDA EnemyState, Y
	BEQ DoorAnimation_LoopNext

	; skip enemies that aren't the door
	LDA ObjectType, Y
	CMP #Enemy_SubspaceDoor
	BNE DoorAnimation_LoopNext

	LDA #EnemyState_PuffOfSmoke
	STA EnemyState, Y
	LDA #$20
	STA EnemyTimer, Y

DoorAnimation_LoopNext:
	DEY
	BPL DoorAnimation_Loop

	JSR CreateEnemy_TryAllSlots_Bank1

	BMI DoorAnimation_Exit

	LDA #$00
	STA DoorAnimationTimer
	STA SubspaceDoorTimer
	LDX byte_RAM_0
	PLA
	STA EnemyArray_477, X
	LDA #Enemy_SubspaceDoor
	STA ObjectType, X
	LDA PlayerXLo
	ADC #$08
	AND #$F0
	STA ObjectXLo, X
	LDA PlayerXHi
	ADC #$00
	STA ObjectXHi, X
	LDA PlayerYLo
	STA ObjectYLo, X
	LDA PlayerYHi
	STA ObjectYHi, X
	LDA #ObjAttrib_Palette1 | ObjAttrib_16x32
	STA ObjectAttributes, X
	LDX byte_RAM_12
	RTS

DoorAnimation_Exit:
	PLA
	RTS


CreateStarman:
	JSR CreateEnemy_Bank1

	BMI CreateStarman_Exit

	LDX byte_RAM_0
	LDA #Enemy_Starman
	STA ObjectType, X
	LDA ScreenBoundaryLeftLo
	ADC #$D0
	STA ObjectXLo, X
	LDA ScreenBoundaryLeftHi
	ADC #$00
	STA ObjectXHi, X
	LDA ScreenYLo
	ADC #$E0
	STA ObjectYLo, X
	LDA ScreenYHi
	ADC #$00
	STA ObjectYHi, X
	JSR loc_BANK1_BA17

	LDX byte_RAM_12

CreateStarman_Exit:
	RTS


; =============== S U B R O U T I N E =======================================

EnemyInit_Basic_Bank1:
	LDA #$00
	STA EnemyTimer, X
	LDA #$00
	STA EnemyVariable, X

loc_BANK1_B9EB:
	LDA #$00
	STA EnemyArray_B1, X
	STA EnemyArray_42F, X
	STA ObjectBeingCarriedTimer, X
	STA ObjectAnimationTimer, X
	STA ObjectShakeTimer, X
	STA EnemyCollision, X
	STA EnemyArray_438, X
	STA EnemyArray_453, X
	STA ObjectXAcceleration, X
	STA ObjectYAcceleration, X
	STA EnemyArray_45C, X
	STA EnemyArray_477, X
	STA EnemyArray_480, X
	STA EnemyHP, X
	STA ObjectYVelocity, X
	STA ObjectXVelocity, X

; look up object attributes
loc_BANK1_BA17:
	LDY ObjectType, X
	LDA ObjectAttributeTable, Y
	AND #ObjAttrib_Palette | ObjAttrib_Horizontal | ObjAttrib_FrontFacing | ObjAttrib_Mirrored | ObjAttrib_BehindBackground | ObjAttrib_16x32
	STA ObjectAttributes, X
	LDA EnemyArray_46E_Data, Y
	STA EnemyArray_46E, X
	LDA EnemyArray_489_Data, Y
	STA EnemyArray_489, X
	LDA EnemyArray_492_Data, Y
	STA EnemyArray_492, X
	RTS

; End of function EnemyInit_Basic_Bank1


;
; Turns the key into a puff of smoke
;
; Input
;   X = enemy slot
; Output
;   X = value of byte_RAM_12
;
TurnKeyIntoPuffOfSmoke:
	LDA ObjectAttributes, X
	AND #%11111100
	ORA #ObjAttrib_Palette1
	STA ObjectAttributes, X
	LDA #EnemyState_PuffOfSmoke
	STA EnemyState, X
	STA ObjectAnimationTimer, X
	LDA #$1F
	STA EnemyTimer, X
	LDX byte_RAM_12
	RTS


;
; NOTE: This is a copy of the "UnlinkEnemyFromRawData" routine in Bank 2, but
; it is used here for spawning the door animation and Starman objects.
;
; Spawned enemies are linked to an offset in the raw enemy data, which prevents
; from being respawned until they are killed or moved offscreen.
;
; This subroutine ensures that the enemy in a particular slot is not linked to
; the raw enemy data
;
; Input
;   X = enemy slot
;
UnlinkEnemyFromRawData_Bank1:
	LDA #$FF
	STA EnemyRawDataOffset, X
	RTS


;
; Updates the area page and tile placement offset
;
; Input
;   byte_RAM_E8 = area page
;   byte_RAM_E5 = tile placement offset shift
;   byte_RAM_E6 = previous tile placement offset
; Output
;   RAM_1 = low byte of decoded level data RAM
;   RAM_2 = low byte of decoded level data RAM
;   byte_RAM_E7 = target tile placement offset
;
SetTileOffsetAndAreaPageAddr_Bank1:
	LDX byte_RAM_E8
	JSR SetAreaPageAddr_Bank1

	LDA byte_RAM_E6
	CLC
	ADC byte_RAM_E5
	STA byte_RAM_E7
	RTS


DecodedLevelPageStartLo_Bank1:
	.db <DecodedLevelData
	.db <(DecodedLevelData+$00F0)
	.db <(DecodedLevelData+$01E0)
	.db <(DecodedLevelData+$02D0)
	.db <(DecodedLevelData+$03C0)
	.db <(DecodedLevelData+$04B0)
	.db <(DecodedLevelData+$05A0)
	.db <(DecodedLevelData+$0690)
	.db <(DecodedLevelData+$0780)
	.db <(DecodedLevelData+$0870)
	.db <(SubAreaTileLayout)

DecodedLevelPageStartHi_Bank1:
	.db >DecodedLevelData
	.db >(DecodedLevelData+$00F0)
	.db >(DecodedLevelData+$01E0)
	.db >(DecodedLevelData+$02D0)
	.db >(DecodedLevelData+$03C0)
	.db >(DecodedLevelData+$04B0)
	.db >(DecodedLevelData+$05A0)
	.db >(DecodedLevelData+$0690)
	.db >(DecodedLevelData+$0780)
	.db >(DecodedLevelData+$0870)
	.db >(SubAreaTileLayout)


;
; Updates the area page that we're reading tiles from
;
; Input
;   X = area page
; Output
;   byte_RAM_1 = low byte of decoded level data RAM
;   byte_RAM_2 = low byte of decoded level data RAM
;
SetAreaPageAddr_Bank1:
	LDA DecodedLevelPageStartLo_Bank1, X
	STA byte_RAM_1
	LDA DecodedLevelPageStartHi_Bank1, X
	STA byte_RAM_2
	RTS


;
; Checks whether the player is on a quicksand tile
;
; Input
;   byte_RAM_0 = tile ID
; Output
;   A = Whether the player is sinking in quicksand
;   X = PlayerInAir flag
;
IFNDEF ENABLE_TILE_ATTRIBUTES_TABLE
PlayerTileCollision_CheckQuicksand:
	LDA #$01
	LDY byte_RAM_0
	CPY #BackgroundTile_QuicksandSlow
	BEQ PlayerTileCollision_QuicksandSlow

	CPY #BackgroundTile_QuicksandFast
	BEQ PlayerTileCollision_QuicksandFast

ELSE
PlayerTileCollision_CheckQuicksand:
	LDY byte_RAM_0
	LDA InteractiveTileCollisionTable, Y
	AND #%00001100
	CMP #%00001000

	BNE PlayerTileCollision_NotQuicksand

	TYA
	AND %00000001
	BNE PlayerTileCollision_QuicksandFast

	LDA #$01
	BNE PlayerTileCollision_QuicksandSlow
ENDIF

PlayerTileCollision_NotQuicksand:
	LDA #$00
	RTS

PlayerTileCollision_QuicksandFast:
	LDA #$08

PlayerTileCollision_QuicksandSlow:
	STA PlayerYVelocity
	LDA QuicksandDepth
	BNE loc_BANK1_BA9B

	LDA PlayerYLo
	AND #$10
	STA byte_RAM_4EB

loc_BANK1_BA9B:
	; check if player is too far under
	LDA PlayerYLo
	AND #$0F
	TAY
	LDA byte_RAM_4EB
	EOR PlayerYLo
	AND #$10
	BEQ loc_BANK1_BAB6

	; kill if >= this check
	CPY #$0C
	BCC loc_BANK1_BAB4

IFDEF CUSTOM_MUSH
    LDX #CustomBitFlag_AllTerrain
    JSR ChkFlagPlayer2
    BNE + 
	LDA #$0
	STA QuicksandDepth
	BEQ loc_BANK1_BAB4
+
ENDIF

	LDA #$00
	STA PlayerStateTimer
	JSR KillPlayer

loc_BANK1_BAB4:
	LDY #$04

loc_BANK1_BAB6:
	CPY #$04
	BCS loc_BANK1_BABC

	LDY #$01

loc_BANK1_BABC:
	TYA
	DEX
	RTS


PlayerTileCollision_HurtPlayer:
	LDA DamageInvulnTime
	BNE locret_BANK1_BAEC

	LDA PlayerHealth
	SEC
	SBC #$10
	BCC loc_BANK1_BAED

	STA PlayerHealth
	LDA #$7F
	STA DamageInvulnTime
	LDA PlayerScreenX
	SEC
	SBC SpriteTempScreenX
	ASL A
	ASL A
	STA PlayerXVelocity
	LDA #$C0
	LDY PlayerYVelocity
	BPL loc_BANK1_BAE5

	LDA #$00

loc_BANK1_BAE5:
	STA PlayerYVelocity
	LDA #DPCM_PlayerHurt
	STA DPCMQueue

locret_BANK1_BAEC:
	RTS

; ---------------------------------------------------------------------------

loc_BANK1_BAED:
	LDA #$C0
	STA PlayerYVelocity
	LDA #$20
	STA PlayerStateTimer
	LDY byte_RAM_12
	BMI loc_BANK1_BAFD

	LSR A
	STA EnemyArray_438, Y

loc_BANK1_BAFD:
	JMP KillPlayer


; ---------------------------------------------------------------------------

_code_3B00:
	LDY EnemyRawDataOffset, X
	BMI loc_BANK1_BB0B

	LDA (RawEnemyData), Y
	AND #$7F
	STA (RawEnemyData), Y

loc_BANK1_BB0B:
	LDA #$00
	STA EnemyState, X
	RTS


;
; NOTE: This is a copy of the "CreateEnemy" routine in Bank 2, but it is used
; here for spawning the door animation and Starman objects.
;
; Creates a generic red Shyguy enemy and
; does some basic initialization for it.
;
; CreateEnemy_TryAllSlots checks all 9 object slots
; CreateEnemy only checks the first 6 object slots
;
; Output
;   N = enabled if no empty slot was found
;   Y = $FF if there no empty slot was found
;   byte_RAM_0 = slot used
;
CreateEnemy_TryAllSlots_Bank1:
	LDY #$08
	BNE CreateEnemy_Bank1_FindSlot

CreateEnemy_Bank1:
	LDY #$05

CreateEnemy_Bank1_FindSlot:
	LDA EnemyState, Y
	BEQ CreateEnemy_Bank1_FoundSlot

	DEY
	BPL CreateEnemy_Bank1_FindSlot

	RTS

CreateEnemy_Bank1_FoundSlot:
	LDA #EnemyState_Alive
	STA EnemyState, Y
	LSR A
	STA EnemyArray_SpawnsDoor, Y
	LDA #Enemy_ShyguyRed
	STA ObjectType, Y
	LDA ObjectXLo, X
	ADC #$05
	STA ObjectXLo, Y
	LDA ObjectXHi, X
	ADC #$00
	STA ObjectXHi, Y
	LDA ObjectYLo, X
	STA ObjectYLo, Y
	LDA ObjectYHi, X
	STA ObjectYHi, Y
	STY byte_RAM_0
	TYA
	TAX

	JSR EnemyInit_Basic_Bank1
	JSR UnlinkEnemyFromRawData_Bank1

	LDX byte_RAM_12
	RTS

.include "src/extras/debug/controller-2-debug.asm"

IFDEF MIGRATE_QUADS
.include "src/systems/tile_quads.asm"
ENDIF

IFDEF CUSTOM_MUSH
.include "src/extras/player-mods.asm"
.include "src/extras/draw-inventory.asm"
ENDIF

