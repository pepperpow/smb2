;
; Creates a mushroom object in subspace.
;
; ##### Input
; - `X`: Object position
; - `Y`: Which mushroom (0 or 1)
;
CreateSubspaceMushroomObject:
IFDEF CUSTOM_MUSH
	TXA
	PHA
    TYA
    TAX
IFDEF CUSTOM_MUSH_LOOP_MUSH
-   LDA EnemyState, X
    CMP #EnemyState_Alive
    BEQ +
	INX
    JMP -
+  
ENDIF
    STX byte_RAM_12
	LDA byte_RAM_7
	AND #$F0
	STA ObjectYLo, X
	LDA byte_RAM_7
	ASL A
	ASL A
	ASL A
	ASL A
	STA ObjectXLo, X
	LDA #$0A
	STA ObjectXHi, X
    LDA #$00
	STA ObjectYHi, X
	LDA #Enemy_Mushroom
	STA ObjectType, X
	LDA #$01
	STA EnemyState, X
	STY EnemyVariable, X
    LDA PlayerLevelPowerup_1, Y
    STA MushroomEffect, X
ENDIF
IFNDEF CUSTOM_MUSH
	TXA
	PHA
	AND #$F0
	STA ObjectYLo
	TXA
	ASL A
	ASL A
	ASL A
	ASL A
	STA ObjectXLo
	LDA #$0A
	STA ObjectXHi
	LDX #$00
	STX byte_RAM_12
	STX ObjectYHi
	LDA #Enemy_Mushroom
	STA ObjectType
	LDA #$01
	STA EnemyState
	STY EnemyVariable
ENDIF
	LDA #$00
	STA EnemyTimer, X
	STA EnemyArray_B1, X
	STA ObjectBeingCarriedTimer, X
	STA ObjectAnimationTimer, X
	STA ObjectShakeTimer, X
	STA EnemyCollision, X
	STA EnemyArray_438, X
	STA EnemyArray_453, X
	STA EnemyArray_45C, X
	STA ObjectYVelocity, X
	STA ObjectXVelocity, X
IFDEF CUSTOM_MUSH
    JSR ProcessCustomPowerup    
ENDIF
IFNDEF CUSTOM_MUSH
	LDY ObjectType, X
	LDA ObjectAttributeTable, Y
	AND #$7F
	STA ObjectAttributes, X
	LDA EnemyArray_46E_Data, Y
	STA EnemyArray_46E, X
	LDA EnemyArray_489_Data, Y
	STA EnemyArray_489, X
	LDA EnemyArray_492_Data, Y
	STA EnemyArray_492, X
	LDA #$FF
	STA EnemyRawDataOffset, X
ENDIF
	PLA
	TAX
	RTS