
char_space = #$FB

TitleLayout:
	; red lines, vertical, left
	.db $20, $00, $DE, $FD
	.db $20, $01, $DE, $FD
	.db $20, $02, $DE, $FD
	.db $20, $03, $DE, $FD
	; red lines, vertical, right
	.db $20, $1C, $DE, $FD
	.db $20, $1D, $DE, $FD
	.db $20, $1E, $DE, $FD
	.db $20, $1F, $DE, $FD
	; red lines, horizontal, top
	.db $20, $03, $5D, $FD
	.db $20, $23, $5D, $FD
	.db $20, $43, $5D, $FD
	.db $20, $63, $5D, $FD
	; red lines, vertical, bottom
	.db $23, $63, $5D, $FD
	.db $23, $83, $5D, $FD
	.db $23, $A3, $5D, $FD

	; ornate frame, top
	.db $20, $68, $10, $48, $4A, $4C, $4E, $50, $51, $52, $53, $54, $55, $56, $57, $58, $5A, $5C, $5E
	.db $20, $84, $08, $FD, $22, $23, $24, $49, $4B, $4D, $4F
	.db $20, $94, $08, $59, $5B, $5D, $5F, $2E, $2F, $30, $FD
	.db $20, $A4, $03, $25, $26, $27
	.db $20, $B9, $03, $31, $32, $33
	.db $20, $C4, $03, $28, $29, $2A
	.db $20, $D9, $03, $34, $35, $36
	.db $20, $E3, $03, $2B, $2C, $2D
	.db $20, $FA, $03, $37, $38, $39
	.db $21, $03, $02, $3A, $3B
	.db $21, $1B, $02, $40, $41
	; ornate frame, lines down, top
	.db $21, $23, $C6, $3C
	.db $21, $3C, $C6, $42
	; ornate frame, middle
	.db $21, $E3, $01, $3D
	.db $21, $FC, $01, $60
	.db $22, $02, $02, $3E, $3F
	.db $22, $1C, $02, $61, $62
	.db $22, $22, $02, $43, $44
	.db $22, $3C, $02, $63, $64
	.db $22, $43, $01, $45
	.db $22, $5C, $01, $65
	; ornate frame, lines down, bottom
	.db $22, $63, $C6, $3C
	.db $22, $7C, $C4, $42
	; ornate frame, bottom, characters
	.db $22, $C4, $02, $A6, $A8
	.db $22, $E4, $02, $A7, $A9
	.db $22, $FA, $04, $80, $82, $88, $8A
	.db $23, $04, $02, $90, $92
	.db $23, $14, $02, $9E, $A0
	.db $23, $1A, $04, $81, $83, $89, $8B
	.db $23, $23, $03, $46, $91, $93
	.db $23, $2A, $02, $A2, $A4
	.db $23, $2E, $0B, $67, $6C, $6E, $70, $72, $69, $9F, $A1, $75, $98, $9A
	.db $23, $3A, $04, $84, $86, $8C, $8E
	.db $23, $43, $1B, $47, $94, $96, $74, $74, $74, $74, $A3, $A5, $74, $66, $68
	.db $6D, $6F, $71, $73, $6A, $6B, $74, $74, $99, $9B, $74, $85, $87, $8D, $8F
	.db $23, $64, $05, $95, $97, $FD, $AA ,$AB
	.db $23, $77, $04, $9C, $9D, $AA, $AB
	.db $23, $89, $02, $AA, $AB

	; SUPER
	;                  SSSSSSSS  UUUUUUUU  PPPPPPPP  EEEEEEEE  RRRRRRRR
	.db $20, $CB, $0A, $00, $01, $08, $08, $FC, $01, $FC, $08, $FC, $01
	.db $20, $EB, $0A, $02, $03, $08, $08, $0A, $05, $0B, $0C, $0A, $0D
	.db $21, $0B, $0A, $04, $05, $04, $05, $0E, $07, $FC, $08, $0E, $08
	.db $21, $2B, $05, $06, $07, $06, $07, $09
	.db $21, $31, $04, $76, $09, $09, $09

	; TM
	;                  TTT  MMM
	.db $21, $38, $02, $F9, $FA

	; MARIO
	;                  MMMMMMMMMMMMM  AAAAAAAA  RRRRRRRR  III  OOOOOOOO
	.db $21, $46, $0A, $00, $0F, $01, $00, $01, $FC, $01, $08, $00, $01
	.db $21, $66, $0A, $10, $10, $08, $10, $08, $10, $08, $08, $10, $08
	.db $21, $86, $0A, $08, $08, $08, $08, $08, $13, $0D, $08, $08, $08
	.db $21, $A6, $0A, $08, $08, $08, $FC, $08, $0E, $08, $08, $08, $08
	.db $21, $C6, $0A, $08, $08, $08, $10, $08, $08, $08, $08, $04, $05
	.db $21, $E6, $0A, $09, $09, $09, $09, $09, $09, $09, $09, $06, $07

	; BROS
	;                  BBBBBBBB  RRRRRRRR  OOOOOOOO  SSSSSSSS
	.db $21, $51, $08, $FC, $01, $FC, $01, $00, $01, $00, $01 ; BROS
	.db $21, $71, $08, $10, $08, $10, $08, $10, $08, $10, $08
	.db $21, $91, $08, $13, $0D, $13, $0D, $08, $08, $77, $03
	.db $21, $B1, $08, $0E, $08, $0E, $08, $08, $08, $12, $08
	.db $21, $D1, $09, $13, $05, $08, $08, $04, $05, $04, $05, $08
	.db $21, $F1, $09, $11, $07, $09, $09, $06, $07, $06, $07, $09

      .BYTE $22,$6,4,$14,$15,$16,$17		  
      .BYTE $22,$26,4,$18,$19,$1A,$1B		  
      .BYTE $22,$46,4,$1C,$1D,$1E,$1F		  
      .BYTE $22,$66,4,$FC,$FC,$FC,$20		  
      .BYTE $22,$86,4,$76,$76,$76,$21		  
