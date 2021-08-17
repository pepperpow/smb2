; Flag Set
; Takes PTR, 

DokiMode:
    .db %0011  ;; doki
    .db %1011  ;; doki
    .db %0011  ;; doki
    .db %0111  ;; doki
MoreCharacteristics:
    .db %0 ;; doki
    .db %0  ;; doki
    .db %0  ;; doki
    .db %0  ;; doki
IFDEF PLAYER_STUFF_EYE_OFFSET
EyeOffsetY:
    .db $0  ;; doki
    .db $0  ;; doki
    .db $0  ;; doki
    .db $0  ;; doki
EyeOffsetX:
    .db $0  ;; doki
    .db $0  ;; doki
    .db $0  ;; doki
    .db $0  ;; doki
ENDIF
HeightOffset:
    .db $0  ;; doki
    .db $0  ;; doki
    .db $0  ;; doki
    .db $0  ;; doki
HeightOffsetSmall:
    .db $8  ;; doki
    .db $8  ;; doki
    .db $8  ;; doki
    .db $8  ;; doki
HeldOffset:
    .db $0
    .db $0
    .db $0
    .db $0
    .db $0
    .db $0
    .db $0
    .db $0
AccelReduction:
    .db $0
    .db $0
    .db $0
    .db $0
    .db $0
    .db $0
    .db $0
    .db $0
MaxedHealth:
    .db $ff  ;; maxed health
StartingInventory:
    .db $0  ;; select death
    .db $0  ;; select death
    .db $0  ;; select death
    .db $0  ;; select death
    .db $0  ;; select death
    .db $0  ;; select death
    .db $0  ;; select death
    .db $0  ;; select death
    .db %0  ;; select death
    .db $0  ;; select death
    .db $0  ;; select death
    .db $0  ;; select death
StartingEquipment:
    .db $0  ;; select death
    .db $0  ;; select death
    .db $0  ;; select death
StartingProjectile:
    .db $0  ;; select death
    .db $0  ;; select death
    .db $0  ;; select death
    .db $0  ;; select death
StartingHold:
    .db $0  ;; select death
    .db $0  ;; select death
    .db $0  ;; select death
    .db $0  ;; select death



GetMushFlag_Bitmask:
;# takes LDX = mush num
    LDA #CustomBitFlag_Mush1
    CPX #0
    BEQ ApplyMush1
    LDA #CustomBitFlag_Mush2
ApplyMush1:
    TAX
    RTS


ApplyFlag:
    TXA
    JSR ChkFlag_Inner
    BEQ Unmodified_Return
    STA ($c5), Y
    RTS
ChkFlag:
    ;# takes LDX = bit
    ;# return flag if modified
    TXA
ChkFlag_Inner:
    ORA ($c5), Y
    CMP ($c5), Y
    RTS
Unmodified_Return:
    RTS

ChkFlagPlayer3:
    JSR LoadFlagPlayer3
    JMP +
ChkFlagPlayer2:
    JSR LoadFlagPlayer2
    JMP +
ChkFlagPlayer:
    JSR LoadFlagPlayer
+   LDY CurrentCharacter
--  JSR ChkFlag
    RTS

ChkFlagLevel:
    JSR LoadFlagLevel
    LDY CurrentLevelAreaIndex
    JMP --
ChkFlagWorld:
    JSR LoadFlagWorld
    LDY CurrentWorld
    JMP --
IFDEF CUSTOM_MUSH
ApplyFlagPlayer3:
    JSR LoadFlagPlayer3
    JMP +
ApplyFlagPlayer2:
    JSR LoadFlagPlayer2
    JMP +
ApplyFlagPlayer:
    JSR LoadFlagPlayer
+   LDY CurrentCharacter
    LDA IndependentPlayers
    BNE +
    LDY #3
--  JSR ApplyFlag
    DEY
    BPL --
    RTS
+
ENDIF
--  JSR ApplyFlag
    RTS
ApplyFlagLevel:
    JSR LoadFlagLevel
    LDY CurrentLevelAreaIndex
    JMP --
ApplyFlagWorld:
    JSR LoadFlagWorld
    LDY CurrentWorld
    JMP --


LoadPlayerSlot:

;; this is likely excessive for what is just a glorified AND check
LoadFlagLevel:
    LDA #<Level_Bit_Flags
    STA $c5
    LDA #>Level_Bit_Flags
    STA $c5 + 1
    RTS

LoadFlagWorld:
    LDA #<World_Bit_Flags
    STA $c5
    LDA #>World_Bit_Flags
    STA $c5 + 1
    RTS

LoadFlagPlayer: ;; use a table for this
    LDA #<Player_Bit_Flags
    STA $c5
    LDA #>Player_Bit_Flags
    STA $c5 + 1
    RTS

LoadFlagPlayer2:
    LDA #<Player_Bit_Flags_2
    STA $c5
    LDA #>Player_Bit_Flags_2
    STA $c5 + 1
    RTS

LoadFlagPlayer3:
    LDA #<Player_Bit_Flags_3
    STA $c5
    LDA #>Player_Bit_Flags_3
    STA $c5 + 1
    RTS




CustomBeh_UnlockM:
    LDA #$0F ^ #%0001
    LDX #0
    JMP CustomBeh_Unlock
CustomBeh_UnlockP:
    LDA #$0F ^ #%1000
    LDX #1
    JMP CustomBeh_Unlock
CustomBeh_UnlockT:
    LDA #$0F ^ #%0100 ; their respective slot
    LDX #2
    JMP CustomBeh_Unlock
CustomBeh_UnlockL:
    LDA #$0F ^ #%0010
    LDX #3
    JMP CustomBeh_Unlock

CustomBeh_Unlock:
    AND CharacterLock_Variable
    CMP CharacterLock_Variable
    BEQ +++
    STA CharacterLock_Variable
    LDA IndependentLives
    BEQ +
    LDA ContinueGame + 1 ;; lives
    CMP PlayerIndependentLives, X
    BCC ++
    STA PlayerIndependentLives, X
    JMP ++
+   LDA ContinueGame + 1 ;; lives
    CMP PlayerIndependentLives, X
    BCC ++
    STA PlayerIndependentLives, X
++
    JSR PlayMushGet
+++
    RTS