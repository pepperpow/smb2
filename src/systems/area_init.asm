;
; Init
;
AreaInitialization:
	INC AreaInitialized
	STA byte_RAM_5BA
	STA POWQuakeTimer
	STA SkyFlashTimer
	STA CrystalAndHawkmouthOpenSize
	STA HawkmouthClosing
	STA SwarmType
	STA HawkmouthOpenTimer
	STA ScrollXLock
	STA VerticalScrollDirection
	STA PlayerXVelocity
	STA DamageInvulnTime
	STA HoldingItem
	STA PlayerStateTimer
	STA BackgroundYOffset
	STA PokeyTempScreenX
	STA CrouchJumpTimer
	STA JumpFloatTimer
	STA QuicksandDepth
	STA BossBeaten
IFDEF RANDOMIZER_FLAGS
    STA SubspaceVisits
	STA KeyUsed
	STA Mushroom1upPulled
	STA Mushroom1Pulled
	STA Mushroom1Pulled + 1

	LDY CurrentLevelAreaIndex
	LDA Level_Bit_Flags, Y
	AND #CustomBitFlag_Crystal
	BEQ +
    INC CrystalAndHawkmouthOpenSize
+   
	LDA Level_Bit_Flags, Y
	AND #CustomBitFlag_Sub2
    BEQ +
    LDA #$2
    STA SubspaceVisits
+   
	LDA Level_Bit_Flags, Y
	AND #CustomBitFlag_Key
    BEQ +
    INC KeyUsed
+   
	LDA Level_Bit_Flags, Y
	AND #CustomBitFlag_1up
    BEQ +
    INC Mushroom1upPulled
+   
	LDA Level_Bit_Flags, Y
	AND #CustomBitFlag_Mush1
    BEQ +
    INC Mushroom1Pulled
+   
	LDA Level_Bit_Flags, Y
	AND #CustomBitFlag_Mush2
    BEQ +
    INC Mushroom1Pulled + 1
+   
ENDIF
IFDEF TRANSITION_INVULN
    LDA TransitionType
    CMP #TransitionType_SubSpace
    BEQ +
    LDA #$20
    STA AreaTransitioned_Invuln
+
ENDIF 

IFDEF RESET_CHR_LATCH
	LDY #$FF
	STY BossTileset
	INC ResetCHRLatch
ENDIF

	LDY #$1B
AreaInitialization_CarryYOffsetLoop:
	; Copy the global carrying Y offsets to memory
	; These are used for every character for different frames of the pickup animation
	LDA ItemCarryYOffsets, Y
	STA ItemCarryYOffsetsRAM, Y
	DEY
	BPL AreaInitialization_CarryYOffsetLoop

IFDEF CONTROLLER_2_DEBUG
	JSR CopyCarryYOffsets
ENDIF

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

	LDA #$B6
	STA PseudoRNGValues
	LDA TransitionType

	; Play the slide-whistle when you start the game and drop into 1-1
	ORA CurrentLevel
	BNE AreaInitialization_CheckObjectCarriedOver

	LDA #SoundEffect2_IntroFallSlide
	STA SoundEffectQueue2

AreaInitialization_CheckObjectCarriedOver:
IFDEF PHANTO_CUSTOM
	LDX #$05
	STX byte_RAM_12
	LDA ObjectCarriedOver
	BEQ AreaInitialization_Phantop
ELSE
	LDA ObjectCarriedOver
	BEQ AreaInitialization_SetEnemyData
ENDIF

	LDX #$05
	STX byte_RAM_12
	CMP #Enemy_Mushroom
	BEQ AreaInitialization_SetEnemyData

	STA ObjectType, X
	LDY #EnemyState_Alive
	STY EnemyState + 5
	LDY #$FF
	STY EnemyRawDataOffset + 5
	CMP #Enemy_Rocket
	BNE AreaInitialization_NonRocketCarryOver

AreaInitialization_Rocket:
	; A = $38 (Enemy_Rocket)
	; X = $05 (from above)
	STA EnemyArray_B1, X
	STA PlayerInRocket, X ; Bug? This sets ObjectXAcceleration for enemy 0
	STA EnemyArray_477, X
	LDA #$00
	STA ObjectXHi, X
	STA ObjectYHi, X
	JSR SetEnemyAttributes

	LDA #$F0
	STA ObjectYVelocity, X
	ASL A
	STA ObjectYLo, X
	LDA #$78
	STA ObjectXLo, X
