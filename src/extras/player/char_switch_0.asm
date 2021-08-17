; $00 Mario
; $01 Princess
; $02 Toad
; $03 Luigi
; however on screen
; $00 Mario
; $03 Luigi
; $02 Toad
; $01 Princess

HandlePlayer_ChangeChar: ; make this less dumb
    LDA CurrentCharacter
    CMP PreviousCharacter
    BEQ +end
	STA PreviousCharacter
	LDA PlayerCurrentSize
	EOR #$1
	STA PlayerCurrentSize
+copy
    JSR CustomCopyChar
+end
HandlePlayer_ChangeCharInput: ; make this less dumb
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
++  LDA Player1JoypadPress
	AND #ControllerInput_Right
    BEQ +
-   DEC CurrentCharacter
    JSR ChkToNextValidCharacter
    BNE -
+
	RTS