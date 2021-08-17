;
; ## Area loading and rendering
;
; This is the main subroutine for parsing and rendering an entire area of a level.
;
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

	;
	; Load initial ground appearance, which determines the tiles used for the background.
	;
	LDY #$03
	LDA (byte_RAM_5), Y
IFNDEF LEVEL_ENGINE_UPGRADES
	LSR A
	AND #%00011100
ELSE
	; double available ground types
	AND #%11110000
	LSR A
	LSR A
ENDIF

	STA GroundType

	; This doesn't hurt, but shouldn't be necessary.
	JSR RestoreLevelDataCopyAddress

IFDEF ENABLE_LEVEL_OBJECT_MODE
	; Read level object mode.
	LDA (byte_RAM_5), Y
	LSR A
	LSR A
	AND #%00000011
	STA LevelObjectMode
ENDIF

	; Determine whether this area is Horizontal or vertical.
	LDY #$00
	LDA (byte_RAM_5), Y
	ASL A
	LDA #$00
	ROL A
	STA IsHorizontalLevel

	; Reset the area page so that we can start drawing from the beginning.
	LDA #$00
	STA byte_RAM_E8

	; Determine the level length (in pages).
	LDY #$02
	LDA (byte_RAM_5), Y
	LSR A
	LSR A
	LSR A
	LSR A
	STA CurrentLevelPages

	; Determine the object types, which are used to determine which horizontal and vertical blocks are
	; used, as well as how some climbable objects appear.
	LDA (byte_RAM_5), Y
	AND #%00000011
	STA ObjectType3Xthru9X
	LDA (byte_RAM_5), Y
	LSR A
	LSR A
	AND #%00000011
	STA ObjectTypeAXthruFX
	DEY

IFDEF AREA_HEADER_TILESET
	; World tileset to use for the area.
	LDA (byte_RAM_5), Y
	ROL A
	ROL A
	ROL A
	ROL A
	AND #%00000111
	CMP #$07 ; only $00-06 are valid, force $07 to CurrentWorld
	BCC LoadCurrentArea_IsValid
	LDA CurrentWorld
LoadCurrentArea_IsValid:
	STA CurrentWorldTileset
ENDIF

	; Load initial ground setting, which determines the shape of the ground layout.
	;
	; Using `$1F` skips rendering ground settings entirely, but no areas seem to use it.
	LDA (byte_RAM_5), Y
	AND #%00011111
	CMP #%00011111
	BEQ LoadCurrentArea_ForegroundData

	STA GroundSetting

	;
	; ### Process level data
	;
	; The area is rendered in two passes (with the exception described above).
	;

	;
	; #### First pass: background terrain
	;
	; The first pass applies the ground settings and appearance to the entire area. This makes sure
	; that the ground is already in place when rendering objects that extend to the ground, such as
	; trees, vines, and platforms.
	;

	; Advance to the first object in the level data.
	INY
	INY
	INY

	; Reset the tile placement offset for the first pass.
	LDA #$00
	STA byte_RAM_E5
	STA byte_RAM_E6

	; Run the first pass of level rendering to apply ground settings and appearance.
	JSR ReadLevelBackgroundData

	;
	; #### Second pass: foreground objects
	;
	; The second pass renders normal level objects and sets up area pointers.
	;
LoadCurrentArea_ForegroundData:
	; Reset the tile placement offset for the second pass.
	LDA #$00
	STA byte_RAM_E6

	; Advance to the first object in the level data.
	LDA #$03
	STA byte_RAM_4

	; Run the second pass of level rendering to place regular objects in the level.
	JSR ReadLevelForegroundData

	; Bootstrap the pseudo-random number generator.
	LDA #$22
	ORA byte_RAM_10
	STA PseudoRNGValues
	RTS

.include "src/level_gen/restore_address.asm"

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

	; weird? the next lines do nothing
	LDY #$00
	JMP ReadLevelForegroundData_NextByteObject

ReadLevelForegroundData_NextByteObject:
	LDY byte_RAM_4

ReadLevelForegroundData_NextByte:
	INY
	LDA (byte_RAM_5), Y
	CMP #$FF
	BNE ReadLevelForegroundData_ProcessObject
	; Encountering `$FF` indicates the end of the level data.
	RTS

ReadLevelForegroundData_ProcessObject:
	; Stash the lower nybble of the first byte.
	; For a special object, this will be the special object type.
	; For a regular object, this will be the X position.
	LDA (byte_RAM_5), Y
	AND #$0F
	STA byte_RAM_E5
	; If the upper nybble of the first byte is $F, this is a special object.
	LDA (byte_RAM_5), Y
	AND #$F0
	CMP #$F0
	BNE ReadLevelForegroundData_RegularObject

ReadLevelForegroundData_SpecialObject:
	LDA byte_RAM_E5
	STY byte_RAM_F
	JSR ProcessSpecialObjectForeground

	LDY byte_RAM_F
	JMP ReadLevelForegroundData_NextByte

ReadLevelForegroundData_RegularObject:
	JSR UpdateAreaYOffset

	; check object type
	INY
	; upper nybble
	LDA (byte_RAM_5), Y
	LSR A
	LSR A
	LSR A
	LSR A
	STA byte_RAM_50E
	CMP #$03
	BCS ReadLevelForegroundData_RegularObjectWithSize

ReadLevelForegroundData_RegularObjectNoSize:
	PHA
	LDA (byte_RAM_5), Y
	AND #$0F
	STA byte_RAM_50E
	PLA
	BEQ ReadLevelForegroundData_RegularObjectNoSize_00

	PHA
	JSR SetTileOffsetAndAreaPageAddr_Bank6

	LDA (byte_RAM_5), Y
	AND #$0F
	STY byte_RAM_4
	PLA
	CMP #$01
	BNE ReadLevelForegroundData_RegularObjectNoSize_Not10

ReadLevelForegroundData_RegularObjectNoSize_10:
	JSR CreateObjects_10
	JMP ReadLevelForegroundData_RegularObject_Exit

ReadLevelForegroundData_RegularObjectNoSize_Not10:
	CMP #$02
	BNE ReadLevelForegroundData_RegularObjectNoSize_Not20

ReadLevelForegroundData_RegularObjectNoSize_20:
	JSR CreateObjects_20
	JMP ReadLevelForegroundData_RegularObject_Exit

ReadLevelForegroundData_RegularObjectNoSize_Not20:
	JMP ReadLevelForegroundData_RegularObject_Exit

ReadLevelForegroundData_RegularObjectWithSize:
	LDA (byte_RAM_5), Y
	AND #$0F
	STA byte_RAM_50D
	STY byte_RAM_4
	JSR SetTileOffsetAndAreaPageAddr_Bank6

	LDA byte_RAM_50E
	SEC
	SBC #$03
	STA byte_RAM_50E
	JSR CreateObjects_30thruF0

ReadLevelForegroundData_RegularObject_Exit:
	JMP ReadLevelForegroundData_NextByteObject

ReadLevelForegroundData_RegularObjectNoSize_00:
	JSR SetTileOffsetAndAreaPageAddr_Bank6

	LDA (byte_RAM_5), Y
	AND #$0F
	STY byte_RAM_4
	JSR CreateObjects_00

	JMP ReadLevelForegroundData_RegularObject_Exit

;
; Updates the area Y offset for object placement
;
; ##### Input
; - `A`: vertical offset
;
UpdateAreaYOffset:
	CLC
	ADC byte_RAM_E6
	BCC UpdateAreaYOffset_SamePage

	ADC #$0F
	JMP UpdateAreaYOffset_NextPage

UpdateAreaYOffset_SamePage:
	CMP #$F0
	BNE UpdateAreaYOffset_Exit

	LDA #$00

UpdateAreaYOffset_NextPage:
	INC byte_RAM_E8

UpdateAreaYOffset_Exit:
	STA byte_RAM_E6
	RTS



