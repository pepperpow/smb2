;
; Bank A & Bank B
; ===============
;
; What's inside:
;
;   - Level title card background data and palettes
;   - Bonus chance background data and palettes
;   - Character select palettes
;   - Character data (physics, palettes, etc.)
;   - Character stats bootstrapping
;

;
; This title card is used for every world from 1 to 6.
; The only difference is the loaded CHR banks.
;
World1thru6TitleCard:
	.db $FB, $FB, $B0, $B2, $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB
	.db $FB, $FB, $B1, $B3, $FB, $FB, $FB, $FB, $FB, $FB, $C0, $C1, $FB, $FB, $FB, $FB ; $10
	.db $FB, $FB, $B4, $B5, $FB, $FB, $FB, $FB, $B6, $B8, $BA, $B8, $BA, $BC, $FB, $FB ; $20
	.db $FB, $FB, $B4, $B5, $FB, $FB, $FB, $FB, $B7, $B9, $BB, $B9, $BB, $BD, $FB, $FB ; $30
	.db $FB, $FB, $B4, $B5, $FB, $FB, $FB, $FB, $B7, $B9, $BB, $B9, $BB, $BD, $FB, $FB ; $40
	.db $FB, $FB, $B4, $B5, $C0, $C1, $FB, $FB, $B7, $B9, $BB, $B9, $BB, $BD, $FB, $FB ; $50
	.db $CA, $CC, $CA, $CC, $CA, $CC, $CA, $CC, $CA, $CC, $CA, $CC, $CA, $CC, $CA, $CC ; $60
	.db $CB, $CD, $CB, $CD, $CB, $CD, $CB, $CD, $CB, $CD, $CB, $CD, $CB, $CD, $CB, $CD ; $70
	.db $CE, $CF, $CE, $CF, $CE, $CF, $CE, $CF, $CE, $CF, $CE, $CF, $CE, $CF, $CE, $CF ; $80
	.db $CF, $CE, $CF, $CE, $CF, $CE, $CF, $CE, $CF, $CE, $CF, $CE, $CF, $CE, $CF, $CE ; $90

;
; This one is the special one used for World 7
;
World7TitleCard:
	.db $FB, $FB, $B0, $B2, $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB
	.db $FB, $FB, $B1, $B3, $FB, $FB, $FB, $FB, $FB, $FB, $C0, $C1, $FB, $FB, $FB, $FB ; $10
	.db $FB, $FB, $B1, $B3, $FB, $FB, $FB, $FB, $B6, $B8, $BA, $B8, $BA, $BC, $FB, $FB ; $20
	.db $FB, $FB, $B1, $B3, $FB, $FB, $FB, $FB, $B7, $B9, $BB, $B9, $BB, $BD, $FB, $FB ; $30
	.db $FB, $FB, $B1, $B3, $FB, $FB, $FB, $FB, $CA, $FC, $FC, $FC, $FC, $CC, $FB, $FB ; $40
	.db $FB, $FB, $B1, $B3, $C0, $C1, $FB, $FB, $CA, $FC, $FC, $FC, $FC, $CC, $FB, $FB ; $50
	.db $A8, $AC, $AA, $AC, $AA, $AC, $AA, $AC, $AA, $AC, $AA, $AC, $AA, $AC, $AA, $AE ; $60
	.db $A9, $AD, $AB, $AD, $AB, $AD, $AB, $AD, $AB, $AD, $AB, $AD, $AB, $AD, $AB, $AF ; $70
	.db $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB ; $80
	.db $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB ; $90

