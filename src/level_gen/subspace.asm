;
;
; Subspace/subarea related functions
;
;

GenerateSubspaceArea:
	LDA CurrentLevelArea
	STA CurrentLevelAreaCopy
	LDA #$30 ; subspace palette (works like area header byte)
	STA byte_RAM_F ; why...?
	JSR ApplyPalette

	LDA ScreenBoundaryLeftHi
	STA byte_RAM_E8

	LDA ScreenBoundaryLeftLo
	CLC
	ADC #$08
	BCC loc_BANK6_9439

	INC byte_RAM_E8

loc_BANK6_9439:
	AND #$F0
	PHA
	SEC

	SBC ScreenBoundaryLeftLo
	STA MoveCameraX
	PLA
	LSR A
	LSR A
	LSR A
	LSR A
	STA byte_RAM_E5
	LDA #$00
	STA byte_RAM_E6
	LDA byte_RAM_E8
	STA byte_RAM_D
IFDEF TEST_FLAG_VERT_SUB
	LDA VertSubspaceFlag
	BEQ +
	LDA ScreenYHi
	STA byte_RAM_E8
	STA byte_RAM_D
	STA VertSubspaceFlag + 1
	LDA ScreenYLo
	STA VertSubspaceFlag + 2
	LDY ScreenYHi
	BEQ ++
--  CLC
	ADC #$10
	DEY
	BNE --
++
	AND #$F0
	STA byte_RAM_E6
	LDA #$0
	STA byte_RAM_E5
	LDA #$0
	STA ScreenYHi
	STA ScreenYLo
	JSR SetTileOffsetAndAreaPageAddr_Bank6
	LDA byte_RAM_1
	CLC
	ADC byte_RAM_E7
	STA byte_RAM_1
	LDA byte_RAM_2
	ADC #$0
	STA byte_RAM_2
	LDY #$0
	LDX #$0F
	BNE GenerateSubspaceArea_TileRemapLoop
+
ENDIF
	JSR SetTileOffsetAndAreaPageAddr_Bank6

	LDY byte_RAM_E7
	LDX #$0F

GenerateSubspaceArea_TileRemapLoop:
	LDA (byte_RAM_1), Y
	JSR DoSubspaceTileRemap

	STA SubAreaTileLayout, X
	TYA
	CLC
	ADC #$10
	TAY
	TXA
	CLC
	ADC #$10
	TAX
	AND #$F0
	BNE GenerateSubspaceArea_TileRemapLoop

IFDEF TEST_FLAG_VERT_SUB
	LDA VertSubspaceFlag
	BEQ +
	INY
	DEX
	BPL GenerateSubspaceArea_TileRemapLoop
	RTS
+
ENDIF
	TYA
	AND #$0F
	TAY
	JSR IncrementAreaXOffset

	DEX
	BPL GenerateSubspaceArea_TileRemapLoop

	RTS



;
; Remaps a single subspace tile.
;
; This also handles creating the mushroom sprites.
;
; ##### Input
; - `A`: input tile
;
; ##### Output
; - `A`: output tile
;
DoSubspaceTileRemap:
	STY byte_RAM_8
	STX byte_RAM_7
	LDX #(SubspaceTilesReplace - SubspaceTilesSearch - 1)

DoSubspaceTileRemap_Loop:
	CMP SubspaceTilesSearch, X
	BEQ DoSubspaceTileRemap_ReplaceTile

	DEX
	BPL DoSubspaceTileRemap_Loop

	CMP #BackgroundTile_SubspaceMushroom1
	BEQ DoSubspaceTileRemap_CheckCreateMushroom

	CMP #BackgroundTile_SubspaceMushroom2
	BEQ DoSubspaceTileRemap_CheckCreateMushroom

	JMP DoSubspaceTileRemap_Exit

DoSubspaceTileRemap_CheckCreateMushroom:
	SEC
	SBC #BackgroundTile_SubspaceMushroom1
	TAY
	LDA Mushroom1Pulled, Y
	BNE DoSubspaceTileRemap_AfterCreateMushroom
	LDX byte_RAM_7
	JSR CreateSubspaceMushroomObject

