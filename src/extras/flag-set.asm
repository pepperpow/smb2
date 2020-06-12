; Flag Set
; Takes PTR, 
Level_Bit_Flags = $7300
World_Bit_Flags = $73D2
Level_Count_Discovery = $73E0
Level_Count_MushCount = $73E1
Level_Count_Coins = $73E2
Level_Count_1ups = $73E3
Level_Count_SubspaceVisits = $73E4
Level_Count_Unlocks = $73E5
Level_Count_BigKill = $73E6
Level_Count_KillCnt = $73E6
Level_Count_LivesLost = $73E7
Level_Count_Crystals = $73E8
Level_Count_Cherries = $73E9
World_Count_Bosses = $73EF
CurrentLevelAreaIndex = $73F0
StatPrintOffset = $73F1
StatPrintCurOffset = $73F2
StatPrintDec = $73F3
StatPrintDecRow = $73F4

PlayerIndependentLives = $73F8
PlayerIndependentMaxHealth = $73FC

CustomBitFlag_Boss_Defeated = %00000010

CustomBitFlag_Visited = %00000001
CustomBitFlag_Mush1 = %00000010
CustomBitFlag_Mush2 = %00000100
CustomBitFlag_1up = %00001000
CustomBitFlag_Sub1 = %00010000
CustomBitFlag_Sub2 = %00100000
CustomBitFlag_Key = %01000000
CustomBitFlag_Crystal = %10000000

CustomCharFlag_Shrinking = %00000001
CustomCharFlag_Running = %00000010
CustomCharFlag_Fluttering = %00000100
CustomCharFlag_PeachWalk = %00001000
CustomCharFlag_WeaponCherry = %00010000
CustomCharFlag_StoreCherry = %00100000
CustomCharFlag_AirControl = %01000000
CustomCharFlag_WideSprite = %10000000

CustomCharFlag_StandStill = %00000001

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
GBreaker:
    .db $0  ;; gbreak
DebugSet:
    .db $1  ;; debug
ResetHealth:
    .db $06  ;; reset health (after slots/boss)
StartHealth:
    .db $08  ;; start health
MaxedHealth:
    .db $ff  ;; maxed health
IndependentLives:
    .db $0  ;; elimination mode
IndependentPlayers:
    .db $0  ;; powerups per player
CharSelectDeath:
    .db $2  ;; select death
CharSelectAnytime:
    .db $1  ;; select death
FluteVisit:
    .db $0
BossMushroom:
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
    .db $0 ;; crystals
BossCondition:
    .db $0  ;; bosses
RescueCondition:
    .db $0  ;; ok
WinLevel:
    .db $FF ;; bosses
ChampionChance:
    .db $10

BonusChanceText_PUSH_OTHER_BUTTON:
	.db $13+4,$22,$87,$13,$DB,$FB,$DC,$DA,$E7,$DC,$DE,$E5,$F7,$FB,$EC,$ED,$DA,$EB,$ED,$FB,$D1,$EE,$E9,$0
TEXT_UP:
	.db $2+4,$2E,$58,$2,$EE,$E9,$0
TEXT_DN:
	.db $2+4,$2E,$F8,$2,$DD,$E7,$0
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
Custom_TextPointers:
	.dw BonusChanceText_PUSH_OTHER_BUTTON ; 0
    .dw TEXT_UP ; 1
    .dw TEXT_DN ; 1
    .dw TEXT_EQUIP ; 1
    .dw TEXT_UPGRADE ; 1
    .dw TEXT_Mario ; 1
    .dw TEXT_Princess ; 1
    .dw TEXT_Toad; 1
    .dw TEXT_Luigi ; 1

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


    
TestMyDraw:
    LDA #$3
    JSR Custom_BufferText
	LDA #ScreenUpdateBuffer_RAM_301
	STA ScreenUpdateIndex
    JSR WaitForNMI
    LDA #$4
    JSR Custom_BufferText
	LDA #ScreenUpdateBuffer_RAM_301
	STA ScreenUpdateIndex
    JSR WaitForNMI
+
    LDY #$0
    LDA #$58
    STA byte_RAM_0 
    LDA #$30
    STA byte_RAM_1
    LDA #$00
    STA byte_RAM_B
    STA byte_RAM_C
    LDX #$A2
	JSR SetSpriteTiles
    LDA #$58
    STA byte_RAM_0 
    LDA #$40
    STA byte_RAM_1
    LDX #$A2
    LDA #$00
    STA byte_RAM_B
    STA byte_RAM_C
	JSR SetSpriteTiles
    LDA #$58
    STA byte_RAM_0 
    LDA #$50
    STA byte_RAM_1
    LDX #$A2
    LDA #$00
    STA byte_RAM_B
    STA byte_RAM_C
	JSR SetSpriteTiles
    RTS

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


IFDEF PAUSE_SCREEN

TEXT_Health:
    .db $e1,$de,$da,$e5,$ed,$e1,$f8,$f8,$f8,$f8,$f8,$f8,$f8,$f8,$f8,$d0
TEXT_Extra_Lives:
    .db $de,$f1,$ed,$eb,$da,$fb,$e5,$e2,$ef,$de,$ec,$f8,$f8,$f8,$f8,$d0
TEXT_Coins:
    .db $dc,$e8,$e2,$e7,$ec,$f8,$f8,$f8,$f8,$f8,$f8,$f8,$f8,$f8,$f8,$d0