;
; Processes special objects for the second pass, which draws object tiles.
;
; On this pass, ground setting tiles are ignored, and we're just eating the bytes, but page skip
; objects still require updating the tile placement cursor.
;
; Area pointers are also processed in this pass. Although they _could_ be processed earlier, this
; reduces the likelihood of being overridden by a door pointer.
;
ProcessSpecialObjectForeground:
	JSR JumpToTableAfterJump

	.dw EatLevelObject1Byte ; Ground setting 0-8
	.dw EatLevelObject1Byte ; Ground setting 9-15
	.dw SkipForwardPage1Foreground ; Skip forward 1 page
	.dw SkipForwardPage2Foreground ; Skip forward 2 pages
	.dw ResetPageAndOffsetForeground ; New object layer
	.dw SetAreaPointer ; Area pointer
	.dw EatLevelObject1Byte ; Ground appearance
IFDEF LEVEL_ENGINE_UPGRADES
	.dw CreateRawTiles
ENDIF


;
; Processes special objects for the first pass, which draws ground layout tiles.
;
ProcessSpecialObjectBackground:
	JSR JumpToTableAfterJump

	.dw SetGroundSettingA ; Ground setting 0-7
	.dw SetGroundSettingB ; Ground setting 8-15
	.dw SkipForwardPage1Background ; Skip forward 1 page
	.dw SkipForwardPage2Background ; Skip forward 2 pages
	.dw ResetPageAndOffsetBackground ; New object layer
	.dw SetAreaPointerNoOp ; Area pointer
	.dw SetGroundType ; Ground appearance
IFDEF LEVEL_ENGINE_UPGRADES
	.dw CreateRawTilesNoOp
ENDIF


;
; #### Special Object `$F2` / `$F3`: Skip Page (Foreground)
;
; Moves the tile placement cursor forward one or two pages in the foregorund pass.
;
; ##### Output
;
; - `byte_RAM_E8`: area page
; - `byte_RAM_E6`: tile placement offset
;
;

SkipForwardPage2Foreground:
	INC byte_RAM_E8

SkipForwardPage1Foreground:
	INC byte_RAM_E8
	LDA #$00
	STA byte_RAM_E6
	RTS


;
; #### Special Object `$F2` / `$F3`: Skip Page (Background)
;
; Moves the tile placement cursor forward one or two pages in the background pass.
;
; ##### Output
;
; - `byte_RAM_540`: area page
; - `byte_RAM_E`: tile placement offset
; - `byte_RAM_9`: tile placement offset (overflow counter)
;

SkipForwardPage2Background:
	INC byte_RAM_540

SkipForwardPage1Background:
	INC byte_RAM_540
	LDA #$00
	STA byte_RAM_E
	STA byte_RAM_9
	RTS

;
; Advances two bytes in the level data.
;
; Unreferenced?
;
EatLevelObject2Bytes:
	INC byte_RAM_F

;
; Advances one byte in the level data.
;
EatLevelObject1Byte:
	INC byte_RAM_F
	RTS


;
; #### Area Pointer Object `$F5`
;
; Sets the area pointer for this page.
;
; ##### Input
; - `byte_RAM_F`: level data byte offset
; - `byte_RAM_E8`: area page
;
; ##### Output
; - `byte_RAM_F`: level data byte offset
;
SetAreaPointer:
	LDY byte_RAM_F
	INY
	LDA byte_RAM_E8
	ASL A
	TAX
	LDA (byte_RAM_5), Y
	STA AreaPointersByPage, X
	INY
	INX
	LDA (byte_RAM_5), Y
	STA AreaPointersByPage, X
	STY byte_RAM_F
	RTS


