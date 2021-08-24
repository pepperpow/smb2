JumpAttack:
    LDX CurrentCharacter
    LDA PlayerYVelocity
    BMI +
    CMP #$10
    BCC +
    LDA DokiMode, X
    AND #CustomCharFlag_BounceAll
    BNE +ok
    LDA DokiMode, X
    AND #CustomCharFlag_BounceJump
    BEQ +o
    LDA PlayerAnimationFrame
    CMP #SpriteAnimation_Jumping
    BEQ +ok
    JMP +
+o
    LDA DokiMode, X
    AND #CustomCharFlag_GroundPound
    BEQ +o
    LDA Player1JoypadHeld
    AND #ControllerInput_Down
    BEQ +
    LDA CrushTimer
    CMP #$08
    BCS +ok
    LDA #$0
    STA CrushTimer
    JMP +
+o
    JMP +
+ok
    LDA #$0
    STA CrushTimer
    LDA PlayerAnimationFrame
    CMP #SpriteAnimation_Ducking
    BEQ +
    LDA Player1JoypadHeld
    AND #ControllerInput_A
    BEQ ++
    LDA #$A0
    STA PlayerYVelocity
    BNE +++
++  LDA #$C0
    STA PlayerYVelocity
+++ LDX byte_RAM_12
    INX
    LDY #$14
    JSR DamageEnemySingle
	LDX byte_RAM_ED
    PLA
    PLA
    RTS
+
    RTS
