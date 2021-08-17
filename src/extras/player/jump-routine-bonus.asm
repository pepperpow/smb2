
	LDA Player1JoypadPress
    BPL +++ ; branch if not pressing A Button
	LDA PlayerInAir
    CMP #1
    BCC +++
    CMP #2
    BEQ + 
    LDX #CustomBitFlag_AirHop
    JSR ChkFlagPlayer2
    BNE +
    LDA HoldingItem
    BEQ +
    JSR SkipToThrowCheck
    LDA HoldingItem
    BNE +
    LDA #$0
	STA ObjectXVelocity, X
    LDA #$20
	STA ObjectYVelocity, X
    INC PlayerInAir
	JSR PlayerStartJump
	LDA #SoundEffect2_Jump
	STA SoundEffectQueue2
	LDA Player1JoypadPress
    EOR #ControllerInput_A
    STA Player1JoypadPress
    JMP +++
+
    LDX #CustomBitFlag_SpaceJump
    JSR ChkFlagPlayer3
    BNE +
    LDA PlayerYVelocity
    BMI +
    LDA PlayerYVelocity
    CMP #$30
    BCS +
	JSR PlayerStartJump
    INC PlayerInAir
	LDA #SoundEffect2_Jump
	STA SoundEffectQueue2
	LDA Player1JoypadPress
    EOR #ControllerInput_A
    STA Player1JoypadPress
    JMP +++
+
    LDX #CustomBitFlag_KirbyJump
    JSR ChkFlagPlayer3
    BNE +++
	JSR PlayerStartJump
    INC PlayerInAir
	LDA PlayerYVelocity
    ASL
    ROR PlayerYVelocity
	LDA #SoundEffect2_Jump
	STA SoundEffectQueue2
	LDA Player1JoypadPress
    EOR #ControllerInput_A
    STA Player1JoypadPress
    JMP +++
+++
    JSR Player_FloatJump
    JSR Player_GroundPound
	LDA PlayerInAir