IFDEF LEVEL_ENGINE_UPGRADES
;
; #### Special Object `$F7`
;
; Creates a run of 1-16 arbitrary tiles.
;
; #### Usage: `$F7 $YX $WL ...`
; - `Y`: relative Y offset on page
; - `X`: X position on page
; - `W`: wrap width (eg. 0 for no wrap, 2 for 2-tiles wide, etc.)
; - `L`: run length, L+1 subsequent bytes are the raw tiles
;
CreateRawTiles:
	LDY byte_RAM_F

	; setting the page address allows this to be the first object of an area
	LDX byte_RAM_E8
	JSR SetAreaPageAddr_Bank6

	INY
	; read tile placement offset
	LDA (byte_RAM_5), Y
	CLC
	ADC byte_RAM_E6 ; add current offset
	STA byte_RAM_E7 ; target tile placement offset

	; apply page Y offset
	LDA (byte_RAM_5), Y
	AND #$F0
	JSR UpdateAreaYOffset

	INY
	; read run length
	LDA (byte_RAM_5), Y
	AND #$0F
	STA byte_RAM_50D

	; read wrap length
	LDA (byte_RAM_5), Y
	LSR A
	LSR A
	LSR A
	LSR A
	STA byte_RAM_50E

	; start counting from 0
	LDX #$00

	; everything afterwards is raw data
CreateRawTiles_Loop:
	; increment and stash Y
	INY
	TYA
	PHA

	; write the next tile
	LDA (byte_RAM_5), Y
	LDY byte_RAM_E7
	STA (byte_RAM_1), Y

	; increment x-position (crossing page as necessary)
	JSR IncrementAreaXOffset
	STY byte_RAM_E7

	; are we wrapping this run of tiles?
	LDA byte_RAM_50E
	BEQ CreateRawTiles_NoWrap

	; increment y-position if we hit the wrap point
	TXA
	CLC
	ADC #$01
CreateRawTiles_CheckWrap:
	SEC
	SBC byte_RAM_50E
	BMI CreateRawTiles_NoWrap
	BNE CreateRawTiles_CheckWrap

CreateRawTiles_Wrap:
	TXA
	PHA
	JSR IncrementAreaYOffset
	SEC
	SBC byte_RAM_50E
	TAY
	STY byte_RAM_E7
	PLA
	TAX

CreateRawTiles_NoWrap:
	; restore Y and iterate
	PLA
	TAY

	CPX byte_RAM_50D
	INX
	BCC CreateRawTiles_Loop

	; update level data offset
	STY byte_RAM_F

CreateRawTilesNoOp:
	RTS
ENDIF


;
; Use top 3 bits for the X offset of a ground setting object
;
; ##### Output
; - `A`: 0-7
;
ReadGroundSettingOffset:
	LDY byte_RAM_F
	INY
	LDA (byte_RAM_5), Y
	AND #%11100000
	LSR A
	LSR A
	LSR A
	LSR A
	LSR A
	RTS

;
; #### Special Object `$F0` / `$F1`: Ground Setting
;
; Sets ground setting at some relative offset on the current page.
;
; Object `$F0` can change the ground setting for offsets 0 through 7.
; Object `$F1` can change the ground setting for offsets 8 through 15.
;
; #### Input
; - `A`: Relative offset (0-7)
; - `byte_RAM_F`: level data byte offset
;
; #### Output
; - `byte_RAM_E`: tile placement offset
;
SetGroundSettingA:
	JSR ReadGroundSettingOffset
	JMP SetGroundSetting

SetGroundSettingB:
	JSR ReadGroundSettingOffset
	CLC
	ADC #$08

SetGroundSetting:
	STA byte_RAM_E
	LDA IsHorizontalLevel
	BNE SetGroundSetting_Exit

	LDA byte_RAM_E
	ASL A
	ASL A
	ASL A
	ASL A
	STA byte_RAM_E

SetGroundSetting_Exit:
	RTS


;
; #### Special Object `$F4`: New Layer (Foreground)
;
; Moves the tile placement cursor to the beginning of the first page in the foreground pass.
;
; ##### Output
;
; - `byte_RAM_E8`: area page
; - `byte_RAM_E6`: tile placement offset
;
ResetPageAndOffsetForeground:
	LDA #$00
	STA byte_RAM_E8 ; area page
	STA byte_RAM_E6 ; tile placement offset
	RTS


;
; #### Special Object `$F4`: New Layer (Background)
;
; Moves the tile placement cursor to the beginning of the first page in the background pass.
;
; ##### Output
;
; - `byte_RAM_540`: area page
; - `byte_RAM_E`: tile placement offset
;
ResetPageAndOffsetBackground:
	LDA #$00
	STA byte_RAM_540
	STA byte_RAM_E
	RTS