FunkyLittleSeedBlock:
      .BYTE $22, $B, $0F, 'OPEN' + $99, char_space, 'RANDOMIZER' + $99
FunkyLittleSeedBlock2:
      .BYTE $22, $2B, $0F, 'NO' + $99, char_space, 'OBJECTIVE' + $99, char_space, char_space, char_space;  
FunkyLittleSeedBlock3:
      .BYTE $22, $4B, $0F, $CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF
FunkyLittleSeedBlock4:
      .BYTE $22, $6B, $0F, $CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF
FunkyLittleSeedBlock5:
      .BYTE $22, $8B, $0F, $CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF
FunkyLittleSeedBlock6:
      .BYTE $22, $a7, $13, $CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF
FunkyLittleSeedBlock7:
      .BYTE $22, $c7, $13, $CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF


	; (C) 1988
	;                  (C)  111  999  888  888
	.db $22, $E7, $05, $F8, $D1, $D9, $D8, $D8  ; (C) 1988

	.db $22, $EC, $05, $F4, $D2, $D0, $D2, $D1  ; (C) 2021

	; NINTENDO
	;                  NNN  III  NNN  TTT  EEE  NNN  DDD  OOO
	.db $22, $F2, $08, 'NINTENDO' + $99

	.db $00

IFDEF PAD_TITLE_SCREEN_PPU_DATA
	.pad TitleLayout + $300, $00
ENDIF

TitleBackgroundPalettes:
	.db $20 + pal_bluB,$30 + pal_bluB,$90 + pal_purp,$00 + pal_orng
	.db $20 + pal_bluB,$30 + pal_orng,$10 + pal_redB,$00 + pal_orng ; Most of screen, outline, etc.
	.db $20 + pal_bluB,$30 + pal_grey,$30 + pal_bluA,$00 + pal_blkC ; Unused
	.db $20 + pal_bluB,$30 + pal_grey,$00 + pal_blkC,$00 + pal_blkC ; Logo
	.db $20 + pal_bluB,$30 + pal_grey,$00 + pal_blkC,$00 + pal_blkC ; Copyright, Story

TitleSpritePalettes:
	.db $22, $30, $28, $0F ; Unused DDP character palettes
	.db $22, $30, $25, $0F ; There are no sprites on the title screen,
	.db $22, $30, $12, $0F ; so these are totally unused
	.db $22, $30, $23, $0F

TitleStoryText_STORY:
	.db 'STORY' + $99

