
    STA PlayerIntermediateValue
    TXA ;; preserve obj position
    PHA
    LDX #CustomBitFlag_PowerThrow
    LDA #$0
    JSR ChkFlagPlayer
    BNE +
	LDA CrouchJumpTimer ; check if crouch jump is charged
	CMP #$3C
	BCC +
    LDA #0 ; success
    STA CrouchJumpTimer
	LDA #SoundEffect1_HawkOpen_WartBarf
	STA SoundEffectQueue1
    LDA PlayerDirection
    BEQ ++
    LDA #$70
    STA PlayerIntermediateValue
    JMP +
++  LDA #$90
    STA PlayerIntermediateValue
+   PLA ;; resume obj position
    TAX
	LDA byte_RAM_1
	ASL A
	ORA PlayerDirection
	TAY ;; pretty sure this accidentally sets something incorrectly to not reduce object speed
	LDA #$0
    CLC
    ADC PlayerIntermediateValue
	STA ObjectXVelocity, X
    LDA #$0
    STA PlayerIntermediateValue