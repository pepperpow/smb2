.include "src/extras/player/custom-player-render.asm"


; Tiles to use for eye sprite. If $00, this will use the character-specific table
CharacterFrameEyeTiles:
	.db $00 ; Walk1
	.db $00 ; Carry1
	.db $00 ; Walk2
	.db $00 ; Carry2
	.db $FB ; Duck
	.db $FB ; DuckCarry
	.db $00 ; Jump
	.db $FB ; Death
	.db $FB ; Lift
	.db $00 ; Throw
	.db $FB ; Climb

; Specific to each character
CharacterEyeTiles:
	.db $D5 ; Mario
	.db $D9 ; Luigi
	.db $FB ; Toad
	.db $D7 ; Princess

DamageInvulnBlinkFrames:
	.db $01, $01, $01, $02, $02, $04, $04, $04
	
;
; Renders the player sprite
;
RenderPlayer:
	LDY_abs PlayerState
	CPY #PlayerState_ChangingSize
	BEQ loc_BANKF_F337

	LDY StarInvincibilityTimer
	BNE loc_BANKF_F337

	LDA DamageInvulnTime ; Determine if the player is invincible from damage,
; and if so, if they should be visible
	BEQ loc_BANKF_F345

	LSR A
	LSR A
	LSR A
	LSR A
	TAY
	LDA DamageInvulnTime
	AND DamageInvulnBlinkFrames, Y
	BNE loc_BANKF_F345

	RTS

; ---------------------------------------------------------------------------

loc_BANKF_F337:
	LDA byte_RAM_10
	CPY #$18
	BCS loc_BANKF_F33F

	LSR A
	LSR A

loc_BANKF_F33F:
	AND #ObjAttrib_Palette
	ORA PlayerAttributes
	STA PlayerAttributes

loc_BANKF_F345:
	LDA QuicksandDepth
	BEQ loc_BANKF_F350

	LDA #ObjAttrib_BehindBackground
	ORA PlayerAttributes
	STA PlayerAttributes

loc_BANKF_F350:
	LDA PlayerScreenX
    LDA PlayerCurrentSize ;; move X pos depending on if "wide"
    BNE ++
    LDX CurrentCharacter
    LDA DokiMode, X
    BPL ++
    LDA PlayerDirection
    BNE +++
	LDA PlayerScreenX
    CLC
    ADC #$04
    STA PlayerScreenX
    JMP ++
+++
	LDA PlayerScreenX
    SEC
    SBC #$04
    STA PlayerScreenX
    JMP ++
++
	LDA PlayerScreenX
	STA SpriteDMAArea + $23
	STA SpriteDMAArea + $2B
	CLC
	ADC #$08
	STA SpriteDMAArea + $27
	STA SpriteDMAArea + $2F
    LDA PlayerDirection
    BEQ +
	LDA PlayerScreenX
	CLC
	ADC #$10
    JMP ++
+
	LDA PlayerScreenX
	SEC
	SBC #$08
++
	STA SpriteDMAArea + $1B
	STA SpriteDMAArea + $1F
	LDA PlayerScreenYLo
	LDX PlayerAnimationFrame
	CPX #SpriteAnimation_Ducking
    BEQ +
    LDX CurrentCharacter
    CLC
    ADC HeightOffset, X
+
	STA byte_RAM_0
	LDA PlayerScreenYHi
	STA byte_RAM_1
	LDY PlayerAnimationFrame
	CPY #$04
	BEQ loc_BANKF_F382

	LDA PlayerCurrentSize
	BEQ loc_BANKF_F382

	LDA byte_RAM_0
    LDX CurrentCharacter
    CLC
    ADC HeightOffset + 4, X

	STA byte_RAM_0
	BCC loc_BANKF_F382

	INC byte_RAM_1

loc_BANKF_F382:
    LDA DokiMode, X
    AND #CustomCharFlag_PeachWalk
	BNE loc_BANKF_F394

	CPY #$00
	BNE loc_BANKF_F394

	LDA byte_RAM_0
	BNE loc_BANKF_F392

	DEC byte_RAM_1

loc_BANKF_F392:
	DEC byte_RAM_0

loc_BANKF_F394:
	JSR FindSpriteSlot

	LDA byte_RAM_1
	BNE loc_BANKF_F3A6

	LDA byte_RAM_0
	STA SpriteDMAArea, Y
	STA SpriteDMAArea + $20
	STA SpriteDMAArea + $24