TitleStoryTextPointersHi:
	.db >TitleStoryText_Line01
	.db >TitleStoryText_Line02
	.db >TitleStoryText_Line03
	.db >TitleStoryText_Line04
	.db >TitleStoryText_Line05
	.db >TitleStoryText_Line06
	.db >TitleStoryText_Line07
	.db >TitleStoryText_Line08
	.db >TitleStoryText_Line09
	.db >TitleStoryText_Line10
	.db >TitleStoryText_Line11
	.db >TitleStoryText_Line12
	.db >TitleStoryText_Line13
	.db >TitleStoryText_Line14
	.db >TitleStoryText_LineBlank
	.db >TitleStoryText_Line16
	.db >TitleStoryText_LineBlank
	.db >TitleStoryText_LineCredit1
	.db >TitleStoryText_LineCredit2
	.db >TitleStoryText_LineBlank
	.db >TitleStoryText_LineCredit4
	.db >TitleStoryText_LineCredit5
	.db >TitleStoryText_LineBlank
	.db >TitleStoryText_LineCredit7
	.db >TitleStoryText_LineCredit8
	.db >TitleStoryText_LineBlank
	.db >TitleStoryText_LineCreditA
	.db >TitleStoryText_LineCreditB
	.db >TitleStoryText_LineBlank
	.db >TitleStoryText_LineCreditD
	.db >TitleStoryText_LineBlank
	.db >TitleStoryText_LineCreditF
	.db >TitleStoryText_LineBlank
	.db >TitleStoryText_LineStart

TitleStoryTextPointersLo:
	.db <TitleStoryText_Line01
	.db <TitleStoryText_Line02
	.db <TitleStoryText_Line03
	.db <TitleStoryText_Line04
	.db <TitleStoryText_Line05
	.db <TitleStoryText_Line06
	.db <TitleStoryText_Line07
	.db <TitleStoryText_Line08
	.db <TitleStoryText_Line09
	.db <TitleStoryText_Line10
	.db <TitleStoryText_Line11
	.db <TitleStoryText_Line12
	.db <TitleStoryText_Line13
	.db <TitleStoryText_Line14
	.db <TitleStoryText_LineBlank
	.db <TitleStoryText_Line16
	.db <TitleStoryText_LineBlank
	.db <TitleStoryText_LineCredit1
	.db <TitleStoryText_LineCredit2
	.db <TitleStoryText_LineBlank
	.db <TitleStoryText_LineCredit4
	.db <TitleStoryText_LineCredit5
	.db <TitleStoryText_LineBlank
	.db <TitleStoryText_LineCredit7
	.db <TitleStoryText_LineCredit8
	.db <TitleStoryText_LineBlank
	.db <TitleStoryText_LineCreditA
	.db <TitleStoryText_LineCreditB
	.db <TitleStoryText_LineBlank
	.db <TitleStoryText_LineCreditD
	.db <TitleStoryText_LineBlank
	.db <TitleStoryText_LineCreditF
	.db <TitleStoryText_LineBlank
	.db <TitleStoryText_LineStart

TitleStoryText_Line01:
	.db 'WHEN MARIO OPENED A ' + $99

TitleStoryText_Line02:
	.db 'DOOR AFTER CLIMBING ' + $99

TitleStoryText_Line03:
	.db 'A LONG STAIR IN HIS ' + $99

TitleStoryText_Line04:
	.db 'DREAM' + $99, $F7, 'ANOTHER WORLD ' + $99

TitleStoryText_Line05:
	.db 'SPREAD BEFORE HIM   ' + $99

TitleStoryText_Line06:
	.db 'AND HE HEARD A VOICE' + $99

TitleStoryText_Line07:
	.db 'CALL FOR HELP TO BE ' + $99

TitleStoryText_Line08:
	.db 'FREED FROM A SPELL  ' + $99

TitleStoryText_Line09:
	.db 'AFTER AWAKENING' + $99, $F7, '    ' + $99

TitleStoryText_Line10:
	.db 'MARIO WENT TO A     ' + $99

TitleStoryText_Line11:
	.db 'CAVE NEARBY AND TO  ' + $99

TitleStoryText_Line12:
	.db 'HIS SURPRISE HE SAW ' + $99

TitleStoryText_Line13:
	.db 'EXACTLY WHAT HE SAW ' + $99

