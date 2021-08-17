
TestMyDraw:
    LDA SpriteCHR4
    CMP #$32
    BNE ++
    RTS
++
	LDA #ScreenUpdateBuffer_RAM_301
	STA ScreenUpdateIndex
    LDA #$1 ; equipment
    JSR Custom_BufferTextNMI
    LDA CrystalCondition
    BEQ +
    LDA #$7 ; crystals
    JSR Custom_BufferTextNMI
    LDA Level_Count_Crystals
    LDX #$26
    LDY #$B3
    JSR Custom_ValueText
    LDA CrystalCondition
    LDX #$26
    LDY #$B6
    JSR Custom_ValueText
+
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
    LDA #$9 ; frag
    JSR Custom_BufferTextNMI
    LDA MushroomFragments
    LDX #$26
    LDY #$f3
    JSR Custom_ValueText
+
    LDY #$0
    LDA #$32
    STA SpriteCHR4

    LDA PlayerInventory
    JSR DisplayItem
    LDA PlayerInventory + 1
    JSR DisplayItem
    LDA SpriteDMAArea + 3, Y
    CLC
    ADC #$10
    STA SpriteDMAArea + 3, Y
    ADC #$8
    STA SpriteDMAArea + 7, Y
    LDA PlayerInventory + 2
    JSR DisplayItem
    LDA SpriteDMAArea + 3, Y
    CLC
    ADC #$20
    STA SpriteDMAArea + 3, Y
    ADC #$8
    STA SpriteDMAArea + 7, Y
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