;
;
;
EndingPPUDataPointers:
	.dw PPUBuffer_301
	.dw EndingCorkJarRoom
	.dw EndingCelebrationCeilingTextAndPodium
	.dw EndingCelebrationFloorAndSubconParade
	.dw EndingCelebrationPaletteFade1
	.dw EndingCelebrationPaletteFade2
	.dw EndingCelebrationPaletteFade3
	.dw EndingCelebrationSubconStandStill
	.dw EndingCelebrationUnusedText_THE_END
	.dw EndingCelebrationText_MARIO
	.dw EndingCelebrationText_PRINCESS
	.dw EndingCelebrationText_TOAD
	.dw EndingCelebrationText_LUIGI


WaitForNMI_Ending_TurnOffPPU:
	LDA #$00
	BEQ WaitForNMI_Ending_SetPPUMaskMirror

WaitForNMI_Ending_TurnOnPPU:
	LDA #PPUMask_ShowLeft8Pixels_BG | PPUMask_ShowLeft8Pixels_SPR | PPUMask_ShowBackground | PPUMask_ShowSprites

WaitForNMI_Ending_SetPPUMaskMirror:
	STA PPUMaskMirror

WaitForNMI_Ending:
	LDA ScreenUpdateIndex
	ASL A
	TAX
	LDA EndingPPUDataPointers, X
	STA RAM_PPUDataBufferPointer
	LDA EndingPPUDataPointers + 1, X
	STA RAM_PPUDataBufferPointer + 1

	LDA #$00
	STA NMIWaitFlag
WaitForNMI_EndingLoop:
	LDA NMIWaitFlag
	BPL WaitForNMI_EndingLoop

	RTS


EndingCorkJarRoom:
	.db $20, $00, $9E, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73
	.db $72, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72
	.db $73, $72, $73
	.db $20, $01, $9E, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72
	.db $73, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73
	.db $72, $73, $72
	.db $22, $02, $8E, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73
	.db $72, $73
	.db $22, $03, $8E, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72
	.db $73, $72
	.db $23, $44, $18, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73
	.db $72, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73
	.db $23, $64, $18, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72
	.db $73, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72
	.db $23, $84, $18, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73
	.db $72, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73
	.db $23, $A4, $18, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72
	.db $73, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72
	.db $22, $1C, $8E, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73
	.db $72, $73
	.db $22, $1D, $8E, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72
	.db $73, $72
	.db $20, $1E, $9E, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73
	.db $72, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72
	.db $73, $72, $73
	.db $20, $1F, $9E, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72
	.db $73, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73, $72, $73
	.db $72, $73, $72
	.db $22, $C6, $C4, $FC
	.db $22, $C7, $C4, $FC
	.db $22, $C8, $84, $AD, $AC, $AC, $AC
	.db $22, $E9, $83, $AD, $AC, $AC
	.db $23, $0A, $82, $AD, $AC
	.db $23, $2B, $01, $AD
	.db $22, $90, $84, $88, $89, $89, $8C
	.db $22, $91, $84, $8A, $8B, $8B, $8D
	.db $23, $0E, $06, $74, $76, $74, $76, $74, $76
	.db $23, $2E, $06, $75, $77, $75, $77, $75, $77
	.db $23, $C0, $20, $22, $00, $00, $00, $00, $00, $00, $88, $22, $00, $00, $00, $00, $00, $00, $88, $22, $00
	.db $00, $00, $00, $00, $00, $88, $22, $00, $00, $00, $00, $00, $00, $88
	.db $23, $E0, $20, $AA, $00, $00, $00, $00, $00, $00, $AA, $AA, $00, $00, $00, $11, $00, $00, $AA, $AA
	.db $A0, $A0, $A4, $A5, $A0, $A0, $AA, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A
	.db $00

EndingCelebrationUnusedText_THANK_YOU:
	.db $21, $0C, $09, $ED, $E1, $DA, $E7, $E4, $FB, $F2, $E8, $EE
	.db $00

CorkRoomSpriteStartX:
	.db $30 ; player
	.db $80 ; subcon 8
	.db $80 ; subcon 7
	.db $80 ; subcon 6
	.db $80 ; subcon 5
	.db $80 ; subcon 4
	.db $80 ; subcon 3
	.db $80 ; subcon 2
	.db $80 ; subcon 1
	.db $80 ; cork

CorkRoomSpriteStartY:
	.db $B0 ; player
	.db $A0 ; subcon 8
	.db $A0 ; subcon 7
	.db $A0 ; subcon 6
	.db $A0 ; subcon 5
	.db $A0 ; subcon 4
	.db $A0 ; subcon 3
	.db $A0 ; subcon 2
	.db $A0 ; subcon 1
	.db $95 ; cork

CorkRoomSpriteTargetX:
	.db $10 ; player
	.db $F4 ; subcon 8
	.db $0C ; subcon 7
	.db $E8 ; subcon 6
	.db $18 ; subcon 5
	.db $EC ; subcon 4
	.db $14 ; subcon 3
	.db $F8 ; subcon 2
	.db $08 ; subcon 1
	.db $00 ; cork

CorkRoomSpriteTargetY:
	.db $00 ; player
	.db $C4 ; subcon 8
	.db $C4 ; subcon 7
	.db $B8 ; subcon 6
	.db $B8 ; subcon 5
	.db $A8 ; subcon 4
	.db $A8 ; subcon 3
	.db $A0 ; subcon 2
	.db $A0 ; subcon 1
	.db $00 ; cork

CorkRoomSpriteDelay:
	.db $00 ; player
	.db $F0 ; subcon 8
	.db $E0 ; subcon 7
	.db $C0 ; subcon 6
	.db $A0 ; subcon 5
	.db $80 ; subcon 4
	.db $60 ; subcon 3
	.db $40 ; subcon 2
	.db $20 ; subcon 1
	.db $00 ; cork

CorkRoomSpriteAttributes:
	.db $00 ; player
	.db $21 ; subcon 8
	.db $61 ; subcon 7
	.db $21 ; subcon 6
	.db $61 ; subcon 5
	.db $21 ; subcon 4
	.db $61 ; subcon 3
	.db $21 ; subcon 2
	.db $61 ; subcon 1
	.db $22 ; cork


FreeSubconsScene:
	JSR WaitForNMI_Ending_TurnOffPPU
	JSR ClearNametablesAndSprites

	LDA #Stack100_Menu
	STA StackArea
	LDA #PPUCtrl_Base2000 | PPUCtrl_WriteHorizontal | PPUCtrl_Sprite0000 | PPUCtrl_Background1000 | PPUCtrl_SpriteSize8x16 | PPUCtrl_NMIEnabled
	STA PPUCtrlMirror
	STA PPUCTRL
	JSR WaitForNMI_Ending

	LDA #EndingUpdateBuffer_JarRoom
	STA ScreenUpdateIndex
	JSR WaitForNMI_Ending

	LDA #$60
	STA FreeSubconsTimer
	LDA #$01
	STA PlayerDirection
	LSR A
	STA PlayerState ; A=$00
	STA FreeSubconsCorkCounter
	STA CrouchJumpTimer
	STA byte_RAM_E6
	STA byte_RAM_E5
	STA SpriteFlickerSlot

	LDX #$09
FreeSubconsScene_SpriteLoop:
	LDA CorkRoomSpriteStartX, X
	STA ObjectXLo - 1, X
	LDA CorkRoomSpriteStartY, X
	STA ObjectYLo - 1, X
	LDA CorkRoomSpriteTargetX, X
	STA ObjectXVelocity - 1, X
	LDA CorkRoomSpriteTargetY, X
	STA ObjectYVelocity - 1, X
	LDA CorkRoomSpriteDelay, X
	STA EnemyTimer - 1, X
	LDA CorkRoomSpriteAttributes, X
	STA ObjectAttributes - 1, X
	DEX
	BPL FreeSubconsScene_SpriteLoop

FreeSubconsScene_JumpingLoop:
	JSR WaitForNMI_Ending_TurnOnPPU

	INC byte_RAM_10
	JSR HideAllSprites

	JSR FreeSubconsScene_Player

	JSR FreeSubconsScene_Cork

	LDA FreeSubconsTimer
	BEQ FreeSubconsScene_Exit

	LDA byte_RAM_10
	AND #$07
	BNE FreeSubconsScene_JumpingLoop

	DEC FreeSubconsTimer
	LDA FreeSubconsTimer
	CMP #$25
	BNE FreeSubconsScene_JumpingLoop

	LDY #Music2_EndingAndCast
	STY MusicQueue2
	BNE FreeSubconsScene_JumpingLoop

FreeSubconsScene_Exit:
	JSR EndingSceneTransition

	LDA byte_RAM_E6
	BEQ FreeSubconsScene_JumpingLoop

	RTS


;
; Moves the player, driving the main action in the scene
;
FreeSubconsScene_Player:
	LDA PlayerWalkFrameCounter
	BEQ FreeSubconsScene_Player_AfterWalkFrameCounter

	DEC PlayerWalkFrameCounter

FreeSubconsScene_Player_AfterWalkFrameCounter:
	LDA PlayerStateTimer
	BEQ FreeSubconsScene_Player_AfterStateTimer

	DEC PlayerStateTimer

FreeSubconsScene_Player_AfterStateTimer:
	LDA PlayerXLo
	STA PlayerScreenX
	LDA PlayerYLo
	STA PlayerScreenYLo
	JSR RenderPlayer

	LDA PlayerState
	JSR JumpToTableAfterJump


	.dw FreeSubconsScene_Phase1
	.dw FreeSubconsScene_Phase2
	.dw FreeSubconsScene_Phase3
	.dw FreeSubconsScene_Phase4
	.dw FreeSubconsScene_Phase5


; Walking in and first jump
FreeSubconsScene_Phase1:
	JSR PlayerWalkJumpAnim

	JSR ApplyPlayerPhysicsX

	; check x-position to trigger first jump
	LDA PlayerXLo
	CMP #$3E
	BCC FreeSubconsScene_PhaseExit

	INC PlayerState
	INC PlayerInAir
	LDA #SpriteAnimation_Jumping
	STA PlayerAnimationFrame

FreeSubconsScene_Jump:
	LDA #SoundEffect2_Jump
	STA SoundEffectQueue2
	JMP PlayerStartJump


; Physics and second jump
FreeSubconsScene_Phase2:
	JSR PlayerWalkJumpAnim

	JSR ApplyPlayerPhysicsX

	JSR ApplyCorkRoomGravity

	JSR ApplyPlayerPhysicsY

	LDA PlayerYVelocity
	BMI FreeSubconsScene_PhaseExit

	; check y-position to trigger second jump
	LDA PlayerYLo
	CMP #$A0
	BCC FreeSubconsScene_Phase2_NoJump

	; set x-velocity to land second jump on the jar
	LDA #$0C
	STA PlayerXVelocity
	JMP FreeSubconsScene_Jump

FreeSubconsScene_Phase2_NoJump:
	; check the top of the jar
	CMP #$75
	BCC FreeSubconsScene_PhaseExit

	; check x-position for jar
	LDA PlayerXLo
	CMP #$70
	BCC FreeSubconsScene_PhaseExit

	INC PlayerState
	DEC PlayerInAir

FreeSubconsScene_PhaseExit:
	RTS


; Start pulling the cork
FreeSubconsScene_Phase3:
	JSR PlayerWalkJumpAnim

	JSR ApplyPlayerPhysicsX

	; check x-position for jar
	LDA PlayerXLo
	CMP #$80
	BCC FreeSubconsScene_PhaseExit

	; pull the cork
	INC PlayerState
	INC HoldingItem
	LDA #SpriteAnimation_Pulling
	STA PlayerAnimationFrame
	LDA #$05
	STA FreeSubconsCorkCounter
	LDA #$28
	STA PlayerStateTimer
	RTS


PullCorkFrameDurations:
	.db $14
	.db $0A
	.db $14
	.db $0A

PullCorkOffsets:
	.db $1C
	.db $1B
	.db $1E
	.db $1D
	.db $1F


; Pull the cork out
FreeSubconsScene_Phase4:
	; use PlayerStateTimer to hold this frame
	LDA PlayerStateTimer
	BNE FreeSubconsScene_Phase4_Exit

	; next FreeSubconsCorkCounter to move cork
	DEC FreeSubconsCorkCounter
	BNE FreeSubconsScene_Phase4_NextCorkFrame

	; uncorked! start jumping
	INC PlayerState
	INC PlayerInAir

	LDA #SpriteAnimation_Jumping
	STA PlayerAnimationFrame

	LDA #DPCM_ItemPull
	STA DPCMQueue

	LDA #$A0
	STA ObjectYVelocity + 8
	RTS

FreeSubconsScene_Phase4_NextCorkFrame:
	LDY FreeSubconsCorkCounter
	LDA PullCorkFrameDurations - 1, Y
	STA PlayerStateTimer

FreeSubconsScene_Phase4_Exit:
	RTS


; Free Subcons and jump repeatedly
FreeSubconsScene_Phase5:
	JSR FreeSubconsScene_Subcons

	JSR ApplyCorkRoomGravity

	JSR PlayerWalkJumpAnim

	JSR ApplyPlayerPhysicsY

	LDA PlayerYVelocity
	BMI FreeSubconsScene_Phase5_Exit

	; jump when we're on the jar
	LDA PlayerYLo
	CMP #$80
	BCC FreeSubconsScene_Phase5_Exit

	JMP PlayerStartJump

FreeSubconsScene_Phase5_Exit:
	RTS


CorkRoomCharacterGravity:
	.db $04 ; Mario
	.db $04 ; Princess
	.db $04 ; Toad
	.db $01 ; Luigi


ApplyCorkRoomGravity:
	LDY CurrentCharacter
	LDA CorkRoomCharacterGravity, Y
	CLC
	ADC PlayerYVelocity
	STA PlayerYVelocity
	RTS


;
; Spits out Subcons and makes them flap their little wings
;
FreeSubconsScene_Subcons:
	LDX #$07

FreeSubconsScene_Subcons_Loop:
	STX byte_RAM_12
	LDA EnemyTimer, X
	BEQ FreeSubconsScene_Subcons_Movement

	CMP #$01
	BNE FreeSubconsScene_Subcons_Next

	LDA #SoundEffect1_ThrowItem
	STA SoundEffectQueue1
	BNE FreeSubconsScene_Subcons_Next

FreeSubconsScene_Subcons_Movement:
	JSR ApplyObjectMovement_Bank1

	LDA ObjectYVelocity, X
	CMP #$08
	BMI FreeSubconsScene_Subcons_Render

	LDA #$00
	STA ObjectXVelocity, X
	LDA #$F9
	STA ObjectYVelocity, X
	LDA CorkRoomSpriteAttributes + 1, X
	EOR #ObjAttrib_Palette0 | ObjAttrib_16x32
	STA ObjectAttributes, X

FreeSubconsScene_Subcons_Render:
	LDA byte_RAM_10
	ASL A
	AND #$02
	STA byte_RAM_F
	JSR FreeSubconsScene_Render

	INC EnemyTimer, X

FreeSubconsScene_Subcons_Next:
	DEC EnemyTimer, X
	DEX
	BPL FreeSubconsScene_Subcons_Loop

	RTS



FreeSubconsScene_Cork:
	LDA #$04
	STA byte_RAM_F
	LDX #$08
	STX byte_RAM_12
	JSR FreeSubconsScene_Render

	LDY FreeSubconsCorkCounter
	BNE FreeSubconsScene_Cork_Pull

	LDA ObjectYLo + 8
	CMP #$F0
	BCS FreeSubconsScene_Cork_Exit

	JMP ApplyObjectPhysicsY_Bank1

FreeSubconsScene_Cork_Pull:
	LDA PullCorkOffsets - 1, Y
	CLC
	ADC PlayerYLo
	STA ObjectYLo + 8

FreeSubconsScene_Cork_Exit:
	RTS


CorkRoomSpriteTiles:
	.db $E8 ; subcon left, wings up
	.db $EA ; subcon right, wings up
	.db $EC ; subcon left, wings down
	.db $EE ; subcon right, wings down
	.db $61 ; cork left
	.db $63 ; cork right

CorkRoomSpriteOAMAddress:
	.db $30 ; subcon 8
	.db $38 ; subcon 7
	.db $40 ; subcon 6
	.db $48 ; subcon 5
	.db $50 ; subcon 4
	.db $58 ; subcon 3
	.db $60 ; subcon 2
	.db $68 ; subcon 1
	.db $00 ; cork