TitleStoryText_Line14:
	.db ' IN HIS DREAM' + $99, $F6, $F6, $F6, $F6 

TitleStoryText_LineBlank:
	.db '                    ' + $99

TitleStoryText_LineStart:
TitleStoryText_Line16:
	.db ' PUSH START BUTTON  ' + $99

TitleStoryText_LineCredit1:
    ;.db $E9, $EB, $E8, $E0, $EB, $DA, $E6, $E6, $DE, $DD, char_space, $DB, $F2, char_space, char_space;
	.db "PROGRAMMED BY     " + $99
	.db $ac, $ae; sheepright

TitleStoryText_LineCredit2:
	.db "PEPPERPOW         " + $99
	.db $ad, $af; (blank)

TitleStoryText_LineCredit4:
	.db $b4, $b6; devilright
	.db char_space ; (blank)
	.db "ASM" + $99, char_space, "DOCUMENTATION" + $99
;    .db $DA, $EC, $E6, char_space, $DD, $E8, $DC, $EE, $E6, $DE, $E7, $ED, $DA, $ED, $E2, $E8, $E7

TitleStoryText_LineCredit5:
	.db $b5, $b7, $c9 ; (blank)
	.db char_space, char_space, char_space ; (blank)
	.db char_space;
    .db $F1, $E4, $DE, $DE, $E9, $DE, $EB, $F7, char_space, $E4, $E6, $DC, $E4, char_space, char_space
	.db "XKEEPER," + $99, char_space, "KMCK" + $99

TitleStoryText_LineCredit7:
    .db $DC, $EE, $EC, $ED, $E8, $E6, char_space, $E0, $EB, $DA, $E9, $E1, $E2, $DC, $EC
	.db char_space, char_space, char_space ; (blank)
	.db $b0, $b2; (blank)

TitleStoryText_LineCredit8:
    .db $E9, $DA, $E4, $E8, $F7, char_space, $E9, $DE, $E9, $E9, $DE, $EB, $E9, $E8, $F0, $DE, $EB
	.db char_space, $b1, $b3; (blank)

TitleStoryText_LineCreditA:
	.db $BC, $BE, char_space, char_space, char_space, char_space, char_space, char_space, char_space
    .db $E9, $EB, $E8, $E0, char_space, $DA, $EC, $EC, $E2, $EC, $ED, char_space, char_space, char_space, char_space
	.db char_space, char_space, char_space, char_space ; (blank)
	.db $CF, $CF, $CF, $CF ; (blank)

TitleStoryText_LineCreditB:
	.db $BD, $BF, char_space, char_space, char_space, char_space, char_space
    .db $E4, $E6, $DC, $E4, $F7, char_space, $F1, $E4, $DE, $DE, $E9, $DE, $EB, char_space, char_space
	.db char_space, char_space, char_space, char_space ; (blank)
	.db $CF, $CF, $CF, $CF ; (blank)

TitleStoryText_LineCreditD:
    .db 'SPECIAL THANKS ' + $99
	.db char_space, char_space, char_space, char_space ; (blank)
	.db char_space; (blank)

TitleStoryText_LineCreditE:
    .db char_space, char_space, char_space, char_space, char_space, char_space, char_space, char_space, char_space, char_space, $E5, $E8, $E0, $E2, $E7, $EC, $E2, $E7, $DE, $F1
	.db char_space, char_space, char_space, char_space ; (blank)
	.db $CF, $CF, $CF, $CF ; (blank)

TitleStoryText_LineCreditF:
	.db '             TO YOU' + $99, $F4, '   ' + $99
	.db $cb, $cd, char_space
	.db char_space, char_space, char_space ; (blank)
	.db char_space; (blank)


TitleAttributeData1:
	.db $23, $CB, $42, $FF
	.db $23, $D1, $01, $CC
	.db $23, $D2, $44, $FF
	.db $23, $D6, $01, $33
	.db $23, $D9, $01, $CC
	.db $23, $DA, $44, $FF

TitleAttributeData2:
	.db $23, $DE, $01, $33
	.db $23, $E1, $01, $CC
	.db $23, $E2, $44, $FF
	.db $23, $E6, $01, $33
	.db $23, $EA, $44, $FF
	.db $23, $E9, $01, $CC
	.db $23, $EE, $01, $33
