    TXA
    PHA
    TYA
    PHA
    LDA ObjectType, Y
    CMP #Enemy_Fireball
    BEQ ++
    CMP #Enemy_FryguySplit
    BEQ ++
    CMP #Enemy_Fryguy
    BEQ ++
    CMP #Enemy_Spark1
    BEQ +++
    CMP #Enemy_Spark2
    BEQ +++
    CMP #Enemy_Spark3
    BEQ +++
    CMP #Enemy_Spark4
    BEQ +++
    JMP +
++  LDX #CustomBitFlag_ImmuneFire
    JSR ChkFlagPlayer
    BNE +
    JMP ImmuneSuccess
+++ LDX #CustomBitFlag_ImmuneElec
    JSR ChkFlagPlayer
    BNE +
ImmuneSuccess:
    PLA
    TAY
    PLA
    TAX
    JMP locret_BANK3_BA31
+   PLA
    TAY
    PLA
    TAX
DamagePlayerNoImmune: