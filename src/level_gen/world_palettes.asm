;
; ## Level palettes
;
; Each world has several sets of background and sprite palettes, which are set per area in the level
; header. Subspace is defined separately in each world, but they all use the same colors!
;

;
; #### Palette pointers
;
WorldBackgroundPalettePointersLo:
	.db <World1BackgroundPalettes
	.db <World2BackgroundPalettes
	.db <World3BackgroundPalettes
	.db <World4BackgroundPalettes
	.db <World5BackgroundPalettes
	.db <World6BackgroundPalettes
	.db <World7BackgroundPalettes

WorldSpritePalettePointersLo:
	.db <World1SpritePalettes
	.db <World2SpritePalettes
	.db <World3SpritePalettes
	.db <World4SpritePalettes
	.db <World5SpritePalettes
	.db <World6SpritePalettes
	.db <World7SpritePalettes

WorldBackgroundPalettePointersHi:
	.db >World1BackgroundPalettes
	.db >World2BackgroundPalettes
	.db >World3BackgroundPalettes
	.db >World4BackgroundPalettes
	.db >World5BackgroundPalettes
	.db >World6BackgroundPalettes
	.db >World7BackgroundPalettes

WorldSpritePalettePointersHi:
	.db >World1SpritePalettes
	.db >World2SpritePalettes
	.db >World3SpritePalettes
	.db >World4SpritePalettes
	.db >World5SpritePalettes
	.db >World6SpritePalettes
	.db >World7SpritePalettes

; #### World 1
;
World1BackgroundPalettes:
	; Day
	.db $21, $30, $12, $0F ; $00
	.db $21, $30, $16, $0F ; $04
	.db $21, $27, $17, $0F ; $08
	.db $21, $29, $1A, $0F ; $0C
	; Night
	.db $0F, $30, $12, $01 ; $10
	.db $0F, $30, $16, $02 ; $14
	.db $0F, $27, $17, $08 ; $18
	.db $0F, $29, $1A, $0A ; $1C
	; Underground
	.db $0F, $2C, $1C, $0C ; $20
	.db $0F, $30, $16, $02 ; $24
	.db $0F, $27, $17, $08 ; $28
	.db $0F, $2A, $1A, $0A ; $2C
	; Jar
	.db $07, $30, $27, $0F ; $30
	.db $07, $30, $16, $0F ; $34
	.db $07, $27, $17, $0F ; $38
	.db $07, $31, $21, $0F ; $3C
	; Castle
	.db $03, $2C, $1C, $0F ; $40
	.db $03, $30, $16, $0F ; $44
	.db $03, $3C, $1C, $0F ; $48
	.db $03, $25, $15, $05 ; $4C
	; Boss
	.db $0C, $30, $06, $0F ; $50
	.db $0C, $30, $16, $0F ; $54
	.db $0C, $30, $16, $0F ; $58
	.db $0C, $30, $26, $0F ; $5C
	; Subspace
	.db $01, $0F, $0F, $0F ; $60
	.db $01, $0F, $0F, $0F ; $64
	.db $01, $0F, $0F, $0F ; $68
	.db $01, $0F, $0F, $0F ; $6C

World1SpritePalettes:
	; Overworld
	.db $FF, $30, $16, $0F ; $00
	.db $FF, $38, $10, $0F ; $04
	.db $FF, $30, $25, $0F ; $08
	; Underground
	.db $FF, $30, $16, $02 ; $0C
	.db $FF, $38, $10, $02 ; $10
	.db $FF, $30, $25, $02 ; $14
	; Boss
	.db $FF, $30, $16, $0F ; $18
	.db $FF, $30, $10, $0F ; $1C
	.db $FF, $25, $10, $0F ; $20
IFDEF EXPAND_TABLES
	unusedSpace World1SpritePalettes + $30, $FF
ENDIF

