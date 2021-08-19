JumpAttack:
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

; Player_GroundPound:
;     LDA Player1JoypadHeld
;     AND #ControllerInput_Down
;     BEQ +o
;     LDX #CustomBitFlag_GroundPound
;     JSR ChkFlagPlayer3
;     BNE +
;     LDA PlayerYVelocity
;     BMI +
;     CMP #$3F
;     BCS ++
;     INC PlayerYVelocity
;     INC PlayerYVelocity
;     JMP +
; ++
;     LDA CrushTimer
;     CMP #$24
;     BCS ++
;     INC CrushTimer
;     LDA #$8
;     CMP CrushTimer
;     BCS +
;     LDA #SpriteAnimation_CustomFrame1
;     STA PlayerAnimationFrame
;     JMP +
; ++
;     LDA StarInvincibilityTimer
;     BNE +
;     LDA #$4
;     STA StarInvincibilityTimer
; +   RTS
; +o  LDA #$0
;     STA CrushTimer
;     RTS

; Player_GroundPoundHit:
;     LDA PlayerYVelocity
;     BMI +
;     CMP #$3F
;     BCC +
;     LDA CrushTimer
;     CMP #$24
;     BCC +
;     LDX #CustomBitFlag_GroundPound
;     JSR ChkFlagPlayer3
;     BNE +
;     LDA #$20
;     STA POWQuakeTimer
; 	LDA #SoundEffect3_Rumble_B
; 	STA SoundEffectQueue3
; +
;     LDA #$0
;     STA CrushTimer
;     RTS