;
; Area pointers are not processed on the background pass.
;
SetAreaPointerNoOp:
	RTS


;
; #### Ground Appearance Object `$F6`
;
; Sets the ground appearance, which determines the tiles used when drawing the ground setting.
;
; ##### Output
;
; `GroundType`: the ground type used for drawing the background
;
SetGroundType:
	LDY byte_RAM_F
	INY
	LDA (byte_RAM_5), Y
	AND #%00001111
	ASL A
	ASL A
	STA GroundType
	RTS


;
; ### Render background level data
;
; Reads level data from the beginning and processes the ground layout.
;
; This first pass is used for setting up the ground types and settings before normal objects are
; rendered in the level.
;
; ##### Input
; - `Y`: raw data offset
;
ReadLevelBackgroundData:
	LDA #$00
	STA byte_RAM_540

ReadLevelBackgroundData_Page:
	LDA #$00
	STA byte_RAM_9

ReadLevelBackgroundData_Object:
	LDA (byte_RAM_5), Y
	CMP #$FF
	BNE ReadLevelBackgroundData_ProcessObject

	; Encountering `$FF` indicates the end of the level data.
	; We need to render the remaining ground setting through the end of the last page in the area.
	LDA #$0A
	STA byte_RAM_540
	INC byte_RAM_540
	LDA #$00
	STA byte_RAM_E
	JMP ReadLevelBackgroundData_RenderGround

ReadLevelBackgroundData_ProcessObject:
	LDA (byte_RAM_5), Y
	AND #$F0
	BEQ ReadLevelBackgroundData_ProcessObject_Advance2Bytes

	CMP #$F0
	BNE ReadLevelBackgroundData_ProcessRegularObject

;
; First byte of `$FX` indicates a special object.
;
ReadLevelBackgroundData_ProcessSpecialObject:
	LDA (byte_RAM_5), Y
	AND #$0F
	STY byte_RAM_F
	JSR ProcessSpecialObjectBackground

	; Determine how many more bytes to advance after processing the special object.
	LDY byte_RAM_F
	LDA (byte_RAM_5), Y
	AND #$0F

	; Ground setting `$F0` / `$F1` should render the previous ground setting
	CMP #$02
	BCC ReadLevelBackgroundData_RenderGround

	; Special objects except `$F0` / `$F1`
	CMP #$05
	BNE ReadLevelBackgroundData_ProcessObject_NotF5

ReadLevelBackgroundData_ProcessObject_Advance3Bytes:
	INY
	JMP ReadLevelBackgroundData_ProcessObject_Advance2Bytes

ReadLevelBackgroundData_ProcessObject_NotF5:
	; Special objects except `$F0` / `$F1` / `$F5`
	CMP #$06
	BNE ReadLevelBackgroundData_ProcessObject_AdvanceByte

; Ground appearance `$F6` is two bytes.
ReadLevelBackgroundData_ProcessObject_Advance2Bytes:
	INY

ReadLevelBackgroundData_ProcessObject_AdvanceByte:
	INY
	JMP ReadLevelBackgroundData_Object

;
; Processes a regular object, as indicated by a value of `$0X-$EX` in the first byte.
;
; ##### Input
; - `byte_RAM_9`: tile placement offset (overflow counter)
;
; ##### Output
; - `byte_RAM_540`: area page
; - `byte_RAM_9`: tile placement offset (overflow counter)
;
; Since we're only processing background objects, all this needs to do is look at the object offset
; and advance the tile placement cursor and current page as needed.
;
; #### The Door Pointer Y Offset "Bug"
;
; An interesting quirk about the level engine is that door pointers are used in worlds 1-5, but not
; worlds 6 and 7, due to the fact that the pointers have an effective Y offset of 1.
;
; The developers chose to disable door pointers to deal with this problem, but another solution
; would have been to modify the code here to determine whether an object was being used as a door
; pointer and avoid processing its position offset.
;
ReadLevelBackgroundData_ProcessRegularObject:
	CLC
	ADC byte_RAM_9
	BCC ReadLevelBackgroundData_ProcessRegularObject_SamePage

	; The object position overflowed to the next page.
	ADC #$0F
	JMP ReadLevelBackgroundData_ProcessRegularObject_NextPage

