;
;
;
IndependentLives:
    .db $1  ;; elimination mode
IndependentPlayers:
    .db $0  ;; powerups per player
BossCondition:
    .db $1  ;; bosses
CrystalCondition:
    .db $1 ;; crystals
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

DokiMode:
    .db 0  ;; doki
    .db CustomCharFlag_PeachWalk
    .db 0  ;; doki
    .db CustomCharFlag_Fluttering

HeightOffset:
    .db 0,0,0,0
    .db 8,8,8,8

CharLookupTable:
	.db $01 ; Mio 
	.db $08 ; Pch 
	.db $04 ; Tod 
	.db $02 ; Lug 

ChkToNextValidCharacter:
      LDA     CurrentCharacter
      AND     #$3
      STA     CurrentCharacter
      TAX
      LDA     CharLookupTable, X
      AND     CharacterLock_Variable
      RTS

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

TestMyDraw:
    LDA SpriteCHR4
    CMP #$32
    BNE ++
    RTS
++
; 	LDA #ScreenUpdateBuffer_RAM_301
; 	STA ScreenUpdateIndex
;     LDA #$1 ; equipment
;     JSR Custom_BufferTextNMI
;     LDA CrystalCondition
;     BEQ +
;     LDA #$7 ; crystals
;     JSR Custom_BufferTextNMI
;     LDA Level_Count_Crystals
;     LDX #$26
;     LDY #$B3
;     JSR Custom_ValueText
;     LDA CrystalCondition
;     LDX #$26
;     LDY #$B6
;     JSR Custom_ValueText
; +
    LDA BossCondition
    BEQ +
    LDA #$8 ; bosses
    JSR Custom_BufferTextNMI
    LDA World_Count_Bosses
    LDX #$26
    LDY #$93
    JSR Custom_ValueText
    LDA BossCondition
    LDX #$26
    LDY #$96
    JSR Custom_ValueText
+
;     LDA #$9 ; frag
;     JSR Custom_BufferTextNMI
;     LDA MushroomFragments
;     LDX #$26
;     LDY #$f3
;     JSR Custom_ValueText
; +
    LDY #$0
    LDA #$32
    STA SpriteCHR4

    ; LDA PlayerInventory
    ; JSR DisplayItem
    ; LDA PlayerInventory + 1
    ; JSR DisplayItem
    ; LDA SpriteDMAArea + 3, Y
    ; CLC
    ; ADC #$10
    ; STA SpriteDMAArea + 3, Y
    ; ADC #$8
    ; STA SpriteDMAArea + 7, Y
    ; LDA PlayerInventory + 2
    ; JSR DisplayItem
    ; LDA SpriteDMAArea + 3, Y
    ; CLC
    ; ADC #$20
    ; STA SpriteDMAArea + 3, Y
    ; ADC #$8
    ; STA SpriteDMAArea + 7, Y
    RTS

DisplayItem:
    PHA
    PHA
	JSR FindSpriteSlot
    LDA #$58
    STA SpriteDMAArea, Y
    STA SpriteDMAArea + 4, Y
    LDA #$38
    CLC
    STA SpriteDMAArea + 3, Y
    ADC #$8
    STA SpriteDMAArea + 7, Y
    LDA #$0
    STA SpriteDMAArea + 2, Y
    STA SpriteDMAArea + 6, Y
    PLA
    TAX
    LDA EnemyCustom_Attributes, X
	AND #ObjAttrib_Mirrored
    BEQ +
    LDA #$40
    STA SpriteDMAArea + 6, Y
+
    PLA
    ASL
    TAX
    LDA EnemyCustom_TableSprites, X
    STA SpriteDMAArea + 1, Y
    LDA EnemyCustom_TableSprites + 1, X
    STA SpriteDMAArea + 5, Y
    RTS
ENDIF