FreeSubconsScene_Render:
	LDY CorkRoomSpriteOAMAddress, X
	LDA ObjectYLo, X
	STA SpriteDMAArea, Y
	STA SpriteDMAArea + 4, Y
	LDA ObjectXLo, X
	STA SpriteDMAArea + 3, Y
	CLC
	ADC #$08
	STA SpriteDMAArea + 7, Y
	LDA ObjectAttributes, X
	STA SpriteDMAArea + 2, Y
	STA SpriteDMAArea + 6, Y
	LDX byte_RAM_F
	AND #ObjAttrib_16x32
	BNE FreeSubconsScene_Render_Flipped

	LDA CorkRoomSpriteTiles, X
	STA SpriteDMAArea + 1, Y
	LDA CorkRoomSpriteTiles + 1, X
	BNE FreeSubconsScene_Render_Exit

FreeSubconsScene_Render_Flipped:
	LDA CorkRoomSpriteTiles + 1, X
	STA SpriteDMAArea + 1, Y
	LDA CorkRoomSpriteTiles, X

FreeSubconsScene_Render_Exit:
	STA SpriteDMAArea + 5, Y
	LDX byte_RAM_12
	RTS


EndingCelebrationCeilingTextAndPodium:
	.db $20, $00, $20
	.db $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81
	.db $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81

	.db $20, $20, $20
	.db $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80
	.db $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80

	.db $20, $40, $20
	.db $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81
	.db $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81

	.db $20, $60, $20
	.db $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80
	.db $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80

	.db $20, $88, $01, $5A
	.db $20, $89, $4E, $9A
	.db $20, $97, $01, $5C
	.db $20, $A8, $C3, $9B
	.db $20, $B7, $C3, $9B
	.db $21, $08, $01, $5B
	.db $21, $09, $4E, $9A
	.db $21, $17, $01, $5D
	.db $20, $AB, $0B, $DC, $E8, $E7, $ED, $EB, $E2, $DB, $EE, $ED, $E8, $EB
	.db $20, $E3, $04, $40, $42, $44, $46
	.db $20, $F9, $04, $40, $42, $44, $46
	.db $21, $23, $C9, $48
	.db $21, $24, $C9, $49
	.db $21, $25, $C9, $4A
	.db $21, $26, $C9, $4B
	.db $22, $43, $04, $4C, $4D, $4E, $4F
	.db $21, $03, $04, $41, $43, $45, $47
	.db $21, $19, $04, $41, $43, $45, $47
	.db $21, $39, $C9, $48
	.db $21, $3A, $C9, $49
	.db $21, $3B, $C9, $4A
	.db $21, $3C, $C9, $4B
	.db $22, $59, $04, $4C, $4D, $4E, $4F
	.db $21, $CA, $4C, $54
	.db $21, $EA, $4C, $55
	.db $22, $0B, $0A, $50, $52, $50, $52, $50, $52, $50, $52, $50, $52
	.db $22, $2B, $0A, $51, $53, $51, $53, $51, $53, $51, $53, $51, $53
	.db $22, $4C, $02, $3A, $3B
	.db $22, $6C, $C5, $3C
	.db $22, $6D, $C5, $3D
	.db $22, $52, $02, $3A, $3B
	.db $22, $72, $C5, $3C
	.db $22, $73, $C5, $3D
	.db $00

EndingCelebrationFloorAndSubconParade:
	.db $23, $00, $20
	.db $00, $02, $08, $0A, $0C, $0E, $04, $06, $08, $0A, $04, $06, $0C, $0E, $04, $06
	.db $08, $0A, $00, $02, $0C, $0E, $0C, $0E, $00, $02, $04, $06, $04, $06, $08, $0A

	.db $23, $20, $20
	.db $01, $03, $09, $0B, $0D, $0F, $05, $07, $09, $0B, $05, $07, $0D, $0F, $05, $07
	.db $09, $0B, $01, $03, $0D, $0F, $0D, $0F, $01, $03, $05, $07, $05, $07, $09, $0B

	.db $27, $00, $20
	.db $74, $76, $74, $76, $74, $76, $74, $76, $74, $76, $74, $76, $74, $76, $74, $76
	.db $74, $76, $74, $76, $74, $76, $74, $76, $74, $76, $74, $76, $74, $76, $74, $76

	.db $27, $20, $20
	.db $75, $77, $75, $77, $75, $77, $75, $77, $75, $77, $75, $77, $75, $77, $75, $77
	.db $75, $77, $75, $77, $75, $77, $75, $77, $75, $77, $75, $77, $75, $77, $75, $77

	.db $23, $40, $20
	.db $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81
	.db $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81

	.db $23, $60, $20
	.db $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80
	.db $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80

	.db $23, $80, $20
	.db $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81
	.db $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81

	.db $23, $A0, $20
	.db $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80
	.db $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80

	.db $27, $40, $20
	.db $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81
	.db $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81

	.db $27, $60, $20
	.db $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80
	.db $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80

	.db $27, $80, $20
	.db $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81
	.db $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81

	.db $27, $A0, $20
	.db $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80
	.db $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $80

	.db $23, $C0, $48, $AA
	.db $23, $C8, $08, $15, $05, $FF, $FF, $FF, $FF, $15, $45

	.db $23, $D0, $20
	.db $31, $00, $FF, $FF, $FF, $FF, $00, $44, $33, $00, $A6, $A5, $A5, $A6, $00, $44
	.db $F3, $F0, $59, $AA, $AA, $96, $F0, $74, $DD, $FF, $55, $AA, $AA, $95, $55, $55

	.db $23, $F0, $48, $A5
	.db $23, $F8, $48, $0A
	.db $27, $F0, $48, $A5
	.db $27, $F8, $48, $0A
	.db $00