BonusChanceLayout:
	.db $20, $00, $60, $FD
	.db $20, $20, $60, $FD
	.db $20, $40, $60, $FD
	.db $20, $60, $60, $FD
	.db $23, $40, $60, $FD
	.db $23, $60, $60, $FD
	.db $23, $80, $60, $FD
	.db $23, $A0, $60, $FD
	.db $20, $80, $D6, $FD
	.db $20, $81, $D6, $FD
	.db $20, $82, $D6, $FD
	.db $20, $9D, $D6, $FD
	.db $20, $9E, $D6, $FD
	.db $20, $9F, $D6, $FD

	.db $20, $68, $10
	.db $48, $4A, $4C, $4E, $50, $51, $52, $53, $54, $55, $56, $57, $58, $5A, $5C, $5E

	.db $20, $83, $09, $FD, $FD, $22, $23, $24, $49, $4B, $4D, $4F
	.db $20, $94, $09, $59, $5B, $5D, $5F, $2E, $2F, $30, $FD, $FD
	.db $20, $A3, $04, $FD, $25, $26, $27
	.db $20, $B9, $04, $31, $32, $33, $FD
	.db $20, $C3, $04, $FD, $28, $29, $2A
	.db $20, $D9, $04, $34, $35, $36, $FD
	.db $20, $E3, $03, $2B, $2C, $2D
	.db $20, $FA, $03, $37, $38, $39
	.db $21, $03, $02, $3A, $3B
	.db $21, $1B, $02, $40, $41
	.db $21, $23, $D0, $3C
	.db $21, $3C, $D0, $42
	.db $22, $02, $02, $3E, $3F
	.db $22, $1C, $02, $61, $62
	.db $22, $22, $02, $43, $44
	.db $22, $3C, $02, $63, $64
	.db $22, $43, $01, $45
	.db $22, $5C, $01, $65
	.db $22, $C4, $02, $A6, $A8
	.db $22, $E4, $02, $A7, $A9
	.db $22, $FA, $04, $80, $82, $88, $8A
	.db $23, $04, $02, $90, $92
	.db $23, $14, $02, $9E, $A0
	.db $23, $1A, $04, $81, $83, $89, $8B
	.db $23, $23, $03, $46, $91, $93
	.db $23, $2A, $02, $A2, $A4

	.db $23, $2E, $10
	.db $67, $6C, $6E, $70, $72, $69, $9F, $A1, $75, $98, $9A, $FB, $84, $86, $8C, $8E

	.db $23, $43, $1B
	.db $47, $94, $96, $74, $74, $74, $74, $A3, $A5, $74, $66, $68, $6D, $6F, $71, $73
	.db $6A, $6B, $74, $74, $99, $9B, $74, $85, $87, $8D, $8F

	.db $23, $64, $05, $95, $97, $FD, $AA, $AB
	.db $23, $77, $05, $9C, $9D, $AA, $AB, $AB
	.db $23, $89, $02, $AA, $AB
	.db $20, $C9, $0E, $78, $AC, $B0, $B4, $B7, $BA, $FB, $BC, $BE, $C1, $C4, $C7, $CB, $7C

	.db $20, $E8, $10
	.db $1C, $79, $AD, $B1, $B5, $B8, $BB, $FB, $BD, $BF, $C2, $C5, $C8, $CC, $7D, $1E

	.db $21, $08, $10
	.db $1D, $7A, $AE, $B2, $B6, $B9, $FB, $FB, $FB, $C0, $C3, $C6, $C9, $CD, $7E, $1F

	.db $21, $29, $03, $7B, $AF, $B3
	.db $21, $34, $03, $CA, $CE, $7F
	.db $21, $6A, $0C, $14, $10, $10, $16, $14, $10, $10, $16, $14, $10, $10, $16
	.db $21, $8A, $0C, $11, $FC, $FC, $12, $11, $FC, $FC, $12, $11, $FC, $FC, $12
	.db $21, $AA, $0C, $11, $FC, $FC, $12, $11, $FC, $FC, $12, $11, $FC, $FC, $12
	.db $21, $CA, $0C, $15, $13, $13, $17, $15, $13, $13, $17, $15, $13, $13, $17
	.db $22, $0D, $02, $18, $1A
	.db $22, $2D, $02, $19, $1B
	.db $23, $D2, $04, $80, $A0, $A0, $20
	.db $23, $DA, $04, $88, $AA, $AA, $22
	.db $23, $E4, $01, $0A
	.db $23, $EA, $05, $A0, $A0, $A0, $A0, $20
	.db $00


;
; Copies the Bonus Chance PPU data
;
; This copies in two $100 byte chunks, the second of which includes extra data
; that is never used because of the terminating $00
;
CopyBonusChanceLayoutToRAM:
	LDY #$00
CopyBonusChanceLayoutToRAM_Loop1:
	LDA BonusChanceLayout, Y ; Blindly copy $100 bytes from $8140 to $7400
	STA BonusChanceLayoutRAM, Y
	DEY
	BNE CopyBonusChanceLayoutToRAM_Loop1

	LDY #$00
CopyBonusChanceLayoutToRAM_Loop2:
	; Blindly copy $100 more bytes from $8240 to $7500
	; That range includes this code! clap. clap.
	LDA BonusChanceLayout + $100, Y
	STA BonusChanceLayoutRAM2, Y
	DEY
	BNE CopyBonusChanceLayoutToRAM_Loop2

	RTS

; =============== S U B R O U T I N E =======================================

DrawTitleCardWorldImage:
	LDA CurrentWorld
	CMP #6
	BEQ loc_BANKA_8392 ; Special case for World 7's title card

	LDA #$25
	STA byte_RAM_0
	LDA #$C8
	STA byte_RAM_1
	LDY #0

loc_BANKA_8338:
	LDX #$F
	LDA PPUSTATUS
	LDA byte_RAM_0
	STA PPUADDR

loc_BANKA_8342:
	LDA byte_RAM_1
	STA PPUADDR

loc_BANKA_8347:
	LDA World1thru6TitleCard, Y
	STA PPUDATA
	INY
	DEX
	BPL loc_BANKA_8347

	CPY #$A0
	BCS loc_BANKA_8364

	LDA byte_RAM_1
	ADC #$20
	STA byte_RAM_1
	LDA byte_RAM_0
	ADC #0
	STA byte_RAM_0
	JMP loc_BANKA_8338

; ---------------------------------------------------------------------------

loc_BANKA_8364:
	LDA CurrentWorld
	CMP #1
	BEQ loc_BANKA_8371

	CMP #5
	BEQ loc_BANKA_8371

	BNE loc_BANKA_8389

loc_BANKA_8371:
	AND #$80
	BNE loc_BANKA_8389

	LDA #$26
	STA byte_RAM_0
	LDA #$88
	STA byte_RAM_1
	LDA CurrentWorld
	ORA #$80
	STA CurrentWorld
	LDY #$80
	BNE loc_BANKA_8338

loc_BANKA_8389:
	LDA CurrentWorld
	AND #$F
	STA CurrentWorld
	RTS

; ---------------------------------------------------------------------------

loc_BANKA_8392:
	LDA #$25
	STA byte_RAM_0
	LDA #$C8
	STA byte_RAM_1
	LDY #0

loc_BANKA_839C:
	LDX #$F
	LDA PPUSTATUS
	LDA byte_RAM_0
	STA PPUADDR
	LDA byte_RAM_1
	STA PPUADDR

loc_BANKA_83AB:
	LDA World7TitleCard, Y
	STA PPUDATA
	INY
	DEX
	BPL loc_BANKA_83AB

	CPY #$A0
	BCS locret_BANKA_83C8

	LDA byte_RAM_1
	ADC #$20
	STA byte_RAM_1
	LDA byte_RAM_0
	ADC #0
	STA byte_RAM_0
	JMP loc_BANKA_839C

; ---------------------------------------------------------------------------

locret_BANKA_83C8:
	RTS

; End of function DrawTitleCardWorldImage

StatOffsets:
	.db (MarioStats - CharacterStats)
	.db (PrincessStats - CharacterStats)
	.db (ToadStats - CharacterStats)
	.db (LuigiStats - CharacterStats)

CharacterStats:
MarioStats:
	.db $00 ; Pick-up Speed, frame 1/6 - pulling
	.db $04 ; Pick-up Speed, frame 2/6 - pulling
	.db $02 ; Pick-up Speed, frame 3/6 - ducking
	.db $01 ; Pick-up Speed, frame 4/6 - ducking
	.db $04 ; Pick-up Speed, frame 5/6 - ducking
	.db $07 ; Pick-up Speed, frame 6/6 - ducking
	.db $B0 ; Jump Speed, still - no object
	.db $B0 ; Jump Speed, still - with object
	.db $98 ; Jump Speed, charged - no object
	.db $98 ; Jump Speed, charged - with object
	.db $A6 ; Jump Speed, running - no object
	.db $AA ; Jump Speed, running - with object
	.db $E0 ; Jump Speed - in quicksand
	.db $00 ; Floating Time
	.db $07 ; Gravity without Jump button pressed
	.db $04 ; Gravity with Jump button pressed
	.db $08 ; Gravity in quicksand
	.db $18 ; Running Speed, right - no object
	.db $18 ; Running Speed, right - with object
	.db $04 ; Running Speed, right - in quicksand
	.db $E8 ; Running Speed, left - no object
	.db $E8 ; Running Speed, left - with object
	.db $FC ; Running Speed, left - in quicksand

ToadStats:
	.db $00 ; Pick-up Speed, frame 1/6 - pulling
	.db $01 ; Pick-up Speed, frame 2/6 - pulling
	.db $01 ; Pick-up Speed, frame 3/6 - ducking
	.db $01 ; Pick-up Speed, frame 4/6 - ducking
	.db $01 ; Pick-up Speed, frame 5/6 - ducking
	.db $02 ; Pick-up Speed, frame 6/6 - ducking
	.db $B2 ; Jump Speed, still - no object
	.db $B2 ; Jump Speed, still - with object
	.db $98 ; Jump Speed, charged - no object
	.db $98 ; Jump Speed, charged - with object
	.db $AD ; Jump Speed, running - no object
	.db $AD ; Jump Speed, running - with object
	.db $E0 ; Jump Speed - in quicksand
	.db $00 ; Floating Time
	.db $07 ; Gravity without Jump button pressed
	.db $04 ; Gravity with Jump button pressed
	.db $08 ; Gravity in quicksand
	.db $18 ; Running Speed, right - no object
	.db $1D ; Running Speed, right - with object
	.db $04 ; Running Speed, right - in quicksand
	.db $E8 ; Running Speed, left - no object
	.db $E3 ; Running Speed, left - with object
	.db $FC ; Running Speed, left - in quicksand

LuigiStats:
	.db $00 ; Pick-up Speed, frame 1/6 - pulling
	.db $04 ; Pick-up Speed, frame 2/6 - pulling
	.db $02 ; Pick-up Speed, frame 3/6 - ducking
	.db $01 ; Pick-up Speed, frame 4/6 - ducking
	.db $04 ; Pick-up Speed, frame 5/6 - ducking
	.db $07 ; Pick-up Speed, frame 6/6 - ducking
	.db $D6 ; Jump Speed, still - no object
	.db $D6 ; Jump Speed, still - with object
	.db $C9 ; Jump Speed, charged - no object
	.db $C9 ; Jump Speed, charged - with object
	.db $D0 ; Jump Speed, running - no object
	.db $D4 ; Jump Speed, running - with object
	.db $E0 ; Jump Speed - in quicksand
	.db $00 ; Floating Time
	.db $02 ; Gravity without Jump button pressed
	.db $01 ; Gravity with Jump button pressed
	.db $08 ; Gravity in quicksand
	.db $18 ; Running Speed, right - no object
	.db $16 ; Running Speed, right - with object
	.db $04 ; Running Speed, right - in quicksand
	.db $E8 ; Running Speed, left - no object
	.db $EA ; Running Speed, left - with object
	.db $FC ; Running Speed, left - in quicksand

PrincessStats:
	.db $00 ; Pick-up Speed, frame 1/6 - pulling
	.db $06 ; Pick-up Speed, frame 2/6 - pulling
	.db $04 ; Pick-up Speed, frame 3/6 - ducking
	.db $02 ; Pick-up Speed, frame 4/6 - ducking
	.db $06 ; Pick-up Speed, frame 5/6 - ducking
	.db $0C ; Pick-up Speed, frame 6/6 - ducking
	.db $B3 ; Jump Speed, still - no object
	.db $B3 ; Jump Speed, still - with object
	.db $98 ; Jump Speed, charged - no object
	.db $98 ; Jump Speed, charged - with object
	.db $AC ; Jump Speed, running - no object
	.db $B3 ; Jump Speed, running - with object
	.db $E0 ; Jump Speed - in quicksand
	.db $3C ; Floating Time
	.db $07 ; Gravity without Jump button pressed
	.db $04 ; Gravity with Jump button pressed
	.db $08 ; Gravity in quicksand
	.db $18 ; Running Speed, right - no object
	.db $15 ; Running Speed, right - with object
	.db $04 ; Running Speed, right - in quicksand
	.db $E8 ; Running Speed, left - no object
	.db $EB ; Running Speed, left - with object
	.db $FC ; Running Speed, left - in quicksand

CharacterPalette:
MarioPalette:
	.db $0F,$01,$16,$27
PrincessPalette:
	.db $0F,$06,$25,$36
ToadPalette:
	.db $0F,$01,$30,$27
LuigiPalette:
	.db $0F,$01,$2A,$36

MysteryData14439:
	.db $DF
	.db $EF
	.db $F7
	.db $FB
	.db $00
	.db $FF
	.db $FF
	.db $FF
	.db $AF
	.db $D7
	.db $EB
	.db $F5
	.db $FB
	.db $F7
	.db $EF
	.db $DF
	.db $00
	.db $FF
	.db $FF
	.db $FF
	.db $F5
	.db $EB
	.db $D7
	.db $AF


;
; This copies the selected character's stats
; into memory for use later, but also a bunch
; of other unrelated crap like the
; Bonus Chance slot reels (???) and
; god knows what else.
;
CopyCharacterStatsAndStuff:
IFDEF CONTROLLER_2_DEBUG
	JSR CopyCharacterStats
ENDIF

	LDX CurrentCharacter
	LDY StatOffsets, X
	LDX #$00
loc_BANKA_8458:
	LDA CharacterStats, Y
	STA CharacterStatsRAM, X
	INY
	INX
	CPX #$17
	BCC loc_BANKA_8458

	LDA CurrentCharacter
	ASL A
	ASL A
	TAY
	LDX #$00
loc_BANKA_846B:
	LDA CharacterPalette, Y
	STA RestorePlayerPalette0, X
	INY
	INX
	CPX #$04
	BCC loc_BANKA_846B

	LDY #$4C
loc_BANKA_8479:
	LDA PlayerSelectPalettes, Y
	STA PPUBuffer_55F, Y
	DEY
	CPY #$FF
	BNE loc_BANKA_8479

	LDY #$B6
loc_BANKA_8486:
	LDA BonusChanceReel1Order, Y
	STA SlotMachineReelOrder1RAM, Y
	DEY
	CPY #$FF
	BNE loc_BANKA_8486

	LDY #$63
loc_BANKA_8493:
	LDA Text_Unknown5, Y
	STA PPUBuffer_7168, Y
	DEY
	CPY #$FF
	BNE loc_BANKA_8493

	; This data is copied, but doesn't appear to be used. Its original purpose is not obvious.
	LDY #$17
loc_BANKA_84A0:
	LDA MysteryData14439, Y
	STA unk_RAM_7150, Y
	DEY
	BPL loc_BANKA_84A0

	; Copy object collision hitbox table
	LDY #$4F
loc_BANKA_84AB:
	LDA ObjectCollisionHitboxLeft, Y
	STA ObjectCollisionHitboxLeft_RAM, Y
	DEY
	BPL loc_BANKA_84AB

	; Copy flying carpet acceleration table
	LDY #$03
loc_BANKA_84B6:
	LDA byte_BANKA_84E1, Y
	STA byte_RAM_71CC, Y
	DEY
	BPL loc_BANKA_84B6

	; Copy object collision type table
	LDY #$49
loc_BANKA_84C1:
	LDA byte_BANKF_F607, Y
	STA unk_RAM_71D1, Y
	DEY
	BPL loc_BANKA_84C1

	; Copy end of level door PPU data to RAM
	;
	; The fact that it's in RAM is actually taken advantage of when defeating Clawgrip, since the
	; door needs to be drawn in a slightly different spot.
	LDY #$20
loc_BANKA_84CC:
	LDA EndOfLevelDoor, Y
	STA PPUBuffer_721B, Y
	DEY
	BPL loc_BANKA_84CC

	; Copy Wart's OAM address table
	LDY #$06
loc_BANKA_84D7:
	LDA byte_BANKA_84E5, Y
	STA unk_RAM_7265, Y
	DEY
	BPL loc_BANKA_84D7

	RTS


; Flying carpet acceleration
byte_BANKA_84E1:
	.db $00
	.db $01
	.db $FF
	.db $00

; Wart OAM address offsets
byte_BANKA_84E5:
	.db $00
	.db $E0
	.db $FF ; Cycled in code ($7267)
	.db $D0
	.db $00
	.db $E0
	.db $FF ; Cycled in code ($726B)

PlayerSelectPalettes:
IFNDEF CUSTOM_TITLE
	.db $30 + pal_blkC, $00, $20
	.db pal_blkC, $20 + pal_yell, $10 + pal_redB, pal_redB
	.db pal_blkC, $30 + pal_grey, $10 + pal_bluB, $10 + pal_redB
	.db pal_blkC, $30 + pal_grey, $10 + pal_redB, $10 + pal_bluB
	.db pal_blkC, $30 + pal_grey, $10 + pal_bluB, $10 + pal_redB
	.db pal_blkC, $20 + pal_bluB, $10 + pal_bluB, pal_bluA 
	.db pal_blkC, $20 + pal_bluB, $10 + pal_bluB, pal_bluA 
	.db pal_blkC, $20 + pal_bluB, $10 + pal_bluB, pal_bluA 
	.db pal_blkC, $20 + pal_bluB, $10 + pal_bluB, pal_bluA 
	.db $00
ELSE
	.db $30 + pal_blkC, $00, $20
	.db pal_blkC, $20 + pal_bluB, $10 + pal_purp, pal_purp
	.db pal_blkC, $10 + pal_grey, $10 + pal_bluB, $10 + pal_redB
	.db pal_blkC, $10 + pal_grey, $10 + pal_redB, $10 + pal_bluB
	.db pal_blkC, $10 + pal_grey, $10 + pal_bluB, $10 + pal_redB
	.db pal_blkC, $20 + pal_bluB, $10 + pal_bluB, pal_bluA 
	.db pal_blkC, $20 + pal_bluB, $10 + pal_bluB, pal_bluA 
	.db pal_blkC, $20 + pal_bluB, $10 + pal_bluB, pal_bluA 
	.db pal_blkC, $20 + pal_bluB, $10 + pal_bluB, pal_bluA 
	.db $00
ENDIF
BonusChanceText_X_1:
	.db $22,$30,$03,$EA,$FB,$D1
BonusChanceText_EXTRA_LIFE_1:
	.db $22,$C9,$0F,$DE,$F1,$ED,$EB,$DA,$FB,$E5,$E2,$DF,$DE,$F9,$F9
	.db $F9,$FB,$D1,$00 ; $0F
BonusChanceBackgroundPalettes:
IFNDEF CUSTOM_TITLE
	.db pal_blkC, $20 + pal_orng, $10 + pal_orng, $00 + pal_orng ; $00
	.db pal_blkC, $30 + pal_orng, $10 + pal_redB, $10 + pal_bluB ; $04
	.db pal_blkC, $30 + pal_grey, $10 + pal_grey, $00 + pal_grey ; $08
	.db pal_blkC, $20 + pal_bluA, $10 + pal_bluB, $00 + pal_bluA ; $0C
ELSE
	.db pal_blkC, $20 + pal_orng, $10 + pal_orng, $00 + pal_orng ; $00
	.db pal_blkC, $30 + pal_orng, $10 + pal_redB, $10 + pal_bluB ; $04
	.db pal_blkC, $30 + pal_grey, $10 + pal_grey, $00 + pal_grey ; $08
	.db pal_blkC, $20 + pal_bluA, $10 + pal_bluB, $00 + pal_bluA ; $0C
ENDIF
BonusChanceReel1Order:
	.db Slot_Snifit ; $00
	.db Slot_Turnip ; $01 ; Graphics exist for a mushroom (not used)
	.db Slot_Star   ; $02
	.db Slot_Turnip ; $03
	.db Slot_Snifit ; $04
	.db Slot_Star   ; $05
	.db Slot_Cherry ; $06
	.db Slot_Turnip ; $07
BonusChanceReel2Order:
	.db Slot_Star   ; $00
	.db Slot_Snifit ; $01
	.db Slot_Cherry ; $02
	.db Slot_Snifit ; $03
	.db Slot_Turnip ; $04
	.db Slot_Star   ; $05
	.db Slot_Snifit ; $06
	.db Slot_Turnip ; $07
BonusChanceReel3Order:
	.db Slot_Star   ; $00
	.db Slot_Snifit ; $01
	.db Slot_Star   ; $02
	.db Slot_Turnip ; $03
	.db Slot_Star   ; $04
	.db Slot_Cherry ; $05
	.db Slot_Turnip ; $06
	.db Slot_Snifit ; $07
BonusChanceUnusedCoinSprite:
	.db $F8,$19,$01,$60,$F8,$1B,$01,$68