;
; #### World 2
;
World2BackgroundPalettes:
	; Day
	.db $11, $30, $2A, $0F ; $00
	.db $11, $30, $16, $0F ; $04
	.db $11, $28, $18, $0F ; $08
	.db $11, $17, $07, $0F ; $0C
	; Night (unused?)
	.db $0F, $30, $2A, $0A ; $10
	.db $0F, $30, $16, $02 ; $14
	.db $0F, $28, $18, $08 ; $18
	.db $0F, $17, $07, $08 ; $1C
	; Underground
	.db $0F, $2A, $1A, $0A ; $20
	.db $0F, $30, $16, $02 ; $24
	.db $0F, $28, $18, $08 ; $28
	.db $0F, $27, $17, $07 ; $2C
	; Jar
	.db $07, $30, $27, $0F ; $30
	.db $07, $30, $16, $0F ; $34
	.db $07, $28, $17, $0F ; $38
	.db $07, $31, $11, $0F ; $3C;
	; Castle (unused)
	.db $0C, $2A, $1A, $0F ; $40
	.db $0C, $30, $16, $0F ; $44
	.db $0C, $17, $07, $0F ; $48
	.db $0C, $25, $15, $0F ; $4C
	; Boss
	.db $0C, $30, $1A, $0F ; $50
	.db $0C, $30, $16, $0F ; $54
	.db $0C, $30, $2A, $0F ; $58
	.db $0C, $30, $3A, $0F ; $5C
	; Subspace
	.db $01, $0F, $0F, $0F ; $60
	.db $01, $0F, $0F, $0F ; $64
	.db $01, $0F, $0F, $0F ; $68
	.db $01, $0F, $0F, $0F ; $6C

World2SpritePalettes:
	; Overworld
	.db $FF, $30, $16, $0F ; $00
	.db $FF, $38, $2A, $0F ; $04
	.db $FF, $30, $25, $0F ; $08
	; Underground
	.db $FF, $30, $16, $02 ; $0C
	.db $FF, $38, $2A, $02 ; $10
	.db $FF, $30, $25, $02 ; $14
	; Boss
	.db $FF, $30, $16, $0F ; $18
	.db $FF, $30, $10, $0F ; $1C
	.db $FF, $30, $23, $0F ; $20
IFDEF EXPAND_TABLES
	unusedSpace World2SpritePalettes + $30, $FF
ENDIF

;
; #### World 3
;
World3BackgroundPalettes:
	; Day
	.db $22, $30, $12, $0F ; $00
	.db $22, $30, $16, $0F ; $04
	.db $22, $27, $17, $0F ; $08
	.db $22, $29, $1A, $0F ; $0C
	; Night (unused)
	.db $0F, $30, $12, $01 ; $10
	.db $0F, $30, $16, $02 ; $14
	.db $0F, $27, $17, $08 ; $18
	.db $0F, $29, $1A, $04 ; $1C
	; Underground
	.db $0F, $30, $1C, $0C ; $20
	.db $0F, $30, $16, $02 ; $24
	.db $0F, $27, $17, $08 ; $28
	.db $0F, $26, $16, $06 ; $2C
	; Jar
	.db $07, $30, $27, $0F ; $30
	.db $07, $30, $16, $0F ; $34
	.db $07, $27, $17, $0F ; $38
	.db $07, $31, $31, $0F ; $3C
	; Castle
	.db $03, $31, $21, $0F ; $40
	.db $03, $30, $16, $0F ; $44
	.db $03, $3C, $1C, $0F ; $48
	.db $03, $2A, $1A, $0F ; $4C
	; Boss
	.db $0C, $30, $11, $0F ; $50
	.db $0C, $30, $16, $0F ; $54
	.db $0C, $30, $21, $0F ; $58
	.db $0C, $30, $31, $0F ; $5C
	; Subspace
	.db $01, $0F, $0F, $0F ; $60
	.db $01, $0F, $0F, $0F ; $64
	.db $01, $0F, $0F, $0F ; $68
	.db $01, $0F, $0F, $0F ; $6C

World3SpritePalettes:
	; Overworld
	.db $FF, $30, $16, $0F ; $00
	.db $FF, $38, $10, $0F ; $04
	.db $FF, $30, $25, $0F ; $08
	; Underground
	.db $FF, $30, $16, $02 ; $0C
	.db $FF, $38, $10, $02 ; $10
	.db $FF, $30, $25, $02 ; $14
	; Boss
	.db $FF, $30, $16, $0F ; $18
	.db $FF, $30, $10, $0F ; $1C
	.db $FF, $2B, $10, $0F ; $20
IFDEF EXPAND_TABLES
	unusedSpace World3SpritePalettes + $30, $FF
ENDIF