EndingCelebrationSubconStandStill:
	.db $23, $00, $20
	.db $70, $72, $70, $72, $70, $72, $70, $72, $70, $72, $70, $72, $70, $72, $70, $72
	.db $70, $72, $70, $72, $70, $72, $70, $72, $70, $72, $70, $72, $70, $72, $70, $72
	.db $23, $20, $20
	.db $71, $73, $71, $73, $71, $73, $71, $73, $71, $73, $71, $73, $71, $73, $71, $73
	.db $71, $73, $71, $73, $71, $73, $71, $73, $71, $73, $71, $73, $71, $73, $71, $73
	.db $00

EndingCelebrationUnusedText_THE_END:
	.db $21, $AC, $07
	.db $ED, $E1, $DE, $FB, $DE, $E7, $DD
	.db $00

EndingCelebrationPaletteFade1:
	.db $3F, $00, $20
	.db $01, $30, $21, $0F
	.db $01, $30, $16, $0F
	.db $01, $28, $18, $0F
	.db $01, $30, $30, $01
	.db $01, $27, $16, $0F
	.db $01, $37, $2A, $0F
	.db $01, $27, $30, $0F
	.db $01, $36, $25, $0F
	.db $00

EndingCelebrationPaletteFade2:
	.db $3F, $00, $20
	.db $0F, $10, $00, $0F
	.db $0F, $10, $00, $0F
	.db $0F, $10, $00, $0F
	.db $0F, $10, $00, $0F
	.db $0F, $10, $00, $0F
	.db $0F, $10, $00, $0F
	.db $0F, $10, $00, $0F
	.db $0F, $10, $00, $0F
	.db $00

EndingCelebrationPaletteFade3:
	.db $3F, $00, $20
	.db $0F, $00, $0F, $0F
	.db $0F, $00, $0F, $0F
	.db $0F, $00, $0F, $0F
	.db $0F, $00, $0F, $0F
	.db $0F, $00, $0F, $0F
	.db $0F, $00, $0F, $0F
	.db $0F, $00, $0F, $0F
	.db $0F, $00, $0F, $0F
	.db $00

EndingScreenUpdateIndex:
	.db EndingUpdateBuffer_PaletteFade1
	.db EndingUpdateBuffer_PaletteFade2 ; 1 ; @TODO This seems wrong, somehow
	.db EndingUpdateBuffer_PaletteFade3 ; 2

ContributorSpriteZeroOAMData:
	.db $8C, $FC, $20, $94

IFDEF CUSTOM_PLAYER_RENDER
ContributorCharacterOAMData:
	; Mario
	.db $4F, $00, $20, $50
	.db $4F, $02, $20, $58
	.db $5F, $04, $20, $50
	.db $5F, $06, $20, $58
	; Luigi
	.db $4F, $08, $21, $68
	.db $4F, $0a, $21, $70
	.db $5F, $0c, $21, $68
	.db $5F, $0e, $21, $70
	; Toad
	.db $4F, $10, $22, $88
	.db $4F, $12, $22, $90
	.db $5F, $14, $22, $88
	.db $5F, $16, $22, $90
	; Princess1
	.db $4F, $18, $23, $A0
	.db $4F, $1a, $23, $A8
	.db $5F, $1c, $23, $A0
	.db $5F, $1e, $23, $A8
CharLookupTable_Ordered:
	.db $01 ; Mio 
	.db $02 ; Lug 
	.db $04 ; Tod 
	.db $08 ; Pch 
ELSE
ContributorCharacterOAMData:
	; Mario
	.db $4F, $61, $20, $50
	.db $4F, $63, $20, $58
	.db $5F, $65, $20, $50
	.db $5F, $67, $20, $58
	; Luigi
	.db $4F, $69, $21, $68
	.db $4F, $6B, $21, $70
	.db $5F, $6D, $21, $68
	.db $5F, $6F, $21, $70
	; Toad
	.db $4F, $83, $22, $88
	.db $4F, $83, $62, $90
	.db $5F, $87, $22, $88
	.db $5F, $87, $62, $90
	; Princess
	.db $4F, $8B, $23, $A0
	.db $4F, $8D, $23, $A8
	.db $5F, $8F, $23, $A0
	.db $5F, $91, $23, $A8
ENDIF


;
; Shows the part of the ending where the Subcons carry Wart to an uncertain
; fate while the characters stand and wave
;
ContributorScene:
	JSR WaitForNMI_Ending_TurnOffPPU

	LDA #VMirror
	JSR ChangeNametableMirroring

	JSR ClearNametablesAndSprites

	LDA #Stack100_Menu
	STA StackArea
	JSR EnableNMI_Bank1

	JSR WaitForNMI_Ending

	LDA #EndingUpdateBuffer_CeilingTextAndPodium
	STA ScreenUpdateIndex
	JSR WaitForNMI_Ending

	LDA #EndingUpdateBuffer_FloorAndSubconParade
	STA ScreenUpdateIndex
	JSR WaitForNMI_Ending

	JSR Ending_GetContributor

	JSR WaitForNMI_Ending

	LDA #HMirror
	JSR ChangeNametableMirroring

	LDY #$03
ContributorScene_SpriteZeroLoop:
	LDA ContributorSpriteZeroOAMData, Y
	STA SpriteDMAArea, Y
	DEY
	BPL ContributorScene_SpriteZeroLoop

	LDA #$00
	STA byte_RAM_F3
	STA byte_RAM_E6

	LDY #$3F
ContributorScene_CharacterLoop:
IFNDEF TEST_FLAG
	LDA ContributorCharacterOAMData, Y
	STA SpriteDMAArea + $10, Y
	DEY
	BPL ContributorScene_CharacterLoop
ENDIF
IFDEF CUSTOM_PLAYER_RENDER
    LDA #$31
    STA SpriteCHR1
-   TYA
    LSR
    LSR
    LSR
    LSR
    TAX
    LDA CharLookupTable_Ordered, X  
    AND CharacterLock_Variable
    BEQ +
    LDA #$FF 
	STA SpriteDMAArea + $10, Y
    DEY
    BPL -
    JMP ++
