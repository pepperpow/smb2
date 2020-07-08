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
IndependentLives:
    .db $0  ;; elimination mode
IndependentPlayers:
    .db $0  ;; powerups per player
CharSelectDeath:
    .db $1  ;; select death (0, no select, 1, always select, 2, random select)
CharSelectAnytime:
    .db $1  ;; select death
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
CrystalCondition:
    .db $1 ;; crystals
BossCondition:
    .db $1  ;; bosses
RescueCondition:
    .db $0  ;; ok
WinLevel:
    .db $FF ;; bosses
FreeHealth:
    .db $00
ChampionChance:
    .db $10
CharacterInitialLock:
    .BYTE 0

BonusChanceText_PUSH_OTHER_BUTTON:
	.db $13+4,$22,$87,$13,$DB,$FB,$DC,$DA,$E7,$DC,$DE,$E5,$F7,$FB,$EC,$ED,$DA,$EB,$ED,$FB,$D1,$EE,$E9,$0
TEXT_EQUIP:
	.db $9+4,$2D,$46,$9
    .db "EQUIPMENT" + $99
    .db $0
TEXT_UPGRADE:
	.db $7+4,$2D,$53,$7
    .db "UPGRADE" + $99
    .db $0
TEXT_Mario:
	.db $8+4,$22,$EC,$8, $FB, $E6, $DA, $EB, $E2, $E8, $FB, $FB, $0
TEXT_Princess:
	.db $8+4,$22,$EC,$8, $E9, $EB, $E2, $E7, $DC, $DE, $EC, $EC, $0
TEXT_Toad:
	.db $8+4,$22,$EC,$8, $FB, $FB, $ED, $E8, $DA, $DD, $FB, $FB, $0
TEXT_Luigi:
	.db $8+4,$22,$EC,$8, $FB, $E5, $EE, $E2, $E0, $E2, $FB, $FB, $0
;TEXT_Extra_Lives:
;    .db $8+4,$22,$EC,$8, $de,$f1,$ed,$eb,$da,$fb,$e5,$e2,$ef,$de,$ec,$f8,$f8,$f8,$f8,$d0
;TEXT_Coins:
;    .db $8+4,$22,$EC,$8, $dc,$e8,$e2,$e7,$ec,$f8,$f8,$f8,$f8,$f8,$f8,$f8,$f8,$f8,$f8,$d0
TEXT_Crystals:
    .db $8+4,$26,$A8,$8, $dc,$eb,$f2,$ec,$ed,$da,$e5,$ec,$0
TEXT_Bosses:
    .db $8+4,$26,$88,$8,$db,$e8,$ec,$ec,$de,$ec,$f8,$f8,$0
TEXT_Fragments:
    .db $10+4,$26,$E8,$10, $DF,$EB,$DA,$E0,$E6,$DE,$E7,$ED,$EC,$F8,$F8,$F8,$F8,$F8,$F8,$D4,$0
;TEXT_Total_Rooms:
;    .db $8+4,$22,$EC,$8, $ed,$e8,$ed,$da,$e5,$fb,$eb,$e8,$e8,$e6,$ec,$f8,$f8,$f8,$f8,$d0
Custom_TextPointers:
	.dw BonusChanceText_PUSH_OTHER_BUTTON ; 0
    .dw TEXT_EQUIP ; 1
    .dw TEXT_UPGRADE ; 1
    .dw TEXT_Mario ; 1
    .dw TEXT_Princess ; 1
    .dw TEXT_Toad; 1
    .dw TEXT_Luigi ; 1
    .dw TEXT_Crystals
    .dw TEXT_Bosses
    .dw TEXT_Fragments

;; thx XK
Custom_BufferText:
    LDY #$0
	ASL A ; Rotate A left one
	TAX ; A->X
	LDA Custom_TextPointers, X ; Load low pointer
	STA $0 ; Store one byte to low address
	LDA Custom_TextPointers + 1, X ; Store high pointer
	STA $1 ; Store one byte to low address
	LDA ($0), Y ; Load the length of data to copy
	TAY
-
	LDA ($0), Y ; Load our PPU data...
	STA PPUBuffer_301 - 1, Y ; ...and store it in the buffer
	DEY
	BNE -
	RTS

Custom_BufferTextNMI:
    JSR Custom_BufferText
    JSR WaitForNMI
    RTS

TEXT_Digits:
    .db $2+4,$26,$C8,$2,$db,$e8,$0
Custom_ValueText:
    PHA
    LDA #$6
    STA PPUBuffer_301 - 1
    STX PPUBuffer_301 + 0
    STY PPUBuffer_301 + 1
    LDA #$2
    STA PPUBuffer_301 + 2
    PLA
	JSR GetTwoDigitNumberTiles
    STA PPUBuffer_301 + 4
    STY PPUBuffer_301 + 3
    LDA #$0
    STA PPUBuffer_301 + 5
    JSR WaitForNMI
    RTS


    

IFDEF PAUSE_SCREEN
Draw_Pause_Stats_Palette:
    LDY #0
    LDX #$E1
-
    LDA #$27
	STA $55F, Y
    INY
    TXA
	STA $55F, Y
    INY
    LDA #$45
	STA $55F, Y
    INY
    LDA #%10101010
	STA $55F, Y
    INY
    TXA
    CLC
    ADC #$08
    TAX
    CMP #$F0
    BCC -
    LDA #0
	STA $55F, Y
	LDA #ScreenUpdateBuffer_RAM_55F
	STA ScreenUpdateIndex
    JSR WaitForNMI
    RTS
ENDIF


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


CharSelectInitialize:
      LDA CharacterLock_Variable ; check lock var, if 0 load new var
      CMP #$F
      BNE +
      LDA CharacterInitialLock
      STA CharacterLock_Variable
+     RTS


LockCharacterSelectColor:
      LDA CurrentCharacter
      PHA
      TYA
      PHA

      LDY #3
      LDA #0 
      STA CurrentCharacter
      JMP +
-     DEC CurrentCharacter
      LDA CurrentCharacter
      AND #3
      CMP #0
      BEQ +++
+     JSR ChkToNextValidCharacter
      BNE ++
      INY
      INY
      INY
      INY
      JMP     -
++    LDA     #$0f
      STA     PPUBuffer_301,Y
      LDA     #$12
      INY
      STA     PPUBuffer_301,Y
      INY
      STA     PPUBuffer_301,Y
      INY
      STA     PPUBuffer_301,Y
      INY
      JMP     -

+++   PLA
      TAY
      PLA
      STA CurrentCharacter
      RTS

ChkToNextValidCharacter:
      LDA     CurrentCharacter
      AND     #$3
      STA     CurrentCharacter
      TAX
      LDA     CharLookupTable, X
      AND     CharacterLock_Variable
      RTS

; $00 Mario
; $01 Princess
; $02 Toad
; $03 Luigi
; however on screen
; $00 Mario
; $03 Luigi
; $02 Toad
; $01 Princess
CharLookupTable:
	.db $01 ; Mio 
	.db $08 ; Pch 
	.db $04 ; Tod 
	.db $02 ; Lug 

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