TEXT_Cherries:
    .db $dc,$e1,$de,$eb,$eb,$f2,$ec,$f8,$f8,$f8,$f8,$f8,$f8,$f8,$f8,$d0
TEXT_Crystals:
    .db $dc,$eb,$f2,$ec,$ed,$da,$e5,$ec,$f8,$f8,$f8,$f8,$f8,$f8,$f8,$d0
TEXT_Bosses:
    .db $db,$e8,$ec,$ec,$de,$ec,$f8,$f8,$f8,$f8,$f8,$f8,$f8,$f8,$f8,$d0
TEXT_Fragments:
    .db $DF,$EB,$DA,$E0,$E6,$DE,$E7,$ED,$EC,$F8,$F8,$F8,$F8,$F8,$F8,$d0
TEXT_Total_Rooms:
    .db $ed,$e8,$ed,$da,$e5,$fb,$eb,$e8,$e8,$e6,$ec,$f8,$f8,$f8,$f8,$d0
TEXT_Continues:
    .db $dc,$e8,$e7,$ed,$e2,$e7,$ee,$de,$ec,$f8,$f8,$f8,$f8,$f8,$f8,$d0
TEXT_Max_Health:
    .db $e6,$da,$f1,$fb,$e1,$de,$da,$e5,$ed,$e1,$f8,$f8,$f8,$f8,$f8,$d0
TEXT_Total_1ups:
    .db $e6,$da,$f1,$fb,$e5,$e2,$ef,$de,$ec,$f8,$f8,$f8,$f8,$f8,$f8,$d0
TEXT_Murders:
    .db $e6,$ee,$eb,$dd,$de,$eb,$ec,$f8,$f8,$f8,$f8,$f8,$f8,$f8,$f8,$d0
TEXT_Crystals2:
    .db $dc,$eb,$f2,$ec,$ed,$da,$e5,$ec,$f8,$dc,$f8,$f8,$f8,$f8,$f8,$d0
TEXT_Bosses2:
    .db $db,$e8,$ec,$ec,$de,$ec,$f8,$dc,$f8,$f8,$f8,$f8,$f8,$f8,$f8,$d0

StatDrawMemory:
    .dw PlayerHealth
    .dw ExtraLives
    .dw SlotMachineCoins
    .dw Level_Count_Cherries
    .dw Level_Count_Crystals
    .dw World_Count_Bosses
    .dw MushroomFragments
    .dw Level_Count_Discovery
    .dw Continues
    .dw PlayerMaxHealth
    .dw Level_Count_1ups
    .dw Level_Count_KillCnt
    .dw CrystalCondition
    .dw BossCondition

InputPause_Stats:
	LDA Player1JoypadHeld
	AND #ControllerInput_Down | #ControllerInput_Up
    BEQ +
    AND #ControllerInput_Down
    BEQ +++
    INC StatPrintOffset
    INC StatPrintOffset
+++ DEC StatPrintOffset   
    BEQ ++
    BPL +++
    LDA #0
    STA StatPrintOffset
    JMP ++
+++ LDA StatPrintOffset
    CMP #$9
    BCC ++
    LDA #$8
    STA StatPrintOffset
++  LDA #ScreenUpdateBuffer_RAM_55F
	STA ScreenUpdateIndex
    JSR Draw_Pause_Stats
+   RTS


Draw_Pause_Stats: ;; needs some clear refactoring but works, very dated
    LDA #$1 
    JSR Custom_BufferText
	LDA #ScreenUpdateBuffer_RAM_301
	STA ScreenUpdateIndex
    JSR WaitForNMI
    LDA #$2
    JSR Custom_BufferText
    JSR WaitForNMI
    LDA #$0 
	LDX StatPrintOffset
    STX StatPrintCurOffset
--  BEQ ++
    CLC
    ADC #$10
    DEX
    JMP --
++
    TAX
    LDA #$60 ;; amount of characters to print, 0x10 per line
    STA StatPrintDec
    LDA #$46 ;; starting row
    STA StatPrintDecRow
    LDY #0
-   
    LDA TEXT_Health, X
	STA $55F+3, Y
    INX
    INY
    CPY #$10
    BNE +
    LDA #$26
	STA $55F
    LDA StatPrintDecRow
	STA $55F + 1
    CLC
    ADC #$20
    STA StatPrintDecRow
    LDA #$12
	STA $55F + 2
    LDA #$FB
	STA $55F + 3, Y
    LDA #$FB
	STA $55F + 4, Y
    LDA #0
	STA $55F + 5, Y
    LDA StatPrintCurOffset 
    ASL
    TAY
    LDA StatDrawMemory, Y
    STA $c5
    LDA StatDrawMemory + 1, Y
    STA $c5 + 1
    LDY #$0
    LDA ($c5), Y
    LDY StatPrintCurOffset
    CPY #$0
    BNE +++
    LSR
    LSR
    LSR
    LSR
    CLC
    ADC #1
+++	JSR GetTwoDigitNumberTiles
    STA $55F + 18
    STY $55F + 17
    INC StatPrintCurOffset 
    TXA
    PHA
	LDA #ScreenUpdateBuffer_RAM_55F
	STA ScreenUpdateIndex
    JSR WaitForNMI
    LDY #$0
    PLA
    TAX
+   DEC StatPrintDec
    BNE -
++
	LDA #$25
	STA $55F
	LDA #$0E
	STA $55F + 1
	LDA #$07
	STA $55F + 2
    LDA #$0 
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