+	LDA ContributorCharacterOAMData, Y
	STA SpriteDMAArea + $10, Y
	DEY
	BPL -
++
ENDIF

	LDA #$FF
	STA PlayerXHi
	LDA #$A0
	STA PlayerXLo
	LDA #$08
	STA PlayerXVelocity
	LDA #$01
	STA IsHorizontalLevel

loc_BANK1_AAD4:
	JSR WaitForNMI_Ending_TurnOnPPU

	INC byte_RAM_F3
	INC byte_RAM_10
	JSR ContributorTicker

	JSR loc_BANK1_ABCC

	LDA byte_RAM_E6
	CMP #$03
	BCS loc_BANK1_AB20

loc_BANK1_AAE7:
	BIT PPUSTATUS
	BVS loc_BANK1_AAE7

loc_BANK1_AAEC:
	BIT PPUSTATUS
	BVC loc_BANK1_AAEC

	LDX #$02

loc_BANK1_AAF3:
	LDY #$00

loc_BANK1_AAF5:
	LDA byte_RAM_0
	LDA byte_RAM_0
	DEY
	BNE loc_BANK1_AAF5

	DEX
	BNE loc_BANK1_AAF3

	LDA PPUSTATUS
	LDA byte_RAM_F2
	STA PPUSCROLL
	LDA #$00
	STA PPUSCROLL
	LDA byte_RAM_F3
	CMP #$0A
	BCC loc_BANK1_AB1D

	LDA #$00
	STA byte_RAM_F3
	LDA byte_RAM_F2
	SEC
	SBC #$30
	STA byte_RAM_F2

loc_BANK1_AB1D:
	JMP loc_BANK1_AAD4

; ---------------------------------------------------------------------------

loc_BANK1_AB20:
	LDA #VMirror
	JSR ChangeNametableMirroring

	LDA #$01
	STA byte_RAM_F2
	LSR A
	STA byte_RAM_F3
	STA byte_RAM_7
	LDA #EndingUpdateBuffer_SubconStandStill
	STA ScreenUpdateIndex

loc_BANK1_AB32:
	JSR WaitForNMI_Ending

	JSR EnableNMI_Bank1

	INC byte_RAM_F3
	JSR ContributorTicker

	JSR ContributorCharacterAnimation

loc_BANK1_AB40:
	BIT PPUSTATUS
	BVS loc_BANK1_AB40

loc_BANK1_AB45:
	BIT PPUSTATUS
	BVC loc_BANK1_AB45

	LDX #$02

loc_BANK1_AB4C:
	LDY #$00

loc_BANK1_AB4E:
	LDA byte_RAM_0
	LDA byte_RAM_0
	DEY
	BNE loc_BANK1_AB4E

	DEX
	BNE loc_BANK1_AB4C

	LDA #$B0
	ORA byte_RAM_F2
	STA PPUCtrlMirror
	STA PPUCTRL
	LDA PPUSTATUS
	LDA #$00
	STA PPUSCROLL
	LDA #$00
	STA PPUSCROLL
	LDA byte_RAM_F3
	CMP #$14
	BCC loc_BANK1_AB80

	LDA #$00
	STA byte_RAM_F3
	LDA byte_RAM_F2
	EOR #$01
	STA byte_RAM_F2
	INC byte_RAM_7

loc_BANK1_AB80:
IFNDEF EXCLUDE_MARIO_DREAM
	LDA byte_RAM_7
	CMP #$29
	BCC loc_BANK1_AB32

	JSR EndingSceneTransition

	LDA byte_RAM_E6
	CMP #$04
	BCC loc_BANK1_AB32
ELSE
	JMP loc_BANK1_AB32
ENDIF

	RTS


;
; Advances to the next scene and does the palette transition
;
EndingSceneTransition:
	LDA byte_RAM_10
	AND #$03
	BNE EndingSceneTransition_Exit

	INC byte_RAM_E5
	LDY byte_RAM_E5
	CPY #$03
	BCS EndingSceneTransition_Next

	LDA EndingScreenUpdateIndex, Y
	STA ScreenUpdateIndex
	RTS

EndingSceneTransition_Next:
	INC byte_RAM_E6

EndingSceneTransition_Exit:
	RTS


; ---------------------------------------------------------------------------

loc_BANK1_ABA7:
	LDA byte_RAM_10
	AND #$03
	BNE EndingSceneTransition_Exit

	DEC byte_RAM_E5
	LDY byte_RAM_E5
	LDA EndingScreenUpdateIndex, Y
	STA ScreenUpdateIndex
	TYA
	BNE EndingSceneTransition_Exit

	INC byte_RAM_E6
	RTS


EnableNMI_Bank1:
	LDA #PPUCtrl_Base2000 | PPUCtrl_WriteHorizontal | PPUCtrl_Sprite0000 | PPUCtrl_Background1000 | PPUCtrl_SpriteSize8x16 | PPUCtrl_NMIEnabled
	STA PPUCtrlMirror
	STA PPUCTRL
	RTS


DisableNMI_Bank1:
	LDA #PPUCtrl_Base2000 | PPUCtrl_WriteHorizontal | PPUCtrl_Sprite0000 | PPUCtrl_Background1000 | PPUCtrl_SpriteSize8x16 | PPUCtrl_NMIDisabled
	STA PPUCTRL
	STA PPUCtrlMirror
	RTS



loc_BANK1_ABCC:
	JSR ContributorCharacterAnimation

	LDA byte_RAM_E6
	JSR JumpToTableAfterJump

	.dw loc_BANK1_ABA7
	.dw loc_BANK1_AC0A
	.dw loc_BANK1_AC87


