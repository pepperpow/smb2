
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

CharacterTiles_Walk1:
	.db $00
	.db $02
	.db $04 ; $00 - start of relative character tile offets, for some reason
	.db $06 ; $01

CharacterTiles_Carry1:
	.db $0C ; $02
	.db $0E ; $03
	.db $10 ; $04
	.db $12 ; $05

CharacterTiles_Walk2:
	.db $00 ; $06
	.db $02 ; $07
	.db $08 ; $08
	.db $0A ; $09

CharacterTiles_Carry2:
	.db $0C ; $0a
	.db $0E ; $0b
	.db $14 ; $0c
	.db $16 ; $0d

CharacterTiles_Duck:
	.db $FB ; $0e
	.db $FB ; $0f
	.db $2C ; $10
	.db $2C ; $11

CharacterTiles_DuckCarry:
	.db $FB ; $12
	.db $FB ; $13
	.db $2E ; $14
	.db $2E ; $15

CharacterTiles_Jump:
	.db $0C ; $16
	.db $0E ; $17
	.db $10 ; $18
	.db $12 ; $19

CharacterTiles_Death:
	.db $30 ; $1a
	.db $30 ; $1b
	.db $32 ; $1c
	.db $32 ; $1d

CharacterTiles_Lift:
	.db $20 ; $1e
	.db $22 ; $1f
	.db $24 ; $20
	.db $26 ; $21

CharacterTiles_Throw:
	.db $00 ; $22
	.db $02 ; $23
	.db $28 ; $24
	.db $2A ; $25

CharacterTiles_Climb:
	.db $18 ; $26
	.db $1A ; $27
	.db $1C ; $28
	.db $1E ; $29

CharacterTiles_PrincessJumpBody:
	.db $B4 ; $2a
	.db $B6 ; $2b

DamageInvulnBlinkFrames:
	.db $01, $01, $01, $02, $02, $04, $04, $04

IFDEF CONTROLLER_2_DEBUG
ChangePlayerPoofTiles:
	.db $5E
	.db $3A
	.db $3A
	.db $3A
	.db $38
	.db $38
	.db $38
	.db $36
	.db $34
ENDIF

;
; Renders the player sprite
;
RenderPlayer:
IFDEF CONTROLLER_2_DEBUG
	LDA ChangeCharacterPoofTimer
	BEQ RenderPlayer_AfterChangeCharacterPoof

	DEC ChangeCharacterPoofTimer

	; tile
	LDY ChangeCharacterPoofTimer
	LDA ChangePlayerPoofTiles, Y
	STA SpriteDMAArea + $01
	STA SpriteDMAArea + $05
	STA SpriteDMAArea + $09
	STA SpriteDMAArea + $0D

	; attributes
	LDA #ObjAttrib_Palette1
	STA SpriteDMAArea + $02
	STA SpriteDMAArea + $0A
	LDA #ObjAttrib_Palette1 | ObjAttrib_16x32
	STA SpriteDMAArea + $06
	STA SpriteDMAArea + $0E

	; y-position
	LDA PlayerScreenYLo
	STA SpriteDMAArea + $00
	STA SpriteDMAArea + $04
	CLC
	ADC #$10
	STA SpriteDMAArea + $08
	STA SpriteDMAArea + $0C

	; x-position
	LDA PlayerScreenX
	STA SpriteDMAArea + $03
	STA SpriteDMAArea + $0B
	CLC
	ADC #$08
	STA SpriteDMAArea + $07
	STA SpriteDMAArea + $0F

RenderPlayer_AfterChangeCharacterPoof:
ENDIF

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
	STA SpriteDMAArea + $23
	STA SpriteDMAArea + $2B
	CLC
	ADC #$08
	STA SpriteDMAArea + $27
	STA SpriteDMAArea + $2F
	LDA PlayerScreenYLo
	STA byte_RAM_0
	LDA PlayerScreenYHi
	STA byte_RAM_1
	LDY PlayerAnimationFrame
	CPY #$04
	BEQ loc_BANKF_F382

	LDA PlayerCurrentSize
	BEQ loc_BANKF_F382

	LDA byte_RAM_0
	CLC
	ADC #$08
	STA byte_RAM_0
	BCC loc_BANKF_F382

	INC byte_RAM_1

loc_BANKF_F382:
	LDA CurrentCharacter
	CMP #Character_Princess
	BEQ loc_BANKF_F394

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
	LDX PlayerAnimationFrame
	CPX #$07
	BEQ loc_BANKF_F3E2

	CPX #$04
	BNE loc_BANKF_F3EE

loc_BANKF_F3E2:
	LDA PlayerAttributes
	STA SpriteDMAArea + $22
	STA SpriteDMAArea + $2A
	ORA #$40
	BNE loc_BANKF_F3F8

loc_BANKF_F3EE:
	AND #$FC
	ORA PlayerAttributes
	STA SpriteDMAArea + $22
	STA SpriteDMAArea + $2A

loc_BANKF_F3F8:
	STA SpriteDMAArea + $26
	STA SpriteDMAArea + $2E
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
	LDA PlayerDirection
	BNE loc_BANKF_F44A

	LDA SpriteDMAArea + $23
	STA SpriteDMAArea + 3, Y
	LDA CharacterTiles_Walk1, X
	STA SpriteDMAArea + $21
	LDA CharacterTiles_Walk1 + 1, X
	STA SpriteDMAArea + $25
	LDA PlayerCurrentSize
	BNE loc_BANKF_F43F

	LDA CurrentCharacter
	CMP #Character_Princess
	BNE loc_BANKF_F43F

	LDA PlayerAnimationFrame
	CMP #SpriteAnimation_Jumping
	BNE loc_BANKF_F43F

	LDX #$2A

loc_BANKF_F43F:
	LDA CharacterTiles_Walk1 + 2, X
	STA SpriteDMAArea + $29
	LDA CharacterTiles_Walk1 + 3, X
	BNE loc_BANKF_F478

loc_BANKF_F44A:
	LDA SpriteDMAArea + $27
	STA SpriteDMAArea + 3, Y
	LDA CharacterTiles_Walk1 + 1, X
	STA SpriteDMAArea + $21
	LDA CharacterTiles_Walk1, X
	STA SpriteDMAArea + $25
	LDA PlayerCurrentSize
	BNE loc_BANKF_F46F

	LDA CurrentCharacter
	CMP #Character_Princess
	BNE loc_BANKF_F46F

	LDA PlayerAnimationFrame
	CMP #SpriteAnimation_Jumping
	BNE loc_BANKF_F46F

	LDX #$2A

loc_BANKF_F46F:
	LDA CharacterTiles_Walk1 + 3, X
	STA SpriteDMAArea + $29
	LDA CharacterTiles_Walk1 + 2, X

loc_BANKF_F478:
	STA SpriteDMAArea + $2D
	RTS
