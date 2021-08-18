;
; Performs an area transition
;
ApplyAreaTransition:
	LDA TransitionType
	CMP #TransitionType_Jar
	BNE ApplyAreaTransition_NotJar

ApplyAreaTransition_Jar:
	LDA InJarType
	BNE ApplyAreaTransition_NotJar

	JSR RestorePlayerPosition

	JMP ApplyAreaTransition_MoveCamera

ApplyAreaTransition_NotJar:
	LDA CurrentLevelEntryPage
	LDY #$00
	LDX IsHorizontalLevel
	BNE ApplyAreaTransition_Horizontal

ApplyAreaTransition_Vertical:
	STY PlayerXHi
	STA PlayerYHi
	BEQ ApplyAreaTransition_SetPlayerPosition

ApplyAreaTransition_Horizontal:
	STA PlayerXHi
	STY PlayerYHi

ApplyAreaTransition_SetPlayerPosition:
	JSR AreaTransitionPlacement

	; The height of a page is only `$0F` tiles instead of `$10`.
	; PlayerYHi is currently using the vertical page rather than the actual high
	; byte of the absolute position, so we need to convert it to compensate!
	LDY PlayerYHi
	LDA PlayerYLo
	JSR PageHeightCompensation
	STY PlayerYHi
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
	CMP #TransitionType_SubSpace
	BNE ApplyAreaTransition_MoveCamera

	JSR DoorAnimation_Unlocked

ApplyAreaTransition_MoveCamera:
	LDA PlayerXLo
	SEC
	SBC #$78
	STA MoveCameraX
	RTS


;
; Do the player placement after an area transition
;
AreaTransitionPlacement:
IFDEF LEVEL_FLAGS
    LDX #CustomBitFlag_Visited
    JSR ApplyFlagLevel
    BEQ +
	LDX CurrentCharacter
	INC CharacterLevelsCompleted, X
    INC Level_Count_Discovery
+
ENDIF
	LDA TransitionType
	JSR JumpToTableAfterJump

IFDEF RANDOMIZER_FLAGS
	.dw AreaTransitionPlacement_Reset
	.dw AreaTransitionPlacement_Randomizer
	.dw AreaTransitionPlacement_Jar
	.dw AreaTransitionPlacement_Randomizer
	.dw AreaTransitionPlacement_Subspace
	.dw AreaTransitionPlacement_Randomizer

AreaTransitionPlacement_Randomizer:
	LDA PlayerInRocket
    BEQ +
	LDA #$00
	STA PlayerInRocket
	STA HoldingItem
+
    STA PlayerState
	LDA #SpriteAnimation_Standing
	STA PlayerAnimationFrame
    JSR AreaTransitionPlacement_DoorCustom
    BCS +end

	JSR AreaTransitionPlacement_Climbing
	LDA PlayerAnimationFrame
	CMP #SpriteAnimation_Climbing
	BEQ +ok

    LDA #$0
    STA PlayerXLo
	STA PlayerYLo
	JSR AreaTransitionPlacement_ClimbingCustom
	BCS +ok
	LDA #$F0
	STA PlayerYLo
	JSR AreaTransitionPlacement_ClimbingCustom
	BCC +
+ok
	LDA #SpriteAnimation_Climbing
	STA PlayerAnimationFrame
    LDA #PlayerState_ClimbingAreaTransition
    STA PlayerState
	LDY #$1
	LDA PlayerYLo
	BPL ++
	INY
++  LDA ClimbSpeed, Y
	STA PlayerYVelocity
    BNE +end
+
    JSR AreaTransitionPlacement_Reset
+end
    RTS

AreaTransitionPlacement_Ground:
END

ELSE
	.dw AreaTransitionPlacement_Reset
	.dw AreaTransitionPlacement_Door
	.dw AreaTransitionPlacement_Jar
	.dw AreaTransitionPlacement_Climbing
	.dw AreaTransitionPlacement_Subspace
	.dw AreaTransitionPlacement_Rocket
ENDIF


AreaTransitionPlacement_Reset:
	LDA #$01
	STA PlayerDirection
	JSR AreaTransitionPlacement_Middle

	LSR A
	LSR A
	LSR A
	LSR A
	STA byte_RAM_E5
	LDA #$D0
	STA PlayerYLo
	STA byte_RAM_E6
	LDA CurrentLevelEntryPage
	STA byte_RAM_E8