ReadLevelBackgroundData_ProcessRegularObject_SamePage:
	CMP #$F0
	BNE ReadLevelBackgroundData_ProcessRegularObject_Exit

	LDA #$00

ReadLevelBackgroundData_ProcessRegularObject_NextPage:
	INC byte_RAM_540

ReadLevelBackgroundData_ProcessRegularObject_Exit:
	STA byte_RAM_9
	JMP ReadLevelBackgroundData_ProcessObject_Advance2Bytes


;
; Renders the ground setting up to this point.
;
; This code is invoked when we encounter a ground setting object and need to render the previous
; ground setting up tothis point or when we have reached the end of the level data and need to
; render the current ground setting through the end of the area.
;
; #### Input
; - `byte_RAM_E8`: area page
; - `byte_RAM_E5`: tile placement offset shift
; - `byte_RAM_E6`: previous tile placement offset
; - `byte_RAM_540`: area page (end)
; - `byte_RAM_E`: tile placement offset (end)
;
; #### Output
;
ReadLevelBackgroundData_RenderGround:
	JSR SetTileOffsetAndAreaPageAddr_Bank6

	JSR LoadGroundSetData

	LDA IsHorizontalLevel
	BEQ ReadLevelBackgroundData_RenderGround_Vertical

ReadLevelBackgroundData_RenderGround_Horizontal:
	; Increment the column.
	INC byte_RAM_E5
	LDA byte_RAM_E5
	CMP #$10
	BNE ReadLevelBackgroundData_RenderGround_CheckComplete

	; Increment the page and reset to the first column.
	INC byte_RAM_E8
	LDA #$00
	STA byte_RAM_E5
	JMP ReadLevelBackgroundData_RenderGround_CheckComplete


ReadLevelBackgroundData_RenderGround_Vertical:
	; Increment the row.
	LDA #$10
	JSR UpdateAreaYOffset

ReadLevelBackgroundData_RenderGround_CheckComplete:
	; If there are more pages to render with this ground setting, keep going.
	LDA byte_RAM_E8
	CMP byte_RAM_540
	BNE ReadLevelBackgroundData_RenderGround

	LDA IsHorizontalLevel
	BEQ ReadLevelBackgroundData_RenderGround_CheckComplete_Vertical

ReadLevelBackgroundData_RenderGround_CheckComplete_Horizontal:
	; If there is more to render with this ground setting, keep going.
	LDA byte_RAM_E5
	CMP byte_RAM_E
	BCC ReadLevelBackgroundData_RenderGround

	; Otherwise, move on and process the next object.
	BCS ReadLevelBackgroundData_RenderGround_Exit

ReadLevelBackgroundData_RenderGround_CheckComplete_Vertical:
	LDA byte_RAM_E6
	CMP byte_RAM_E
	BCC ReadLevelBackgroundData_RenderGround

ReadLevelBackgroundData_RenderGround_Exit:
	LDA (byte_RAM_5), Y
	; Encountering `$FF` indicates the end of the level data.
	CMP #$FF
	BEQ ReadGroundSetByte_Exit

	; Otherwise this was triggered because we encountered a ground setting object, so `GroundSetting`
	; for the next time we need to render the ground.
	INY
	LDA (byte_RAM_5), Y
	AND #$1F
	STA GroundSetting
	JMP ReadLevelBackgroundData_ProcessObject_AdvanceByte

; -----


;
; Reads the current ground setting byte.
;
; ##### Input
; - `X`: Ground setting offset
;
; ##### Output
; - `A`: Byte containing the 4 ground appearance bit pairs for the offset
;
ReadGroundSetByte:
	LDA IsHorizontalLevel
	BNE ReadGroundSetByte_Vertical

	LDA VerticalGroundSetData, X
	RTS

ReadGroundSetByte_Vertical:
	LDA HorizontalGroundSetData, X