;
; #### World 4
;
World4BackgroundPalettes:
	; Day
	.db $23, $30, $12, $0F ; $00
	.db $23, $30, $16, $0F ; $04
	.db $23, $2B, $1B, $0F ; $08
	.db $23, $30, $32, $0F ; $0C
	; Night (unused)
	.db $0F, $30, $12, $01 ; $10
	.db $0F, $30, $16, $02 ; $14
	.db $0F, $2B, $1B, $0B ; $18
	.db $0F, $29, $1A, $0A ; $1C
	; Underground
	.db $0F, $32, $12, $01 ; $20
	.db $0F, $30, $16, $02 ; $24
	.db $0F, $2B, $1B, $0B ; $28
	.db $0F, $27, $17, $07 ; $2C
	; Jar
	.db $07, $30, $27, $0F ; $30
	.db $07, $30, $16, $0F ; $34
	.db $07, $27, $17, $0F ; $38
	.db $07, $21, $21, $0F ; $3C
	; Castle
	.db $03, $30, $12, $0F ; $40
	.db $03, $30, $16, $0F ; $44
	.db $03, $3C, $1C, $0F ; $48
	.db $03, $28, $18, $0F ; $4C
	; Boss
	.db $0C, $30, $00, $0F ; $50
	.db $0C, $30, $16, $0F ; $54
	.db $0C, $30, $10, $0F ; $58
	.db $0C, $30, $30, $0F ; $5C
	; Subspace
	.db $01, $0F, $0F, $0F ; $60
	.db $01, $0F, $0F, $0F ; $64
	.db $01, $0F, $0F, $0F ; $68
	.db $01, $0F, $0F, $0F ; $6C

World4SpritePalettes:
	; Overworld
	.db $FF, $30, $16, $0F ; $00
	.db $FF, $38, $10, $0F ; $04
	.db $FF, $30, $25, $0F ; $08
	; Underground
	.db $FF, $30, $16, $02 ; $0C
	.db $FF, $38, $10, $02 ; $10
	.db $FF, $30, $25, $02 ; $14
	; Boss
	.db $FF, $30, $16, $0F ; $18
	.db $FF, $30, $10, $0F ; $1C
	.db $FF, $27, $16, $0F ; $20
IFDEF EXPAND_TABLES
	unusedSpace World4SpritePalettes + $30, $FF
ENDIF

;
; #### World 5
;
World5BackgroundPalettes:
	; Night
	.db $0F, $30, $12, $01 ; $00
	.db $0F, $30, $16, $01 ; $04
	.db $0F, $27, $17, $07 ; $08
	.db $0F, $2B, $1B, $0B ; $0C
	; Also night (unused)
	.db $0F, $30, $12, $01 ; $10
	.db $0F, $30, $16, $02 ; $14
	.db $0F, $27, $17, $08 ; $18
	.db $0F, $29, $1A, $0A ; $1C
	; Underground
	.db $0F, $31, $12, $01 ; $20
	.db $0F, $30, $16, $02 ; $24
	.db $0F, $3C, $1C, $0C ; $28
	.db $0F, $2A, $1A, $0A ; $2C
	; Jar/Tree
	.db $07, $30, $27, $0F ; $30
	.db $07, $30, $16, $0F ; $34
	.db $07, $27, $17, $0F ; $38
	.db $07, $31, $01, $0F ; $3C
	; Castle
	.db $01, $2A, $1A, $0F ; $40
	.db $01, $30, $16, $0F ; $44
	.db $01, $3C, $1C, $0F ; $48
	.db $01, $25, $15, $05 ; $4C
	; Boss
	.db $0C, $30, $16, $0F ; $50
	.db $0C, $30, $16, $0F ; $54
	.db $0C, $30, $24, $0F ; $58
	.db $0C, $30, $34, $0F ; $5C
	; Subspace
	.db $01, $0F, $0F, $0F ; $60
	.db $01, $0F, $0F, $0F ; $64
	.db $01, $0F, $0F, $0F ; $68
	.db $01, $0F, $0F, $0F ; $6C

World5SpritePalettes:
	; Overworld
	.db $FF, $30, $16, $0F ; $00
	.db $FF, $38, $10, $0F ; $04
	.db $FF, $30, $25, $0F ; $08
	; Underground
	.db $FF, $30, $16, $02 ; $0C
	.db $FF, $38, $10, $02 ; $10
	.db $FF, $30, $25, $02 ; $14
	; Boss
	.db $FF, $30, $16, $0F ; $18
	.db $FF, $30, $16, $0F ; $1C
	.db $FF, $16, $30, $0F ; $20
IFDEF EXPAND_TABLES
	unusedSpace World5SpritePalettes + $30, $FF
ENDIF

