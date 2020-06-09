NewHealthRender:
    TYA
    PHA
    TXA
    PHA
    LDA PlayerHealth
    BEQ ++
;    LDX ProjectileType
;    LDA ProjectileTileHealth, X
;    STA SpriteDMAArea + 1, Y
;    PLA
;    TAX
;    JMP +++
++  PLA
    TAX
DrawHealthPip:
    LDA #$BA
    STA SpriteDMAArea+1,Y
+++
    LDA #$10
    STA SpriteDMAArea+3,Y
    LDA #3
    STA SpriteDMAArea+2,Y
    LDA byte_RAM_0
    STA SpriteDMAArea,Y
    CLC
    ADC #$10
    STA byte_RAM_0
    INX
    INC byte_RAM_3
    INC byte_RAM_3
    LDA byte_RAM_3
    CMP #6
    BCS +
    CMP PlayerMaxHealth
    BCS +
    INY
    INY
    INY
    INY
    JMP DrawHealthPip
+   PLA
    TAX
    TYA
    STA byte_RAM_3
    LDA PlayerHealth
    BEQ EndDrawHealth
FillHealthPip:
    SBC #$10
    BCC EndFillHealth
    TAY
    LDA SpriteDMAArea+1,X
    CMP #$BA
    BNE +
    LDA #$B8
    STA SpriteDMAArea+1,X
+
    DEC SpriteDMAArea+2,X
    DEC SpriteDMAArea+2,X
    TYA
    SBC #$10
    BCC EndFillHealth
    ;DEC SpriteDMAArea+2,X
    ;SBC #$10
    ;BCC EndFillHealth
    INX
    CPX byte_RAM_3
    BCS EndFillHealth
    INX
    INX
    INX
    JMP FillHealthPip
EndFillHealth:
    LDA PlayerHealth
    CMP #$8F
    BCS EndDrawHealth
    LDA #$12
    STA SpriteDMAArea+3,X
    LDY BackgroundCHR2 
    CPY #$20
    BCC EndDrawHealth
    LDA SpriteDMAArea+2,X
    CMP #$3
    BNE EndDrawHealth
    DEC SpriteDMAArea+2,X
    ;LDA #$B8
    ;STA SpriteDMAArea+1,X
    ;DEC SpriteDMAArea+2,X
    ;DEC SpriteDMAArea+2,X
EndDrawHealth:
    RTS