ReadGroundSetByte_Exit:
	RTS


;
; Draws the current ground setting and type to the raw tile buffer.
;
; ##### Input
; - `GroundSetting`: current ground setting
; - `GroundType`: current ground appearance
; - `byte_RAM_E7`: tile placement offset
;
LoadGroundSetData:
	STY byte_RAM_4
	LDA GroundSetting
	ASL A
	ASL A
	TAX
	LDY byte_RAM_E7

LoadGroundSetData_Loop:
	JSR ReadGroundSetByte

	JSR WriteGroundSetTiles1

	JSR ReadGroundSetByte

	JSR WriteGroundSetTiles2

	JSR ReadGroundSetByte

	JSR WriteGroundSetTiles3

	JSR ReadGroundSetByte

	JSR WriteGroundSetTiles4

	LDA IsHorizontalLevel
	BEQ LoadGroundSetData_Horizontal

	INX
	BCS LoadGroundSetData_Exit

	BCC LoadGroundSetData_Loop

LoadGroundSetData_Horizontal:
	INX
	TYA
	AND #$0F
	BNE LoadGroundSetData_Loop

LoadGroundSetData_Exit:
	LDY byte_RAM_4
	RTS

;
; Draws current ground set tiles.
;
WriteGroundSetTiles:
WriteGroundSetTiles1:
	LSR A
	LSR A

WriteGroundSetTiles2:
	LSR A
	LSR A

WriteGroundSetTiles3:
	LSR A
	LSR A

WriteGroundSetTiles4:
	AND #$03
	STX byte_RAM_3
	; This `BEQ` is what effectively ignores the first index of the groundset tiles lookup tables.
	BEQ WriteGroundSetTiles_AfterWriteTile

	CLC
	ADC GroundType
	TAX
	LDA IsHorizontalLevel
	BNE WriteGroundSetTiles_Horizontal

	JSR ReadGroundTileVertical

	JMP WriteGroundSetTiles_WriteTile

WriteGroundSetTiles_Horizontal:
	JSR ReadGroundTileHorizontal

WriteGroundSetTiles_WriteTile:
	STA (byte_RAM_1), Y

WriteGroundSetTiles_AfterWriteTile:
	LDX byte_RAM_3
	LDA IsHorizontalLevel
	BNE WriteGroundSetTiles_IncrementYOffset

	INY
	RTS

WriteGroundSetTiles_IncrementYOffset:
	TYA
	CLC
	ADC #$10
	TAY
	RTS


ReadGroundTileHorizontal:
	STX byte_RAM_C
	STY byte_RAM_D
	LDX CurrentWorldTileset
	LDA GroundTilesHorizontalLo, X
	STA byte_RAM_7
	LDA GroundTilesHorizontalHi, X
	STA byte_RAM_8
	LDY byte_RAM_C
	LDA (byte_RAM_7), Y
	LDX byte_RAM_C
	LDY byte_RAM_D
	RTS


ReadGroundTileVertical:
	STX byte_RAM_C
	STY byte_RAM_D
	LDX CurrentWorldTileset
	LDA GroundTilesVerticalLo, X
	STA byte_RAM_7
	LDA GroundTilesVerticalHi, X
	STA byte_RAM_8
	LDY byte_RAM_C
	LDA (byte_RAM_7), Y
	LDX byte_RAM_C
	LDY byte_RAM_D
	RTS

.include "src/level_gen/set_page_offset.asm"

IFNDEF DISABLE_DOOR_POINTERS
;
; Consume the object as an area pointer. This overwrites any existing area
; pointer for this page.
;
LevelParser_EatDoorPointer:
	LDY byte_RAM_4
	INY
	LDA (byte_RAM_5), Y
	STA byte_RAM_7
	INY
	LDA (byte_RAM_5), Y
	STA byte_RAM_8
	STY byte_RAM_4
	LDA byte_RAM_E8
	ASL A
	TAY
	LDA byte_RAM_7
	STA AreaPointersByPage, Y
	INY
	LDA byte_RAM_8
	STA AreaPointersByPage, Y
	RTS
ENDIF
