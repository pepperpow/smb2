
HandlePlayer_ChangeChar: ; make this less dumb
	LDA CharSelectAnytime
	BEQ +
    LDA PlayerInAir
    BNE +
	LDA Player1JoypadHeld
	AND #ControllerInput_Select
    BEQ +
	LDA Player1JoypadPress
	AND #ControllerInput_Left
    BEQ ++
-   INC CurrentCharacter
    JSR ChkToNextValidCharacter
    BNE -
	BEQ +
++
	LDA Player1JoypadPress
	AND #ControllerInput_Right
    BEQ +
-   DEC CurrentCharacter
    JSR ChkToNextValidCharacter
    BNE -
+
    LDA CurrentCharacter
    CMP PreviousCharacter
    BEQ +end
	STA PreviousCharacter
	LDA CharSelectAnytime
	BEQ +
	LDA PlayerCurrentSize
	EOR #$1
	STA PlayerCurrentSize
+
    JSR CustomCopyChar
+end
	RTS