IFDEF LEVEL_ENGINE_UPGRADES 
	LDX IsHorizontalLevel
	BEQ AreaTransitionPlacement_Reset_FindOpenSpace

	; Find non-sky to use as the ground
	LDA #$E0
	STA byte_RAM_E6

AreaTransitionPlacement_Reset_FindStandableTile:
	LDA #$0C
	STA byte_RAM_3
AreaTransitionPlacement_Reset_FindStandableTileLoop:
	JSR SetTileOffsetAndAreaPageAddr_Bank1

	LDY byte_RAM_E7
	LDA (byte_RAM_1), Y
	CMP #BackgroundTile_Sky
	BNE AreaTransitionPlacement_Reset_FindOpenSpaceLoop

	JSR AreaTransitionPlacement_MovePlayerUp1Tile

	STA byte_RAM_E6
	DEC byte_RAM_3
	BNE AreaTransitionPlacement_Reset_FindStandableTileLoop
ENDIF

;
; The player must start in empty space (not a wall)
;
AreaTransitionPlacement_Reset_FindOpenSpace:
	LDA #$0C
	STA byte_RAM_3
AreaTransitionPlacement_Reset_FindOpenSpaceLoop:
	JSR SetTileOffsetAndAreaPageAddr_Bank1

	LDY byte_RAM_E7
	LDA (byte_RAM_1), Y
	CMP #BackgroundTile_Sky
	BEQ AreaTransitionPlacement_MovePlayerUp1Tile

	JSR AreaTransitionPlacement_MovePlayerUp1Tile

	STA byte_RAM_E6
	DEC byte_RAM_3
	BNE AreaTransitionPlacement_Reset_FindOpenSpaceLoop


;
; Moves the player up by one tile
;
AreaTransitionPlacement_MovePlayerUp1Tile:
	LDA PlayerYLo
	SEC
	SBC #$10
	STA PlayerYLo
	RTS


;
; Looks for a door and positions the player at it
;
; The implementation of this requires the destination door to be at the
; OPPOSITE side of the screen from the origin door horizontally, but it can be
; at any position vertically.
;
; If no suitable door is found, the player is positioned to fall from the
; top-middle of the screen instead
;
AreaTransitionPlacement_Door:
	LDA PlayerXLo
	; Switch the x-position to the opposite side of the screen
	CLC
	ADC #$08
	AND #$F0
	EOR #$F0
	STA PlayerXLo

	; Convert to a tile offset
	LSR A
	LSR A
	LSR A
	LSR A
	STA byte_RAM_E5

	; Start at the bottom of the page
	LDA #$E0
	STA PlayerYLo
	STA byte_RAM_E6
	LDA CurrentLevelEntryPage
	STA byte_RAM_E8
	LDA #$0D
	STA byte_RAM_3

AreaTransitionPlacement_Door_Loop:
	JSR SetTileOffsetAndAreaPageAddr_Bank1

	; Read the target tile
	LDY byte_RAM_E7
	LDA (byte_RAM_1), Y
	LDY #$05

AreaTransitionPlacement_Door_InnerLoop:
	; See if it matches any door tile
	CMP DoorTiles - 1, Y
	BEQ AreaTransitionPlacement_Door_Exit
	DEY
	BNE AreaTransitionPlacement_Door_InnerLoop

	; Nothing matched on this row, so check the next row or give up
	DEC byte_RAM_3
IFNDEF ROBUST_TRANSITION_SEARCH
	BEQ AreaTransitionPlacement_Door_Fallback
ENDIF
IFDEF ROBUST_TRANSITION_SEARCH
	BEQ AreaTransitionPlacement_DoorCustom
ENDIF

	JSR AreaTransitionPlacement_MovePlayerUp1Tile

	STA byte_RAM_E6
	JMP AreaTransitionPlacement_Door_Loop

AreaTransitionPlacement_Door_Fallback:
	; Place in the middle of the screen if no door is found
	JSR AreaTransitionPlacement_Middle

AreaTransitionPlacement_Door_Exit:
	JSR AreaTransitionPlacement_MovePlayerUp1Tile

	LDA #$00
	STA PlayerLock
	RTS


IFDEF ROBUST_TRANSITION_SEARCH
;
; Looks for a door and positions the player at it
;
; In contrast to the normal door placement routine, this will search all
; x-positions rather than just one opposite the door
;
AreaTransitionPlacement_DoorCustom:
	; Start on the correct page
	LDX CurrentLevelEntryPage
	JSR SetAreaPageAddr_Bank1

	; Start at the bottom right and work backwards
	LDA #$EF
	STA byte_RAM_E7