loc_BANKF_F3A6:
	LDA byte_RAM_0
	CLC
	ADC #$10
	STA byte_RAM_0
	LDA byte_RAM_1
	ADC #$00
	BNE loc_BANKF_F3BB

	LDA byte_RAM_0
	STA SpriteDMAArea + $28
	STA SpriteDMAArea + $2C

loc_BANKF_F3BB:
	LDA CrouchJumpTimer
	CMP #$3C
	BCC loc_BANKF_F3CA

	LDA byte_RAM_10
	AND #ObjAttrib_Palette1
	ORA PlayerAttributes
	STA PlayerAttributes

loc_BANKF_F3CA:
	LDA PlayerDirection
	LSR A
	ROR A
	ROR A
	ORA PlayerAttributes
	AND #%11111100
	ORA #ObjAttrib_Palette1
	STA SpriteDMAArea + 2, Y
	AND #$FC
	ORA PlayerAttributes
	STA SpriteDMAArea + $22
	STA SpriteDMAArea + $2A
	STA SpriteDMAArea + $26
	STA SpriteDMAArea + $2E
    LDA PlayerCurrentSize
    JSR ApplyMetaInformation
	LDX PlayerAnimationFrame
	LDA CharacterFrameEyeTiles, X
	BNE loc_BANKF_F408

	LDX CurrentCharacter
	LDA CharacterEyeTiles, X

loc_BANKF_F408:
	STA SpriteDMAArea + 1, Y
	LDA PlayerAnimationFrame
	CMP #$06
	BCS loc_BANKF_F413

	ORA HoldingItem

loc_BANKF_F413:
	ASL A
	ASL A
	TAX
    LDA PlayerCurrentSize
    BEQ +
    JMP RenderSmallPlayer
+
	LDA PlayerDirection
	BNE loc_BANKF_F44A

	LDA SpriteDMAArea + $23
	STA SpriteDMAArea + 3, Y
    TXA
    CLC
	LDX CurrentCharacter
    ADC CharacterStartTiles, X
    TAX
	LDA CharacterOne_Frames, X
	STA SpriteDMAArea + $21
	LDA CharacterOne_Frames + 1, X
	STA SpriteDMAArea + $25

loc_BANKF_F43F:
	LDA CharacterOne_Frames + 2, X
	STA SpriteDMAArea + $29
	LDA CharacterOne_Frames + 3, X
	BNE loc_BANKF_F478

loc_BANKF_F44A:
    TXA
    CLC
	LDX CurrentCharacter
    ADC CharacterStartTiles, X
    TAX
	LDA SpriteDMAArea + $27
	STA SpriteDMAArea + 3, Y
	LDA CharacterOne_Frames + 1, X
	STA SpriteDMAArea + $21
	LDA CharacterOne_Frames, X
	STA SpriteDMAArea + $25

loc_BANKF_F46F:
	LDA CharacterOne_Frames + 3, X
	STA SpriteDMAArea + $29
	LDA CharacterOne_Frames + 2, X

loc_BANKF_F478:
	STA SpriteDMAArea + $2D

    TXA
	PHA
	JSR FindSpriteSlot
	PLA
    LSR
    TAX
	LDA ExtraFramesOne, X
	CMP #$FB
	BEQ +++
	STA SpriteDMAArea + 1, Y
	LDA SpriteDMAArea + $20
	STA SpriteDMAArea + 0, Y
	STA SpriteDMAArea + 2, Y
;    CMP #$FB
;    BNE +
;	STA SpriteDMAArea + $18
;+
+++
	LDA ExtraFramesOne + 1, X
	CMP #$FB
	BEQ +++
	STA SpriteDMAArea + 5, Y
	LDA SpriteDMAArea + $28
	STA SpriteDMAArea + 4, Y
    LDA PlayerDirection
    BEQ +
	LDA SpriteDMAArea + $23
	CLC
	ADC #$10
    JMP ++
+
	LDA SpriteDMAArea + $23
	SEC
	SBC #$08
++
	STA SpriteDMAArea + 3, Y
	STA SpriteDMAArea + 7, Y
	LDA SpriteDMAArea + $22
	STA SpriteDMAArea + 2, Y
	STA SpriteDMAArea + 6, Y
    LDA ($c5)
    AND #%10000
    BEQ +
	LDA SpriteDMAArea + $22
    EOR #$40
	STA SpriteDMAArea + 2, Y
+
    LDA ($c5)
    AND #%100000
    BEQ +
	LDA SpriteDMAArea + $22
    EOR #$40
	STA SpriteDMAArea + 6, Y
+
;	STA SpriteDMAArea + $1d
;    CMP #$FB
;    BNE +
;	STA SpriteDMAArea + $1C
;+
+++
    RTS