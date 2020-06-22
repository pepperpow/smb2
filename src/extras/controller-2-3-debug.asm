
; Copies all character stats to RAM for hot-swapping the current character
;
CopyCarryYOffsets:
	LDX #(AreaMainRoutine - CarryYOffsets - 1)
CopyCarryYOffsets_Loop:
	LDA CarryYOffsets, X
	STA CarryYOffsetsRAM, X
	DEX
	BPL CopyCarryYOffsets_Loop

	RTS

AreaDebugRoutine:
	LDA CreateObjectType
	BEQ AreaDebugRoutine_Exit

	JSR DebugCreateObject

AreaDebugRoutine_Exit:
	RTS

;
; Input
;   CreateObjectType = object type
;
DebugCreateObject:
	JSR CreateEnemy

	BMI AreaDebugRoutine_Exit

	LDX byte_RAM_0
	LDA CreateObjectType
	STA ObjectType, X
	LDA ScreenBoundaryLeftLo
	ADC #$80
	STA ObjectXLo, X
	LDA ScreenBoundaryLeftHi
	ADC #$00
	STA ObjectXHi, X
	LDA ScreenYLo
	STA ObjectYLo, X
	LDA ScreenYHi
	ADC #$00
	STA ObjectYHi, X

	JSR InitializeEnemy

	LDA CreateObjectAttributes
	BEQ DebugCreateObject_ClearObjectType

DebugCreateObject_ObjectCarried:
	ROL CreateObjectAttributes
	BCC DebugCreateObject_ObjectTimer

	LDA #$01
	STA HoldingItem
	STA ObjectBeingCarriedTimer, X
	STX ObjectBeingCarriedIndex

	LDA #SoundEffect1_CherryGet
	STA SoundEffectQueue1

DebugCreateObject_ObjectTimer:
	ROL CreateObjectAttributes
	BCC DebugCreateObject_ObjectBottomScreen

	LDA #$FF
	STA EnemyTimer, X

DebugCreateObject_ObjectBottomScreen:
	ROL CreateObjectAttributes
	BCC DebugCreateObject_Bit4

	LDA ObjectYLo, X
	CLC
	ADC #$E0
	STA ObjectYLo, X
	LDA ObjectYHi, X
	ADC #$00
	STA ObjectYHi, X

DebugCreateObject_Bit4:
	ROL CreateObjectAttributes
	BCC DebugCreateObject_Bit3

DebugCreateObject_Bit3:
	ROL CreateObjectAttributes
	BCC DebugCreateObject_Bit2

DebugCreateObject_Bit2:
	ROL CreateObjectAttributes
	BCC DebugCreateObject_ObjectThrown

DebugCreateObject_ObjectThrown:
	ROL CreateObjectAttributes
	BCC DebugCreateObject_ObjectNoVelocityReset

	LDA #$01
	STA EnemyArray_42F, X

DebugCreateObject_ObjectNoVelocityReset:
	ROL CreateObjectAttributes
	BCS DebugCreateObject_ClearObjectType

	LDA #$00
	STA ObjectXVelocity, X
	STA ObjectYVelocity, X

DebugCreateObject_ClearObjectType:
	LDA #$00
	STA CreateObjectType

DebugCreateObject_Exit:
	RTS