byte_BANK1_ABDA:
	.db $C0
	.db $C8
	.db $B8
	.db $B8
	.db $C8
	.db $C0

byte_BANK1_ABE0:
	.db $C0
	.db $08
	.db $E0
	.db $F0
	.db $D0
	.db $E8

EndingWartTiles:
	.db $11
	.db $13
	.db $19
	.db $1B
	.db $21
	.db $23
	.db $15
	.db $17
	.db $1D
	.db $1F
	.db $25
	.db $27

byte_BANK1_ABF2:
	.db $00
	.db $08
	.db $10
	.db $18
	.db $20
	.db $28
	.db $00
	.db $08
	.db $10
	.db $18
	.db $20
	.db $28

byte_BANK1_ABFE:
	.db $00
	.db $00
	.db $00
	.db $00
	.db $00
	.db $00
	.db $10
	.db $10
	.db $10
	.db $10
	.db $10
	.db $10


; ---------------------------------------------------------------------------

loc_BANK1_AC0A:
	JSR ApplyPlayerPhysicsX

	LDA PlayerXHi
	CMP #$01
	BNE loc_BANK1_AC37

	LDA PlayerXLo
	CMP #$20
	BCC loc_BANK1_AC37

	INC_abs byte_RAM_E6

	LDA #$A0
	STA byte_RAM_10
	LDX #$05

loc_BANK1_AC22:
	LDA #$20
	STA ObjectXLo, X
	LDA #$A8

loc_BANK1_AC28:
	STA ObjectYLo, X
	LDA byte_BANK1_ABDA, X
	STA ObjectXVelocity, X
	LDA byte_BANK1_ABE0, X
	STA ObjectYVelocity, X
	DEX
	BPL loc_BANK1_AC22

loc_BANK1_AC37:
	LDY #$A0
	LDA byte_RAM_10
	AND #$38
	BNE loc_BANK1_AC40

	DEY

loc_BANK1_AC40:
	AND #$08
	BNE loc_BANK1_AC45

	DEY

loc_BANK1_AC45:
	STY PlayerYLo
	LDX #$0B
	LDY #$70

loc_BANK1_AC4B:
	LDA PlayerYLo
	CLC
	ADC byte_BANK1_ABFE, X
	STA SpriteDMAArea, Y
	LDA EndingWartTiles, X
	STA SpriteDMAArea + 1, Y
	LDA #$01
	STA SpriteDMAArea + 2, Y
	LDA PlayerXLo
	CLC
	ADC byte_BANK1_ABF2, X
	STA SpriteDMAArea + 3, Y
	LDA PlayerXHi

loc_BANK1_AC6A:
	ADC #$00
	BEQ loc_BANK1_AC73

	LDA #$F0
	STA SpriteDMAArea, Y

loc_BANK1_AC73:
	INY
	INY
	INY
	INY
	DEX
	BPL loc_BANK1_AC4B

	RTS


ZonkTiles:
	.db $39
	.db $35
	.db $37
	.db $35
	.db $37
	.db $39

byte_BANK1_AC81:
	.db $00
	.db $06
	.db $03
	.db $09
	.db $0F
	.db $0C


loc_BANK1_AC87:
	LDA byte_RAM_10
	BNE loc_BANK1_ACA4

loc_BANK1_AC8B:
	STA ObjectXSubpixel + 6
	STA ObjectYSubpixel + 6
	STA ObjectXLo + 6
	STA byte_RAM_10
	LDA #$6F
	STA ObjectYLo + 6
	LDA #$E6
	STA ObjectXVelocity + 6
	LDA #$0DA
	STA ObjectYVelocity + 6

	INC_abs byte_RAM_E6


loc_BANK1_ACA4:
	LDX #$05

loc_BANK1_ACA6:
	STX byte_RAM_12
	JSR ApplyObjectPhysicsX_Bank1

	JSR ApplyObjectPhysicsY_Bank1

	LDY #$F0
	LDA byte_RAM_10
	BEQ loc_BANK1_ACC1

	AND #$0F
	CMP byte_BANK1_AC81, X
	BNE loc_BANK1_ACC3

	LDA #$20
	STA ObjectXLo, X
	LDY #$A8

loc_BANK1_ACC1:
	STY ObjectYLo, X

loc_BANK1_ACC3:
	TXA
	ASL A
	ASL A
	TAY
	LDA ObjectXLo, X
	CMP #$80
	BCS loc_BANK1_ACD1

	LDA #$F0
	BNE loc_BANK1_ACD6

loc_BANK1_ACD1:
	STA SpriteDMAArea + $73, Y
	LDA ObjectYLo, X

loc_BANK1_ACD6:
	STA SpriteDMAArea + $70, Y
	LDA ZonkTiles, X
	STA SpriteDMAArea + $71, Y
	LDA #$00
	STA SpriteDMAArea + $72, Y
	DEX
	BPL loc_BANK1_ACA6

	RTS


ContributorAnimationTiles:
ContributorAnimationTiles_Mario:
	.db $61
	.db $61
	.db $63
	.db $93
	.db $65
	.db $65
	.db $67
	.db $67
ContributorAnimationTiles_Luigi:
	.db $69
	.db $69
	.db $95
	.db $6B
	.db $6D
	.db $6D
	.db $97
	.db $6F
ContributorAnimationTiles_Toad:
	.db $83
	.db $85
	.db $83
	.db $85
	.db $87
	.db $89
	.db $87
	.db $89
ContributorAnimationTiles_Princess:
	.db $8B
	.db $8B
	.db $99
	.db $8D
	.db $8F
	.db $8F
	.db $91
	.db $91