;
; #### World 6
;
World6BackgroundPalettes:
	; Day
	.db $21, $30, $2A, $0F ; $00
	.db $21, $30, $16, $0F ; $04
	.db $21, $28, $18, $0F ; $08
	.db $21, $17, $07, $0F ; $0C
	; Night
	.db $0F, $30, $2A, $01 ; $10
	.db $0F, $30, $16, $02 ; $14
	.db $0F, $28, $18, $08 ; $18
	.db $0F, $17, $07, $08 ; $1C
	; Underground
	.db $0F, $30, $12, $01 ; $20
	.db $0F, $30, $16, $02 ; $24
	.db $0F, $28, $18, $08 ; $28
	.db $0F, $27, $17, $07 ; $2C
	; Jar
	.db $07, $30, $27, $0F ; $30
	.db $07, $30, $16, $0F ; $34
	.db $07, $28, $17, $0F ; $38
	.db $07, $31, $01, $0F ; $3C
	; Castle
	.db $0C, $2A, $1A, $0F ; $40
	.db $0C, $30, $16, $0F ; $44
	.db $0C, $17, $07, $0F ; $48
	.db $0C, $25, $15, $0F ; $4C
	; Boss
	.db $0C, $30, $1B, $0F ; $50
	.db $0C, $30, $16, $0F ; $54
	.db $0C, $30, $2B, $0F ; $58
	.db $0C, $30, $3B, $0F ; $5C
	; Subspace
	.db $01, $0F, $0F, $0F ; $60
	.db $01, $0F, $0F, $0F ; $64
	.db $01, $0F, $0F, $0F ; $68
	.db $01, $0F, $0F, $0F ; $6C

World6SpritePalettes:
	; Overworld
	.db $FF, $30, $16, $0F ; $00
	.db $FF, $38, $2A, $0F ; $04
	.db $FF, $30, $25, $0F ; $08
	; Underground
	.db $FF, $30, $16, $02 ; $0C
	.db $FF, $38, $2A, $02 ; $10
	.db $FF, $30, $25, $02 ; $14
	; Boss
	.db $FF, $30, $16, $0F ; $18
	.db $FF, $30, $10, $0F ; $1C
	.db $FF, $30, $23, $0F ; $20
IFDEF EXPAND_TABLES
	unusedSpace World6SpritePalettes + $30, $FF
ENDIF

;
; #### World 7
;
World7BackgroundPalettes:
	; Day
	.db $21, $30, $12, $0F ; $00
	.db $21, $30, $16, $0F ; $04
	.db $21, $27, $17, $0F ; $08
	.db $21, $29, $1A, $0F ; $0C
	; Night (unused)
	.db $0F, $30, $12, $01 ; $10
	.db $0F, $30, $16, $02 ; $14
	.db $0F, $27, $17, $08 ; $18
	.db $0F, $29, $1A, $0A ; $1C
	; Castle
	.db $0F, $2C, $1C, $0C ; $20
	.db $0F, $30, $16, $02 ; $24
	.db $0F, $27, $17, $08 ; $28
	.db $0F, $2A, $1A, $0A ; $2C
	; Jar (unused)
	.db $07, $30, $16, $0F ; $30
	.db $07, $30, $16, $0F ; $34
	.db $07, $27, $17, $0F ; $38
	.db $07, $31, $01, $0F ; $3C
	; Castle (unused)
	.db $0F, $3C, $2C, $0C ; $40
	.db $0F, $30, $16, $02 ; $44
	.db $0F, $28, $18, $08 ; $48
	.db $0F, $25, $15, $05 ; $4C
	; Boss
	.db $0C, $30, $08, $0F ; $50
	.db $0C, $30, $16, $0F ; $54
	.db $0C, $38, $18, $0F ; $58
	.db $0C, $28, $08, $0F ; $5C
	; Subspace
	.db $01, $0F, $0F, $0F ; $60
	.db $01, $0F, $0F, $0F ; $64
	.db $01, $0F, $0F, $0F ; $68
	.db $01, $0F, $0F, $0F ; $6C

World7SpritePalettes:
	; Overworld
	.db $FF, $30, $16, $0F ; $00
	.db $FF, $38, $10, $0F ; $04
	.db $FF, $30, $25, $0F ; $08
	; Underground
	.db $FF, $30, $16, $02 ; $0C
	.db $FF, $38, $10, $02 ; $10
	.db $FF, $30, $25, $02 ; $14
	; Boss
	.db $FF, $30, $16, $0F ; $18
	.db $FF, $30, $10, $0F ; $1C
	.db $FF, $30, $2A, $0F ; $20
IFDEF EXPAND_TABLES
	unusedSpace World7SpritePalettes + $30, $FF
ENDIF

; -----