IFDEF PHANTO_CUSTOM
	BNE AreaInitialization_Phantop
ENDIF
	BNE AreaInitialization_SetEnemyData

AreaInitialization_NonRocketCarryOver:
	PHA
	STX ObjectBeingCarriedIndex
	JSR EnemyInit_Basic

	LDA #$01
	STA ObjectBeingCarriedTimer, X
	STA HoldingItem
	JSR CarryObject

	PLA
	CMP #Enemy_Key
IFDEF PHANTO_CUSTOM
	BNE AreaInitialization_Phantop
ENDIF
	BNE AreaInitialization_SetEnemyData

AreaInitialization_KeyCarryOver:
	INC EnemyVariable, X
	DEX
	STX byte_RAM_12
IFDEF PHANTO_CUSTOM
	BNE +
AreaInitialization_Phantop:
	DEX
	LDA PhantoActivateTimer
	CMP #$FF
	BEQ +
	LDA #$0
	STA PhantoActivateTimer
	BEQ AreaInitialization_SetEnemyData
+
ENDIF
	LDA #EnemyState_Alive
	STA EnemyState, X
	LDA #Enemy_Phanto
	STA ObjectType, X
	JSR EnemyInit_Basic

IFDEF PHANTO_CUSTOM
	++
	LDA #$00
ELSE
	LDA #$00
	STA PhantoActivateTimer
ENDIF
	LDA ScreenYLo
	STA ObjectYLo, X
	LDA ScreenYHi
	STA ObjectYHi, X
	LDA ScreenBoundaryLeftLo
	STA ObjectXLo, X
	LDA ScreenBoundaryLeftHi
	STA ObjectXHi, X
	JSR UnlinkEnemyFromRawData

AreaInitialization_SetEnemyData:
	LDA #<RawEnemyDataAddr
	STA RawEnemyData
	LDA #>RawEnemyDataAddr
	STA RawEnemyData + 1
	LDA IsHorizontalLevel
	BNE AreaInitialization_HorizontalArea

;
; Loads area enemies based on the vertical screen scroll
;
AreaInitialization_VerticalArea:
	LDA #$14
	STA byte_RAM_9
	LDA ScreenYLo
	SBC #$30
	AND #$F0
	STA byte_RAM_5
	LDA ScreenYHi
	SBC #$00
	STA byte_RAM_6

AreaInitialization_VerticalArea_Loop:
	LDA byte_RAM_6
	CMP #$0B
	BCS AreaInitialization_VerticalArea_Next

	JSR CheckObjectVerticalSpawnBoundaries_InitializePage
	JSR CheckObjectVerticalSpawnBoundaries_InitializePage

AreaInitialization_VerticalArea_Next:
	JSR IncrementSpawnBoundaryTile

	DEC byte_RAM_9
	BPL AreaInitialization_VerticalArea_Loop

	RTS

; End of function AreaMainRoutine

;
; Increments the spawn boundary by one tile, incrementing the page if necessary
;
IncrementSpawnBoundaryTile:
	LDA byte_RAM_5
	CLC
	ADC #$10
	STA byte_RAM_5
	BCC IncrementSpawnBoundaryTile_Exit

	INC byte_RAM_6

IncrementSpawnBoundaryTile_Exit:
	RTS


;
; Loads area enemies based on the horizontal screen scroll
;
AreaInitialization_HorizontalArea:
	; Start 3 tiles to the left of the screen boundary
	LDA ScreenBoundaryLeftLo
	SBC #$30
	AND #$F0
	STA byte_RAM_5
	LDA ScreenBoundaryLeftHi
	SBC #$00
	STA byte_RAM_6

	; Check a screen and a half screen's worth of objects
	LDA #$17
	STA byte_RAM_9
AreaInitialization_HorizontalArea_Loop:
	LDA byte_RAM_6
	CMP #$0B
	BCS AreaInitialization_HorizontalArea_Next

	JSR CheckObjectHorizontalSpawnBoundaries_InitializePage
	JSR CheckObjectHorizontalSpawnBoundaries_InitializePage

AreaInitialization_HorizontalArea_Next:
	JSR IncrementSpawnBoundaryTile

	DEC byte_RAM_9
	BPL AreaInitialization_HorizontalArea_Loop

	RTS