ContributorAnimationTilesOffset:
	.db (ContributorAnimationTiles_Mario - ContributorAnimationTiles + 6)
	.db (ContributorAnimationTiles_Luigi - ContributorAnimationTiles + 6)
	.db (ContributorAnimationTiles_Toad - ContributorAnimationTiles + 6)
	.db (ContributorAnimationTiles_Princess - ContributorAnimationTiles + 6)


ContributorCharacterAnimation:
	INC PlayerWalkFrame
	LDA #$03
	STA byte_RAM_0
	LDA PlayerWalkFrame
	STA byte_RAM_1
	LDY #$3C

ContributorCharacterAnimation_OuterLoop:
	LDX byte_RAM_0
	LDA ContributorAnimationTilesOffset, X
	TAX
	INC byte_RAM_1
	LDA byte_RAM_1
	AND #$10
	BEQ ContributorCharacterAnimation_Render

	INX

ContributorCharacterAnimation_Render:
	LDA #$03
	STA byte_RAM_2
ContributorCharacterAnimation_InnerLoop:
	LDA ContributorAnimationTiles, X
	STA SpriteDMAArea + $11, Y
	DEX
	DEX
	DEY
	DEY
	DEY
	DEY
	DEC byte_RAM_2
	BPL ContributorCharacterAnimation_InnerLoop

	DEC byte_RAM_0
	BPL ContributorCharacterAnimation_OuterLoop

	RTS


;
; Calculates the list of top contributors
;
Ending_GetContributor:
	LDA #$00
	STA MaxLevelsCompleted

	LDY #$03
Ending_GetContributor_Loop:
	LDA CharacterLevelsCompleted, Y
	CMP MaxLevelsCompleted
	BCC Ending_GetContributor_Next

	LDA CharacterLevelsCompleted, Y
	STA MaxLevelsCompleted

Ending_GetContributor_Next:
	DEY
	BPL Ending_GetContributor_Loop

	LDX #$00
	LDY #$03
Ending_GetContributor_Loop2:
	LDA CharacterLevelsCompleted, Y
	CMP MaxLevelsCompleted
	BNE Ending_GetContributor_Next2

	TYA
	STA Contributors, X
	INX

Ending_GetContributor_Next2:
	DEY
	BPL Ending_GetContributor_Loop2

	DEX
	STX NumContributors
	LDX #$00
	LDA #$21
	STA PPUBuffer_301, X
	INX
	LDA #$2A
	STA PPUBuffer_301, X
	INX
	LDA #$0C
	STA PPUBuffer_301, X
	INX
	LDY #$00
	LDA CharacterLevelsCompleted, Y
	JSR sub_BANK1_AE43

	TYA
	STA PPUBuffer_301, X
	INX
	LDA byte_RAM_1
	STA PPUBuffer_301, X
	INX
	LDA #$0FB
	STA PPUBuffer_301, X
	INX
	LDY #$03
	LDA CharacterLevelsCompleted, Y
	JSR sub_BANK1_AE43

	TYA
	STA PPUBuffer_301, X
	INX
	LDA byte_RAM_1
	STA PPUBuffer_301, X
	INX

	LDA #$0FB
	STA PPUBuffer_301, X
	INX
	STA PPUBuffer_301, X
	INX
	LDY #$02
	LDA CharacterLevelsCompleted, Y
	JSR sub_BANK1_AE43

	TYA
	STA PPUBuffer_301, X
	INX
	LDA byte_RAM_1
	STA PPUBuffer_301, X
	INX
	LDA #$0FB
	STA PPUBuffer_301, X
	INX
	LDY #$01
	LDA CharacterLevelsCompleted, Y
	JSR sub_BANK1_AE43

	TYA
	STA PPUBuffer_301, X
	INX
	LDA byte_RAM_1
	STA PPUBuffer_301, X
	INX
	LDA #$00
	STA PPUBuffer_301, X
	LDA #$3C
	STA ContributorTimer
	RTS


; =============== S U B R O U T I N E =======================================

ContributorTicker:
	DEC ContributorTimer
	BPL ContributorTicker_Exit

	LDA #$3C
	STA ContributorTimer
	LDY ContributorIndex
	LDA Contributors, Y
	CLC
	ADC #$09

	STA_abs ScreenUpdateIndex

	DEC ContributorIndex
	BPL ContributorTicker_Exit

	LDA NumContributors
	STA ContributorIndex

ContributorTicker_Exit:
	RTS


EndingCelebrationText_MARIO:
	.db $20, $ED, $08, $E6, $DA, $EB, $E2, $E8, $FB, $FB, $FB
	.db $00

EndingCelebrationText_PRINCESS:
	.db $20, $ED, $08, $E9, $EB, $E2, $E7, $DC, $DE, $EC, $EC
	.db $00

EndingCelebrationText_TOAD:
	.db $20, $ED, $08, $ED, $E8, $DA, $DD, $FB, $FB, $FB, $FB
	.db $00

EndingCelebrationText_LUIGI:
	.db $20, $ED, $08, $E5, $EE, $E2, $E0, $E2, $FB, $FB, $FB
	.db $00


; =============== S U B R O U T I N E =======================================

sub_BANK1_AE43:
	LDY #$D0

loc_BANK1_AE45:
	CMP #$0A
	BCC loc_BANK1_AE4F

	SBC #$0A

loc_BANK1_AE4B:
	INY
	JMP loc_BANK1_AE45

; ---------------------------------------------------------------------------

loc_BANK1_AE4F:
	ORA #$D0
	CPY #$D0
	BNE loc_BANK1_AE57

	LDY #$0FB

loc_BANK1_AE57:
	STA byte_RAM_1
	RTS

; End of function sub_BANK1_AE43

; ---------------------------------------------------------------------------