BonusChanceUnusedImajinHead:
	.db $CB,$B0,$00,$A0,$CB,$B0,$40,$A8
BonusChanceUnusedLinaHead:
	.db $CB,$B2,$00,$A0,$CB,$B2,$40,$A8
BonusChanceUnusedMamaHead:
	.db $CB,$B6,$00,$A0,$CB,$B6,$40,$A8
BonusChanceUnusedPapaHead:
	.db $CB,$B4,$00,$A0,$CB,$B4,$40,$A8
BonusChanceUnused_Blank20C6:
	.db $20,$C6,$14,$FB,$FB,$FB,$FB,$FB,$FB,$FB,$FB,$FB,$FB,$FB,$FB
	.db $FB,$FB,$FB,$FB,$FB,$FB,$FB,$FB,$00 ; $0F
BonusChanceText_NO_BONUS:
	.db $22,$86,$14,$FB,$FB,$FB,$FB,$FB,$FB,$E7,$E8,$FB,$DB,$E8,$E7
	.db $EE,$EC,$FB,$FB,$FB,$FB,$FB,$FB,$00 ; $0F
BonusChanceText_PUSH_A_BUTTON:
	.db $22,$89,$0E,$E9,$EE,$EC,$E1,$FB,$0E,$F,$FB,$DB,$EE,$ED,$ED,$E8
	.db $E7,$00 ; $10
BonusChanceText_PLAYER_1UP:
	.db $22,$8B,$0B,$E9,$E5,$DA,$F2,$DE,$EB,$FB,$FB,$D1,$EE,$E9,$00
Text_PAUSE:
	.db $25,$ED,$05,$E9,$DA,$EE,$EC,$DE
Text_Unknown:
	.db $27,$DB,$02,$AA,$AA,$00
Text_Unknown2:
	.db $22,$86,$54,$FB,$00
Text_Unknown3:
	.db $22,$AA,$4D,$FB,$00
Text_Unknown4:
	.db $22,$EB,$4B,$FB,$00
Text_PAUSE_Erase:
	.db $25,$ED,$05,$FB,$FB,$FB,$FB,$FB,$00
Text_Unknown5:
	.db $25,$0E,$07,$FB,$FB,$FB,$FB,$FB,$FB,$FB ; This one is actually used, just not sure what for
Text_WORLD_1_1:
	.db $24,$CA,$0B,$FB,$F0,$E8,$EB,$E5,$DD,$FB,$FB,$D1,$F3,$D1
Text_EXTRA_LIFE_0:
	.db $23,$48,$10,$DE,$F1,$ED,$EB,$DA,$FB,$E5,$E2,$DF,$DE,$F9,$F9
	.db $F9,$FB,$FB,$D0,$00 ; $0F
Text_WARP:
	.db $21,$8E,$04,$F0,$DA,$EB,$E9

; Doki Doki Panic pseudo-leftover
; This actually has extra spaces on either end:
; "-WORLD-" ... It originally said "CHAPTER"
Text_WORLD_1:
	.db $22,$0C,$09,$FB,$F0,$E8,$EB,$E5,$DD,$FB,$FB,$D1,$00
Text_Unknown6:
	.db $21,$6A,$01,$FB
Text_Unknown7:
	.db $21,$AA,$01,$FB,$00
Text_Unknown8:
	.db $21,$97,$C6,$FB,$00
UnusedText_THANK_YOU:
	.db $21,$0C,$09,$ED,$E1,$3A,$E7,$E4,$FB,$F2,$E8,$EE
UnusedText_Blank214D:
	.db $21,$4D,$06,$FB,$FB,$FB,$FB,$FB,$FB,$00

IFDEF CONTROLLER_2_DEBUG
;
; Copies all character stats to RAM for hot-swapping the current character
;
CopyCharacterStats:
	LDX #(MysteryData14439 - StatOffsets - 1)
CopyCharacterStats_Loop:
	LDA StatOffsets, X
	STA StatOffsetsRAM, X
	DEX
	BPL CopyCharacterStats_Loop

	RTS
ENDIF


IFDEF DEBUG
	.include "src/extras/debug/debug-a.asm"
ENDIF

IFDEF SECONDARY_ROUTINE_MOVE
	.include "src/systems/area_secondary_routine.asm"
ENDIF