;
; ## Ground setting data
;
; The ground setting defines a single column (or row, for vertical areas) where each row (or column)
; can be one of four tiles. These tiles are repeated until an object changes  the ground setting or
; the renderer reaches the the end of the area.
;
; An area has its initial ground setting set in the header, but it can be changed mid-area using the
; `$F0` and `$F1` special objects.
;

;
; #### Horizontal ground set data
;
; Two bits per tile are used to select from one of the four ground appearance tiles. The tiles are
; defined from top-to-bottom, except for the last tile, which is actually the top row!
;
; Ground appearance tiles are defined xpecifically in the `WorldXGroundTilesHorizontal` lookup
; tables, but here's an example of how they apply:
;
; - `%00`: default background (ie. sky)
; - `%01`: secondary platform (eg. sand)
; - `%10`: primary platform (eg. grass)
; - `%11`: secondary background (eg. black background in 3-2)
;
HorizontalGroundSetData:
	.db $00,$00,$00,$24 ; $00
	.db $00,$00,$02,$54 ; $01
	.db $00,$02,$55,$54 ; $02
	.db $00,$02,$7F,$54 ; $03
	.db $00,$02,$7F,$D4 ; $04
	.db $00,$03,$FF,$54 ; $05
	.db $00,$02,$5F,$FC ; $06
	.db $00,$03,$FF,$FC ; $07
	.db $00,$00,$00,$00 ; $08
	.db $55,$55,$55,$7C ; $09
	.db $E7,$9E,$79,$E4 ; $0A
	.db $00,$0E,$79,$E4 ; $0B
	.db $00,$00,$09,$E4 ; $0C
	.db $00,$00,$00,$24 ; $0D
	.db $E0,$0E,$79,$E4 ; $0E
	.db $E4,$00,$09,$E4 ; $0F
	.db $E4,$00,$00,$24 ; $10
	.db $E7,$90,$09,$E4 ; $11
	.db $E7,$9E,$70,$24 ; $12
	.db $E7,$9E,$40,$24 ; $13
	.db $E7,$9C,$00,$24 ; $14
	.db $E0,$0E,$40,$24 ; $15
	.db $00,$00,$00,$E4 ; $16
	.db $E4,$00,$00,$00 ; $17
	.db $E7,$9E,$79,$E4 ; $18
	.db $E7,$90,$01,$E4 ; $19
	.db $E0,$00,$01,$E4 ; $1A
	.db $E7,$90,$00,$24 ; $1B
	.db $E0,$00,$00,$24 ; $1C
	.db $00,$00,$00,$24 ; $1D
	.db $00,$00,$00,$24 ; $1E
	; Based on the level header parsing code, $1F seems like it may have been reserved for some
	; special behavior at some point, but it doesn't appear to be implemented.
IFDEF EXPAND_TABLES
	.db $00,$00,$00,$24 ; $1F
ENDIF

;
; #### Vertical ground set data
;
; Two bits per tile are used to select from one of the four ground appearance tiles. The tiles are
; defined from left-to-right.
;
; Ground appearance tiles are defined xpecifically in the `WorldXGroundTilesVertical` lookup
; tables, but here's an example of how they apply:
;
; - `%00`: default background (ie. sky)
; - `%01`: secondary platform (eg. bombable wall, sand)
; - `%10`: primary platform
; - `%11`: secondary background
;
VerticalGroundSetData:
	.db $AA,$AA,$AA,$AA ; $00
	.db $80,$00,$00,$02 ; $01
	.db $AA,$00,$00,$AA ; $02
	.db $FA,$00,$00,$AF ; $03
	.db $FE,$00,$00,$BF ; $04
	.db $FA,$80,$02,$AF ; $05
	.db $E8,$00,$00,$2B ; $06
	.db $E0,$00,$00,$0B ; $07
	.db $FA,$95,$56,$AF ; $08
	.db $95,$00,$00,$56 ; $09
	.db $A5,$55,$55,$5A ; $0A
	.db $A5,$5A,$A5,$5A ; $0B
	.db $55,$55,$55,$55 ; $0C
	.db $95,$55,$55,$56 ; $0D
	.db $95,$5A,$A5,$56 ; $0E
	.db $A9,$55,$55,$6A ; $0F
	.db $81,$55,$55,$42 ; $10
	.db $AA,$A5,$55,$5A ; $11
	.db $A5,$55,$5A,$AA ; $12
	.db $00,$00,$00,$00 ; $13
	.db $80,$00,$00,$02 ; $14
	.db $A0,$00,$00,$0A ; $15
	.db $AA,$00,$00,$AA ; $16
	.db $AA,$A0,$0A,$AA ; $17
	.db $80,$00,$0A,$AA ; $18
	.db $80,$0A,$AA,$AA ; $19
	.db $AA,$AA,$A0,$02 ; $1A
	.db $AA,$A0,$00,$02 ; $1B
	.db $A0,$0A,$A0,$0A ; $1C
	.db $A0,$00,$00,$00 ; $1D
	.db $00,$00,$00,$0A ; $1E
	; Based on the level header parsing code, $1F seems like it may have been reserved for some
	; special behavior at some point, but it doesn't appear to be implemented.
IFDEF EXPAND_TABLES
	.db $00,$00,$00,$0A ; $1F
ENDIF