AreaTransitionPlacement_DoorCustom_Loop:
	; Read the target tile
	LDY byte_RAM_E7
	LDA (byte_RAM_1), Y
	LDY #$05

AreaTransitionPlacement_DoorCustom_InnerLoop:
	; See if it matches any door tile
	CMP DoorTiles - 1, Y
	BEQ AreaTransitionPlacement_DoorCustom_Exit
	DEY
	BNE AreaTransitionPlacement_DoorCustom_InnerLoop

    CMP #BackgroundTile_JarTopPointer
    BNE +notjar 
	LDY #$00
	STY PlayerDucking
	STY PlayerYVelocity
	STY PlayerXVelocity
	LDA #PlayerState_ExitingJar
	STA PlayerState
	LDA #SpriteAnimation_Ducking
	STA PlayerAnimationFrame
    BNE AreaTransitionPlacement_DoorCustom_Exit
+notjar
	; No matches on this tile, check the next one or give up
	DEC byte_RAM_E7
	BEQ AreaTransitionPlacement_DoorCustom_Fallback

	BNE AreaTransitionPlacement_DoorCustom_Loop

AreaTransitionPlacement_DoorCustom_Fallback:
	LDA #$20
	STA PlayerYLo
	JSR AreaTransitionPlacement_Middle
	JSR AreaTransitionPlacement_MovePlayerUp1Tile
	LDA #$00
	STA PlayerLock
    CLC
    RTS

AreaTransitionPlacement_DoorCustom_Exit:
	LDA byte_RAM_E7
	ASL A
	ASL A
	ASL A
	ASL A
	STA PlayerXLo
	LDA byte_RAM_E7
	AND #$F0
	STA PlayerYLo
	JSR AreaTransitionPlacement_MovePlayerUp1Tile
	LDA #$00
	STA PlayerLock
    SEC
    RTS
ENDIF


;
; Place the player at the top of the screen in the middle horizontally
;
AreaTransitionPlacement_Jar:
	LDA #$00
	STA PlayerYLo

;
; Place the player in the air in the middle of the screen horizontally
;
AreaTransitionPlacement_Middle:
	LDA #$01
	STA PlayerInAir
	LDA #$78
	STA PlayerXLo
	RTS

;
; Looks for a climbable tile (vine/chain/ladder) and positions the player at it
;
; The implementation of this requires the destination to be at the OPPOSITE
; side of the screen from the origin horizontally, otherwise the player will
; be climbing on nothing.
;
AreaTransitionPlacement_Climbing:
	LDA PlayerXLo
	; Switch the x-position to the opposite side of the screen
	CLC
	ADC #$08
	AND #$F0
	EOR #$F0
	STA PlayerXLo

	; Switch the y-position to the opposite side of the screen
	LDA PlayerScreenYLo
	CLC
	ADC #$08
	AND #$F0
	EOR #$10
	STA PlayerYLo
	CMP #$F0
	BEQ AreaTransitionPlacement_Climbing_Exit

	DEC PlayerYHi

AreaTransitionPlacement_Climbing_Exit:
IFDEF ROBUST_TRANSITION_SEARCH
	JSR AreaTransitionPlacement_ClimbingCustom

	BCS AreaTransitionPlacement_Climbing_SetPlayerAnimationFrame

	; Try the opposite side of the screen
	LDA PlayerYLo
	EOR #$10
	STA PlayerYLo

	LDA PlayerYHi
	EOR #$FF
	STA PlayerYHi

	JSR AreaTransitionPlacement_ClimbingCustom
	BCC AreaTransitionPlacement_Climbing_UnreversePositionY

	; Found something on the opposite side, so flip Y velocity
	LDY #$01
	LDA PlayerYVelocity
	BMI AreaTransitionPlacement_Climbing_SetYVelocity

	INY
AreaTransitionPlacement_Climbing_SetYVelocity:
	LDA ClimbSpeed, Y
	STA PlayerYVelocity

	BNE AreaTransitionPlacement_Climbing_SetPlayerAnimationFrame

AreaTransitionPlacement_Climbing_UnreversePositionY:
	; Unflip Y position
	LDA PlayerYLo
	EOR #$10
	STA PlayerYLo

	LDA PlayerYHi
	EOR #$FF
	STA PlayerYHi

    RTS