DoSubspaceTileRemap_AfterCreateMushroom:
	LDA #BackgroundTile_SubspaceMushroom1
	JMP DoSubspaceTileRemap_Exit

DoSubspaceTileRemap_ReplaceTile:
	LDA SubspaceTilesReplace, X

DoSubspaceTileRemap_Exit:
	LDX byte_RAM_7
	LDY byte_RAM_8
	RTS


;
; Clears the sub-area tile layout when the player goes into a jar
;
ClearSubAreaTileLayout:
	LDX #$00
	STX IsHorizontalLevel

ClearSubAreaTileLayout_Loop:
	LDA #BackgroundTile_Sky
	STA SubAreaTileLayout, X
	INX
	BNE ClearSubAreaTileLayout_Loop

	LDA CurrentLevelArea
	STA CurrentLevelAreaCopy
	LDA #$04 ; jar is always area 4
	STA CurrentLevelArea
IFNDEF CUSTOM_LEVEL_RLE
	LDA #$0A
	JSR HijackLevelDataCopyAddressWithJar

	LDY #$00
	LDA #$0A
	STA byte_RAM_E8
	STA byte_RAM_540
	STY byte_RAM_E6
	STY byte_RAM_E5
	STY GroundType
	LDY #$03
	STY GroundSetting
	LDY #$04
	JSR ReadLevelBackgroundData_Page

	; object type
	LDY #$02
	LDA (byte_RAM_5), Y
	AND #%00000011
	STA ObjectType3Xthru9X
	LDA (byte_RAM_5), Y
	LSR A
	LSR A
	AND #%00000011
	STA ObjectTypeAXthruFX
ENDIF
	JSR HijackLevelDataCopyAddressWithJar
	LDA #$0A
	STA byte_RAM_E8
	LDA #$00
	STA byte_RAM_E6
	STA byte_RAM_E5
IFDEF CUSTOM_LEVEL_RLE
	LDA #$01
	STA byte_RAM_4
	STA IsHorizontalLevel
	LDA #$0A
	STA Obj_Page
	STA PlayerXHi
	; Reset the tile placement offset for the second pass.
	JSR HijackLevelDataCopyAddressWithJar
	JSR ReadLevelForegroundData_FromLastPage
	RTS
ELSE
	LDA #$03
	STA byte_RAM_4
	JSR ReadLevelForegroundData_NextByteObject
	LDA #$01
	STA IsHorizontalLevel
	RTS
ENDIF

;
; Set the current background music to the current area's music as defined in the header.
;
; This stops the current music unless the player is currently invincible.
;
LoadAreaMusic:
IFNDEF CUSTOM_LEVEL_RLE
	LDY #$03
	LDA (byte_RAM_5), Y
ELSE
	LDY #$01
	LDA (byte_RAM_5), Y
ENDIF
	AND #%00000011
	STA CompareMusicIndex
	CMP CurrentMusicIndex
	BEQ LoadAreaMusic_Exit

	LDA StarInvincibilityTimer
	CMP #$08
	BCS LoadAreaMusic_Exit

	LDA #Music2_StopMusic
	STA MusicQueue2

LoadAreaMusic_Exit:
	RTS


;
; Unreferenced? A similar routine exists in Bank F, so it seems like this may
; be leftover code from a previous version.
;
Unused_LevelMusicIndexes:
	.db Music1_Overworld
	.db Music1_Inside
	.db Music1_Boss
	.db Music1_Wart
	.db Music1_Subspace

Unused_ChangeAreaMusic:
	LDA CompareMusicIndex
	CMP CurrentMusicIndex
	BEQ Unused_ChangeAreaMusic_Exit

	TAX
	STX CurrentMusicIndex
	LDA StarInvincibilityTimer
	CMP #$08
	BCS LoadAreaMusic_Exit

	LDA Unused_LevelMusicIndexes, X
	STA MusicQueue1

Unused_ChangeAreaMusic_Exit:
	RTS

; Unreferenced?
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