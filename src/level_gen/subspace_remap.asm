;
; Subspace tile remapping
; =======================
;
; The horizontal order of tiles is reversed in subspace. Tiles with an obvious
; left/right direction (eg. the corners of green platforms) appear backwards
; until they're swapped with the corresponding right/left version.
;
; This is handled in two tables corresponding tables. If a tile is found in the
; first table, it will be replaced with the tile at the corresponding offset in
; the second table.
;
SubspaceTilesSearch:
	.db $75 ; $00
	.db $77 ; $01
	.db $CA ; $02
	.db $CE ; $03
	.db $C7 ; $04
IFNDEF FIX_SUBSPACE_TILES
	.db $C8 ; $05 ; BUG: This should be $C9
ENDIF
IFDEF FIX_SUBSPACE_TILES
	.db $C9 ; $05
ENDIF
	.db $D0 ; $06
	.db $D1 ; $07
	.db $01 ; $08
	.db $02 ; $09
	.db $84 ; $0A
	.db $87 ; $0B
	.db $60 ; $0C
	.db $62 ; $0D
	.db $13 ; $0E
	.db $15 ; $0F
	.db $53 ; $10
	.db $55 ; $11
	.db $CB ; $12
	.db $CF ; $13
	.db $09 ; $14
	.db $0D ; $15

SubspaceTilesReplace:
	.db $77 ; $00
	.db $75 ; $01
	.db $CE ; $02
	.db $CA ; $03
IFNDEF FIX_SUBSPACE_TILES
	.db $C8 ; $04 ; BUG: This should be $C9
ENDIF
IFDEF FIX_SUBSPACE_TILES
	.db $C9 ; $04
ENDIF
	.db $C7 ; $05
	.db $D1 ; $06
	.db $D0 ; $07
	.db $02 ; $08
	.db $01 ; $09
	.db $87 ; $0A
	.db $84 ; $0B
	.db $62 ; $0C
	.db $60 ; $0D
	.db $15 ; $0E
	.db $13 ; $0F
	.db $55 ; $10
	.db $53 ; $11
	.db $CF ; $12
	.db $CB ; $13
	.db $0D ; $14
	.db $09 ; $15