AreaTransitionPlacement_Climbing_SetPlayerAnimationFrame:
ENDIF

	LDA #SpriteAnimation_Climbing
	STA PlayerAnimationFrame
	RTS


IFDEF ROBUST_TRANSITION_SEARCH
;
; Ouput
;   C = set if a climbable tile was found
;
AreaTransitionPlacement_ClimbingCustom:
	; Target x-position
	LDA PlayerXLo
	LSR A
	LSR A
	LSR A
	LSR A
	STA byte_RAM_E5

	; Target y-position
	LDA PlayerYLo
	EOR #$10
	CLC
	ADC #$10
	CMP #$F0
	BNE AreaTransitionPlacement_ClimbingCustom_AfterNudge
	SEC
	SBC #$10
AreaTransitionPlacement_ClimbingCustom_AfterNudge:
	STA byte_RAM_E6

	; Read the target tile
	LDA CurrentLevelEntryPage
	STA byte_RAM_E8
	JSR SetTileOffsetAndAreaPageAddr_Bank1
	LDY byte_RAM_E7
	LDA (byte_RAM_1), Y

	; Check if the target tile is climbable
	LDY #$09
AreaTransitionPlacement_ClimbingCustom_CheckLoop:
	CMP ClimbableTiles, Y
	BNE AreaTransitionPlacement_ClimbingCustom_LoopNext

	RTS

AreaTransitionPlacement_ClimbingCustom_LoopNext:
	DEY
	BPL AreaTransitionPlacement_ClimbingCustom_CheckLoop

	; Target tile is not climbable; start at the right and work backwards
	LDA byte_RAM_E7
	AND #$F0
	STA byte_RAM_E6

	LDA #$0F
	STA byte_RAM_3
	CLC
	ADC byte_RAM_E6
	STA byte_RAM_E7

AreaTransitionPlacement_ClimbingCustom_Loop:
	; Read the target tile
	LDY byte_RAM_E7
	LDA (byte_RAM_1), Y
	LDY #$09

AreaTransitionPlacement_ClimbingCustom_InnerLoop:
	CMP ClimbableTiles, Y
	BEQ AreaTransitionPlacement_ClimbingCustom_SetXPosition
	DEY
	BPL AreaTransitionPlacement_ClimbingCustom_InnerLoop

	; No matches on this tile, check the next one or give up
	DEC byte_RAM_E7
	DEC byte_RAM_3
	BMI AreaTransitionPlacement_ClimbingCustom_NotFound

	JMP AreaTransitionPlacement_ClimbingCustom_Loop

AreaTransitionPlacement_ClimbingCustom_SetXPosition:
	LDA byte_RAM_3
	ASL A
	ASL A
	ASL A
	ASL A
	STA PlayerXLo

	SEC
	RTS

AreaTransitionPlacement_ClimbingCustom_NotFound:
	CLC
	RTS
ENDIF


AreaTransitionPlacement_Subspace:
	LDA PlayerScreenX
	SEC
	SBC MoveCameraX
	EOR #$FF
	CLC
	ADC #$F1
	STA PlayerXLo
	LDA PlayerScreenYLo
	STA PlayerYLo
	DEC PlayerLock
	LDA #$60
	STA SubspaceTimer
	RTS


AreaTransitionPlacement_Rocket:
IFDEF RANDOMIZER_FLAGS
	LDA #$00
	STA PlayerInRocket
	STA HoldingItem
	STA PlayerXVelocity
ENDIF
	JSR AreaTransitionPlacement_Middle
	LDA #$60
	STA PlayerYLo
	RTS


;
; Converts a y-position from page+offset to hi+lo coordinates, compensating for
; the fact that a page height is only $0F tiles, not a full $10.
;
; ##### Input
; - `Y`: page
; - `A`: position on page
;
; ##### Output
; - `Y`: hi position
; - `A`: lo position
;
PageHeightCompensation:
	; If player is above the top, exit
	CPY #$00
	BMI PageHeightCompensation_Exit

	; Convert page to number of tiles
	PHA
	TYA
	ASL A
	ASL A
	ASL A
	ASL A
	STA byte_RAM_F
	PLA

	; Subtract the tiles from the position
	SEC
	SBC byte_RAM_F
	BCS PageHeightCompensation_Exit

	; Carry to the high byte
	DEY

PageHeightCompensation_Exit:
	RTS